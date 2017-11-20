//
//  Order.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/10/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import CoreLocation
class Order {

    // Declare
    
    var orderID:String?
    
    var clientID: String?
    
    var isOnDemand: Bool?
    
    var location: HomeAddress?
    
    var isExpress: Bool?
    
    var isLaundry: Bool?
    
    var specialPreferences: String?
    
    var review: OrderReview?
    
    var status: OrderStatus?
    
    var laundromatID: String?
    
    var inventory: Inventory?
    
    var scheduledTimes: [String]?
    
    var price: Float?
    
    func fetchOrderID() -> String? {
        if let key = self.orderID {
            let newKey = key.replacingOccurrences(of: "https://laundry-project-database.firebaseio.com/", with: "")
            return newKey
        } else { return nil }
    }
    
    init() { // New Order
        let key = FIRDatabase.database().reference().child("Orders").child("allOrders").childByAutoId().key
        self.orderID = key
        self.orderID = self.orderID!.replacingOccurrences(of: "https://laundry-project-database.firebaseio.com/", with: "")
        print("Initialized order key: \(key)")
        scheduledTimes = [String]()
    }
    
    init(id: String, onDataRetreieved: @escaping () -> ()) { // Existing Order
        self.orderID = id
        scheduledTimes = [String]()
        dbFill {
            onDataRetreieved()
        }
    }
    
    func dbCreate(finished: @escaping (_ success: Bool) -> ()) {
        print("Attempting to retreive order key: \(orderID!)")

        if let uid = clientID, let oid = fetchOrderID(), let orderJSON = json {
                firebase.child("Users").child(uid).child("clientInfo").child("Orders").child(oid).setValue(orderJSON.dictionaryObject)
                firebase.child("Orders").child("allOrders").child(oid).setValue(orderJSON.dictionaryObject)
                finished(true)
            print("creating order in database . . .\n Order json object: \n\(orderJSON)")
        } else { print("Cannot init one of three: laundromat, orderID, json")
        finished(false)
        }
    }
    
    /*
     
     Creates order in database, Save order information to:
     
     - Previous Orders
     - Orders (all-encompassing)
     
     From here, should put into Open Orders Queue of nearest laundromat
     
     */
        
    func reject() {
        if let uid = clientID, let oid = fetchOrderID() {
            
            firebase.child("Users").child(uid).child("clientInfo").child("Orders").child(oid).removeValue()
            firebase.child("Orders").child("allOrders").child(oid).removeValue()
        }
    }
    
    /* 
 
    Laundromat rejects order, should be deleted from everywhere
 
    */
    
    func findLaundromat(finished: @escaping (_ success: Bool) -> ()) {
        if let uid = clientID, let oid = fetchOrderID() {
            firebase.child("Cleaners").child("allCleaners").observeSingleEvent(of: .value, with: { (snap) in
               var allLocations = [CLLocation]()
                var allOrders = [String]()
                if let dict = snap.value as? [String: AnyObject] {
                    for cleaner in dict as [String: AnyObject] {
                        if let location = cleaner.value["location"] as? [String: AnyObject] {
                            if let lat = location["latitude"] as? Double, let long = location["longitude"] as? Double {
                                let latitude: CLLocationDegrees = CLLocationDegrees(lat)
                                let longitude: CLLocationDegrees = CLLocationDegrees(long)
                                let newLoc = CLLocation(latitude: latitude, longitude: longitude)
                                let orderID = cleaner.value["orderID"] as! String
                                allOrders.append(orderID)
                                allLocations.append(newLoc)
                            }
                        }
                    }
                }
                let coordinate = self.location!.geoLoc!
                let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let laundromat = self.closestLaundromat(toUserLocation: userLocation, fromList: allLocations, andOrderList: allOrders)
                self.laundromatID = laundromat
                self.moveToOpenOrders()
                finished(true)
            })
        } else { finished(false) }
    }
    
    /*
     Sends order to Laundromat
    */
    
    
    func accept() {
        self.moveToWorkingOrdersBin()
    }
    
    /*
     
     Laundromat accepts order, should be moved to next step in process. This step handles allocating if order will be put into scheduled orders bin or working orders bin (on-demand, to be dealt with immediately).
     
     */
    
