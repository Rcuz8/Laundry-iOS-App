//
//  Organization.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 7/12/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class Organization {
    
//    var id: String?
//    
//    var location: HomeAddress?
//    
//    var washers: [Washer]?
//    
//    var filledOrders: [Order]?
//    
//    var openOrders: [Order]?
//    
//    var ordersProcessing: [Order]?
//    
//    var rating: Double!
//    
//    var geoCoordinate: CLLocation?
//    
//    init(with organizationID: String) {
//        id = organizationID
//        washers = [Washer]()
//        filledOrders = [Order]()
//        ordersProcessing = [Order]()
//        openOrders = [Order]()
//    }
//    
//    func valid() -> Bool{
//        if let tID = id, let tCity = location?.city, let tState = location?.state, let tStreetAddress = location?.streetAddress, let tZip = location?.zip, let tApt = location?.apartmentNumber, let tWashers = washers, let tFilledOrders = filledOrders, let tOpenOrders = openOrders, let tOrdersProcessing = ordersProcessing, let tRating = rating, let tGeoCoordinate = geoCoordinate {
//            return true
//        } else { return false }
//    }
//    
//    func save() {
//        if valid() {
//            firebase.child("Organizations").child("Info").setValue(json())
//        }
//    }
//    
//    func json() -> JSON {
//        if let tID = id, let tCity = location?.city, let tState = location?.state, let tStreetAddress = location?.streetAddress, let tZip = location?.zip, let tApt = location?.apartmentNumber, let tWashers = washers, let tFilledOrders = filledOrders, let tOpenOrders = openOrders, let tOrdersProcessing = ordersProcessing, let tRating = rating, let tGeoCoordinate = geoCoordinate?.coordinate {
//            
//            let jsonData: JSON = [
//                "id": tID,
//                "location": location?.json(),
//                "washers": convertedWashers,
//                "filledOrders": convertedFIlledOrders,
//                "openOrders": convertedOpenOrders,
//                "ordersProcessing": convertedOrdersProcessing,
//                "rating": tRating,
//                "geoCoordinate": [
//                    "longitude": tGeoCoordinate.longitude,
//                    "lattitude": tGeoCoordinate.latitude,
//                ],
//            
//            ]
//            return jsonData
//        } else { return false }
//    }
//    
//    var convertedFIlledOrders: [JSON] {
//        get {
//            var list = [JSON]()
//            if let orderList = filledOrders {
//                for order in orderList {
//                    let id = order.info.orderID!
//                    let info = order.info.toJSON()
//                    let json: JSON = [
//                        id:info,
//                        ]
//                    list.append(json)
//                }
//                return list
//            } else {
//                return list
//            }
//        }
//    }
//    
//    var convertedOrdersProcessing: [JSON] {
//        get {
//            var list = [JSON]()
//            if let orderList = ordersProcessing {
//                for order in orderList {
//                    let id = order.info.orderID!
//                    let info = order.info.toJSON()
//                    let json: JSON = [
//                        id:info,
//                        ]
//                    list.append(json)
//                }
//                return list
//            } else {
//                return list
//            }
//        }
//    }
//    
//    var convertedOpenOrders: [JSON] {
//        get {
//            var list = [JSON]()
//            if let orderList = openOrders {
//                for order in orderList {
//                    let id = order.info.orderID!
//                    let info = order.info.toJSON()
//                    let json: JSON = [
//                        id:info,
//                        ]
//                    list.append(json)
//                }
//                return list
//            } else {
//                return list
//            }
//        }
//    }
//    
//    var convertedWashers: [JSON] {
//        get {
//            var list = [JSON]()
//            if let washerList = washers {
//                for washer in washerList {
//                    let id = washer.id!
//                    let info = washer.json()
//                    let json: JSON = [
//                        id:info,
//                        ]
//                    list.append(json)
//                }
//                return list
//            } else {
//                return list
//            }
//        }
//    }
//    
//    func getDataFromDatabase(finished: @escaping () -> ()) {
//        if let orgID = self.id {
//            firebase.child("Organizations").child(orgID).observeSingleEvent(of: .value, with: { (snap) in
//                
//                if let snapDict = snap.value as? [String: AnyObject] {
//                
//                // Begin Loc
//                if let address = snapDict["location"] as? [String: AnyObject] {
//                    if let zip = address["zipCode"] as? String {
//                        if let state = address["state"] as? String  {
//                            if let city = address["city"] as? String  {
//                                if let streetAddress = address["streetAddress"] as? String  {
//                                    if let aptNumber = address["apartmentNumber"] as? String  {
//                                        print("Org: getInfoFromDatabase: HomeAddress Info good!")
//                                        let newlocation = HomeAddress(aStreetAddress: streetAddress, aCity: city, aState: state, aZip: zip, aptNumber: aptNumber )
//                                        self.location = newlocation
//                                    } else {
//                                        print("Org: getInfoFromDatabase: HomeAddress Info good except for apartment Number!")
//                                        let newLocation = HomeAddress(aStreetAddress: streetAddress, aCity: city, aState: state, aZip: zip, aptNumber: nil )
//                                        self.location = newLocation
//                                    }
//                                } else { print("Error code: 5") }
//                            } else { print("Error code: 4") }
//                        } else { print("Error code: 3") }
//                    } else { print("Error code: 2") }
//                    
//                } else { print("\n\n\n Could not initialize snapDict[\"homeAddress\"] as [String: AnyObject]") }
//                // End Loc
//                
//                    if let dictWashers = snapDict["washers"] as? [String: AnyObject] {
//                        
//                        for washer in dictWashers as [String: AnyObject] {
//                            
//                            let washerID = washer.key
//                            let newWasherObject = Washer(with: washerID)
//                            newWasherObject.getDataFromDatabase() {
//                                self.washers!.append(newWasherObject)
//                            }
//                        }
//                        
//                    }
//                    
//                    if let dictOpenOrders = snapDict["openOrders"] as? [String: AnyObject] {
//                        
//                        for order in dictOpenOrders as [String: AnyObject] {
//                            
//                            let orderID = order.key
//                            let newOrder = ClientOrder(with: orderID)
//                            newOrder.info?.getDataFromDatabase() {
//                                self.openOrders!.append(newOrder)
//                            }
//                        }
//                        
//                    }
//                    
//                    if let dictFilledOrders = snapDict["filledOrders"] as? [String: AnyObject] {
//                        
//                        for order in dictFilledOrders as [String: AnyObject] {
//                            
//                            let orderID = order.key
//                            let newOrder = ClientOrder(with: orderID)
//                            newOrder.info?.getDataFromDatabase() {
//                                self.filledOrders!.append(newOrder)
//                            }
//                        }
//                        
//                    }
//                    
//                    if let dictProcessingOrders = snapDict["processingOrders"] as? [String: AnyObject] {
//                        
//                        for order in dictProcessingOrders as [String: AnyObject] {
//                            
//                            let orderID = order.key
//                            let newOrder = ClientOrder(with: orderID)
//                            newOrder.info?.getDataFromDatabase() {
//                                self.ordersProcessing!.append(newOrder)
//                            }
//                        }
//                        
//                    }
//                    
//                    // Begin geoCoordinate
//                    if let dictGeoCoordinate = snapDict["geoCoordinate"] as? [String: AnyObject] {
//                        if let lattitude = dictGeoCoordinate["lattitude"] as? Double {
//                            if let longitude = dictGeoCoordinate["longitude"] as? Double  {
//                                
//                                let latDegrees: CLLocationDegrees = CLLocationDegrees(lattitude)
//                                let longDegrees: CLLocationDegrees = CLLocationDegrees(longitude)
//                                let coordinate = CLLocation(latitude: latDegrees, longitude: longDegrees)
//                                self.geoCoordinate = coordinate
//                            }
//                        }
//                    }
//                    // End geoCoordinate
//                    
//                    if let dictRating = snapDict["rating"] as? Double {
//                        self.rating = dictRating
//                    }
//                    
//                }
//                finished()
//            })
//        }
//    }
//    
    
}