    func moveToOpenOrders() {
        if let laundromat = self.laundromatID, let oid = self.fetchOrderID(), let orderJSON = json {
            self.status = OrderStatus.readyForPickup
            firebase.child("Cleaners").child("allCleaners").child(laundromat).child("openOrders").child(oid).setValue(orderJSON.dictionaryObject)
            
        } else { print("Cannot init one of three: laundromat, orderID, json") }
    }
    
    /*
     
     Order moved to the list of the laundromat's unaccepted orders
     
     */
    
    func moveToScheduledOrdersBin() {
        if let laundromat = self.laundromatID, let oid = self.fetchOrderID(), let orderJSON = json {
            firebase.child("Cleaners").child("allCleaners").child(laundromat).child("scheduledOrders").child(oid).setValue(orderJSON.dictionaryObject)
            firebase.child("Cleaners").child("allCleaners").child(laundromat).child("openOrders").child(oid).removeValue()
        } else { print("Cannot init one of three: laundromat, orderID, json") }
    }
    
    /*
    
     Order moved to list of laundromat's scheduled orders, which are checked for their date every time laundromat clicks Refresh or views Scheduled orders bin
    
    */
    
    
    func moveToWorkingOrdersBin() {
        if let laundromat = self.laundromatID, let oid = self.fetchOrderID(), let orderJSON = json {
            firebase.child("Cleaners").child("allCleaners").child(laundromat).child("workingOrders").child(oid).setValue(orderJSON.dictionaryObject)
            firebase.child("Cleaners").child("allCleaners").child(laundromat).child("scheduledOrders").child(oid).removeValue()
        } else { print("Cannot init one of three: laundromat, orderID, json") }
    }
    
    /*
     
     Order moved to the list of the laundromat's orders that they are currently dealing with (accepted on-demand orders, orders they have in-house or waiting for delivery, etc.)
     
     */
    
    func finished() {
        if let laundromat = self.laundromatID, let oid = self.fetchOrderID(), let orderJSON = json {
            self.status = OrderStatus.delivered
            firebase.child("Cleaners").child("allCleaners").child(laundromat).child("finishedOrders").child(oid).setValue(orderJSON.dictionaryObject)
            firebase.child("Cleaners").child("allCleaners").child(laundromat).child("workingOrders").child(oid).removeValue()
        } else { print("Cannot init one of three: laundromat, orderID, json") }
    }
    
    /*
     
     Order moved to the list of the laundromat's completed orders
     
     */
    
    
    // use to get JSON
    
     var json: JSON? {
        get{
            if let vOrderID = self.fetchOrderID(), let vClientID = self.clientID, let vLaundromatID = self.laundromatID, let vIsLaundry = self.isLaundry, let vIsExpress = self.isExpress, let vIsOnDemand = self.isOnDemand, let vSpecialPreferences = self.specialPreferences, let vLocation = self.location, let vOverall = self.review?.overallRating,  let vCustomerService = self.review?.customerServiceRating, let vPickup = self.review?.pickupRating, let vDropoff = self.review?.dropoffRating, let vPricing = self.review?.pricingRating, let vStatus = self.status, let vNumShirts = self.inventory?.numShirts, let vNumPants = self.inventory?.numPants, let vNumJackets = self.inventory?.numJackets, let vNumSuits = self.inventory?.numSuits, let vNumDresses = self.inventory?.numDresses, let vNumTies = self.inventory?.numTies, let vTimes = self.scheduledTimes, let vPrice = self.price {
                if vLocation.infoValid() {
                let json: JSON = [
             //   "orderID": vOrderID,
                "clientID": vClientID,
                "laundromatID": vLaundromatID,
                "isLaundry": vIsLaundry,
                "isExpress": vIsExpress,
                "isOnDemand": vIsOnDemand,
                "specialPreferences": vSpecialPreferences,
                "location": vLocation.json(),
                "rating": [
                    "overall": vOverall,
                    "pricing": vPricing,
                    "pickup": vPickup,
                    "dropoff": vDropoff,
                    "customerService": vCustomerService,
                    ],
                "status": vStatus.simpleDescription(),
                "inventory": [
                    "numShirts": vNumShirts,
                    "numPants": vNumPants,
                    "numSuits": vNumSuits,
                    "numJackets": vNumJackets,
                    "numTies": vNumTies,
                    "numDresses": vNumDresses,
                    ],
                "times": convertedTimes,
                "price": vPrice,
                ]
                
                return json
                } else { return nil }
            } else { return nil } } set {}
    }
    
    /* 
 
    the converted data, structured in JSON, that is used as direct input to the database
 
    */
    
    // Use to find validity
    
    func valid() -> Bool {
    if let vOrderID = self.orderID, let vClientID = self.clientID, let vLaundromatID = self.laundromatID, let vIsLaundry = self.isLaundry, let vIsExpress = self.isExpress, let vIsOnDemand = self.isOnDemand, let vSpecialPreferences = self.specialPreferences, let vLocation = self.location, let vOverall = self.review?.overallRating,  let vCustomerService = self.review?.customerServiceRating, let vPickup = self.review?.pickupRating, let vDropoff = self.review?.dropoffRating, let vPricing = self.review?.pricingRating, let vStatus = self.status, let vNumShirts = self.inventory?.numShirts, let vNumPants = self.inventory?.numPants, let vNumJackets = self.inventory?.numJackets, let vNumSuits = self.inventory?.numSuits, let vNumDresses = self.inventory?.numDresses, let vNumTies = self.inventory?.numTies, let vTimes = self.scheduledTimes, let vPrice = self.price {
        if vLocation.infoValid() {
            return true
        } else { return false }
        } else { return false }
    }
    
    /*
 
    returns the validity of all the order's information
 
    */
 
   private var convertedTimes: JSON? {      // Use this logic to decipher the order time list when pushing to db
        get {
            if let times = scheduledTimes {
            if times.count > 0 {
                var bigJson: JSON = [
                    firebase.childByAutoId().key: times[0],
                    ]
                for time in times {
                    if time != times[0] {
                    bigJson[firebase.childByAutoId().key] = [time]
                    }
                }
                return bigJson
            } else {
                return nil
            }
            } else { return nil }
        }
    }
    
    // Use to retrieve from database
    
    func dbFill(finished: @escaping () -> ()) {      print("Filling order info")
        if let id = orderID {
            firebase.child("Orders").child("allOrders").child(id).observeSingleEvent(of: .value, with: { (snap) in
                
                if let snapDict = snap.value as? [String: AnyObject] {
                    print("Order snapshot: { \n \(snapDict) \n } ")
                    if let laundryBool = snapDict["isLaundry"] as? Bool, let expressBool = snapDict["isExpress"] as? Bool, let specPrefString = snapDict["specialPreferences"] as? String, let onDemandBool = snapDict["isOnDemand"] as? Bool, let clientIDstring = snapDict["clientID"] as? String, let statusString = snapDict["status"] as? String, let laundromatIDstring = snapDict["laundromatID"] as? String, let locationDict = snapDict["location"] as? [String: AnyObject], let reviewDict = snapDict["review"] as? [String: AnyObject], let inventoryDict = snapDict["inventory"] as? [String: AnyObject], let timesDict = snapDict["scheduledTimes"] as? [String: AnyObject], let priceAmount = snapDict["price"] as? Float {
                        
                        
                        // Handle Dictionaries
                        
                        // location
                        if let zip = locationDict["zipCode"] as? String, let state = locationDict["state"] as? String, let city = locationDict["city"] as? String, let streetAddress = locationDict["streetAddress"] as? String, let aptNumber = locationDict["apartmentNumber"] as? String, let latitude = locationDict["latitude"] as? Double, let longitude = locationDict["longitude"] as? Double {
                            let newLocation = HomeAddress(aStreetAddress: streetAddress, aCity: city, aState: state, aZip: zip, aptNumber: aptNumber)
                            let lat: CLLocationDegrees = CLLocationDegrees(latitude);let long: CLLocationDegrees = CLLocationDegrees(longitude)
                            newLocation.geoLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            self.location = newLocation
                        }
                        
                        // Review
                        if let rOverall = reviewDict["overall"] as? Int, let rCusomertService = reviewDict["customerService"] as? Int, let rPickup = reviewDict["pickup"] as? Int, let rDropoff = reviewDict["dropoff"] as? Int, let rPricing = reviewDict["pricing"] as? Int {
                            let oReview = OrderReview(overall: rOverall, pricing: rPricing, pickup: rPickup, dropoff: rDropoff, customerService: rCusomertService)
                            self.review = oReview
                        }
                        
                        // Inventory
                        if let iShirts = inventoryDict["numShirts"] as? Int,  let iPants = inventoryDict["numPants"] as? Int, let iSuits = inventoryDict["numSuits"] as? Int, let iDresses = inventoryDict["numDresses"] as? Int, let iTies = inventoryDict["numTies"] as? Int, let iJackets = inventoryDict["numJackets"] as? Int, let iBagCount = inventoryDict["bagCount"] as? Int  {
                            let oInventory = Inventory()
                            oInventory.bagCount = iBagCount; oInventory.numTies = iTies; oInventory.numPants = iPants; oInventory.numSuits = iSuits; oInventory.numShirts = iShirts; oInventory.numDresses = iDresses; oInventory.numJackets = iJackets;
                            self.inventory = oInventory
                        }
                        
                        // Scheduled Times
                        for child in timesDict as [String: AnyObject] {
                            if let time = child.value as? String { self.scheduledTimes?.append(time) }
                        }
                        
                        // End Handle Dictionaries
                        
                        // Handle Status
                        if statusString == "Ready for Pickup" { self.status = OrderStatus.readyForPickup } else if statusString == "Ready for Delivery" { self.status = OrderStatus.readyForDelivery } else if statusString == "Picked Up" { self.status = OrderStatus.pickedUp } else if statusString == "Delivered" { self.status = OrderStatus.delivered } else if statusString == "Processing" { self.status = OrderStatus.processing }
                        
                        // Fill Remaining Fields
                        
                    self.isLaundry = laundryBool; self.isExpress = expressBool; self.isOnDemand = onDemandBool; self.specialPreferences = specPrefString; self.clientID = clientIDstring; self.laundromatID = laundromatIDstring; self.price = priceAmount;
                    
                    }
                    
                }
                finished()
            })
        }

    }
 
    func closestLaundromat(toUserLocation location: CLLocation,  fromList locations: [CLLocation], andOrderList orderKeys: [String]) -> String? {
        if let closestLocation = locations.min(by: { location.distance(from: $0) < location.distance(from: $1) }) {
            print("closest location: \(closestLocation), distance: \(location.distance(from: closestLocation))")
            let closestIndex = locations.index(of: closestLocation)
            let orderKey = orderKeys[closestIndex!]
            return orderKey
        } else {
            print("coordinates is empty")
            return nil
        }
    }
    
    var onDemandString: String? {
        get {
            if isOnDemand != nil {
            if self.isOnDemand! { return "On Demand" } else { return "Scheduled for: \n\(printableTimes)" }
            } else { return nil }
        }
    }
    var laundryString: String? {
        get {
            if isLaundry != nil {
            if self.isLaundry! { return "Laundry" } else { return "Dry Cleaning" }
            } else { return nil }
        }
    }
    
    var expressString: String? {
        get {
            if isExpress != nil {
            if self.isExpress! { return "Express" } else { return "Standard" }
            } else { return nil }
        }
    }
    
    var printableTimes: String {
    get {
        var t = ""
        if let times = scheduledTimes {
            for time in times {
                t.append("\n")
                t.append(time)
            }
        }
        return t
    }
    }
    
    func orderDescription() -> String{
        if let statusDescription = self.status?.simpleDescription(), let locDescription = location?.userFriendlyDescription(), let inventoryDescription = self.inventory?.simpleDescription(), let total = price, let onDemand = onDemandString, let laundry = laundryString, let express = expressString {
                let d = "Background: \(onDemand)\n\(laundry)\n(express)\n\(statusDescription)\nLocation: \n\(locDescription)\n\(inventoryDescription)\nTotal: \(total)"
            return d
        } else {
            return "Could not find order information!" // Lie, just not all info
        }
    }
    
    func printt() {
        print("Order ID: \(self.fetchOrderID())")
        print("Client ID: \(self.clientID)")
        print("Express: \(self.isExpress)")
        print(self.isOnDemand)
        print("LOCATION VALID: \(self.location?.infoValid())")
        print(self.isLaundry)
        print(self.specialPreferences)
        print(self.review)
        print(self.status)
        print(self.laundromatID)
        print(self.inventory)
        print(self.scheduledTimes)
        print(self.price)
    }
    
}




















