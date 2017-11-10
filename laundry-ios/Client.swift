//
//  Client.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 5/16/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON
import CoreLocation

protocol ClientOrderChecking {
    func update(with order: Order)
}

class bSource {
    var sourceID: String, last4digits: String?, email: String?
    init(_ id: String) {
    sourceID = id
    }
}


class Client {
    
    var id: String?
    
    var email: String? // use changeEmail, needs to be done through FIRAuth & database
    
    var firstName: String?
    
    var lastName: String?
    
    var phoneNumber: String?
    
    var homeAddress: HomeAddress?
    
    var savedLocations: [(name: String, location: HomeAddress)]? // (Name, Location)
    
    var savedOrderingPreferences: [(name: String, preferences: String)]? // (Name, Order Preferences)
    
    var orders: [Order]?
    
    var profilePicture: UIImage?
    
    var stripeToken: String? // not included in JSON representation
    
    func valid() -> Bool {
        if let cId = self.id, let cEmail = self.email, let cFirstName = self.firstName, let cLastName = self.lastName, let cPhoneNumber = self.phoneNumber, savedLocations != nil, homeAddress != nil, homeAddress!.infoValid(), savedOrderingPreferences != nil, orders != nil {
                return true
        } else { return false }
    }
    
    func simpleDescription() -> String {
        return "Client Description: { \n id: \(id) \n email: \(email) \n first name: \(firstName) \n last name: \(lastName) \n phone number: \(phoneNumber) \n Home Address: \n \(homeAddress?.simpleDescription()) \n orders: \(orders) \n saved ordering preferences: \(savedOrderingPreferences) \n saved locations: \(savedLocations) \n } "
    }
    
    init() {
        savedLocations = [(name: String, location: HomeAddress)]()
        savedOrderingPreferences = [(name: String, preferences: String)]()
        orders = [Order]()
    }
    
    init(id clientID: String) {
        self.id = clientID
        savedLocations = [(name: String, location: HomeAddress)]()
        savedOrderingPreferences = [(name: String, preferences: String)]()
        orders = [Order]()
    }

    private var convertedSavedLocations: JSON? {
        get {
            if savedLocations!.count > 0 {
                var bigJson: JSON = [
                    savedLocations![0].name: savedLocations![0].location.json(),
                    ]
                for location in savedLocations! {
                    bigJson[location.name] = location.location.json()!
                }
                return bigJson
            } else {
                return nil
            }
            

        }
    }
    
    private var convertedOrderingPreferences: JSON? {
        get {
                if savedOrderingPreferences!.count > 0 {
                    var bigJson: JSON = [
                        savedOrderingPreferences![0].name: savedOrderingPreferences![0].preferences,
                        ]
                    for pref in savedOrderingPreferences! {
                        bigJson[pref.name] = [pref.preferences]
                    }
                    return bigJson
                } else {
                    return nil
                }
            
        }
    }
    
    
    private var convertedOrders: JSON? {
        get {
            
            if orders!.count > 0 {
                var bigJson: JSON = [
                    orders![0].orderID!: orders![0].json,
                    ]
                for order in orders! {
                    bigJson[order.orderID!] = [order.json]
                }
                return bigJson
            } else {
                return nil
            }

        }
    }
    
    var orderUpdater: ClientOrderChecking?
    
    func dbFill(finished: @escaping ()->()) {
        if let clientId = id {
            print(0)
            FIRDatabase.database().reference().child("Users").child(clientId).child("clientInfo").observeSingleEvent(of: .value, with: { (userSnap) in
                print(1)
                if let userDict = userSnap.value as? [String: AnyObject] {
                    print(2)
                    print(userDict["email"] as? String);print(userDict["firstName"] as? String);print(userDict["lastName"] as? String);print(userDict["phoneNumber"] as? String);print(userDict["homeAddress"] as? [String: AnyObject]);
                    if let uEmail = userDict["email"] as? String { self.email = uEmail };
                    if let uFirstName = userDict["firstName"] as? String { self.firstName = uFirstName }
                    if let uLastName = userDict["lastName"] as? String { self.lastName = uLastName }
                    if let uPhoneNumber = userDict["phoneNumber"] as? String { self.phoneNumber = uPhoneNumber }
                    if let addressDict = userDict["homeAddress"] as? [String: AnyObject] {
                        if let zip = addressDict["zipCode"] as? String, let state = addressDict["state"] as? String, let city = addressDict["city"] as? String, let streetAddress = addressDict["streetAddress"] as? String, let aptNumber = addressDict["apartmentNumber"] as? String, let latitude = addressDict["latitude"] as? Double, let longitude = addressDict["longitude"] as? Double {
                            let newAddress = HomeAddress(aStreetAddress: streetAddress, aCity: city, aState: state, aZip: zip, aptNumber: aptNumber)
                            let lat: CLLocationDegrees = CLLocationDegrees(latitude);let long: CLLocationDegrees = CLLocationDegrees(longitude)
                            newAddress.geoLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            self.homeAddress = newAddress;   }}
                    if let prefDict = userDict["savedOrderingPreferences"] as? [String: AnyObject] { print(9)
                        print(prefDict)
                            for child in prefDict as [String: AnyObject] {
                                print(10)
                                print(child)
                                if let preference = child.value as? [String] {
                                    print(121)
                                    let preferenceName = child.key
                                    let newSavedOrderPreference: (String, String) = (preferenceName, preference[0] as! String)
                                    self.savedOrderingPreferences?.append(newSavedOrderPreference);   }
                        }}
                    
                    if let locDict = userDict["savedLocations"] as? [String: AnyObject] {
                        print("init savedLocations")
                        for child in locDict as [String: AnyObject] {
                            print()
                            print("savedLocations child x")
                            print(child.value["streetAddress"] as? String)
                            print(locDict["zipCode"] as? String)
                            print(locDict["city"] as? String)
                            print(locDict["state"] as? String)
                            print(locDict["apartmentNumber"] as? String)
                            print(locDict["latitude"] as? Double)
                            print(locDict["longitude"] as? Double)
                            print()
                            if let zip = child.value["zipCode"] as? String, let state = child.value["state"] as? String, let city = child.value["city"] as? String, let streetAddress = child.value["streetAddress"] as? String, let aptNumber = child.value["apartmentNumber"] as? String, let latitude = child.value["latitude"] as? Double, let longitude = child.value["longitude"] as? Double {
                                print("initialized everything")
                                    let newLocation = HomeAddress(aStreetAddress: streetAddress, aCity: city, aState: state, aZip: zip, aptNumber: aptNumber)
                                    let lat: CLLocationDegrees = CLLocationDegrees(latitude);let long: CLLocationDegrees = CLLocationDegrees(longitude)
                                    newLocation.geoLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                    let newLocationName = child.key
                                    let newSavedLocation: (String, HomeAddress) = (newLocationName, newLocation)
                                self.savedLocations?.append(newSavedLocation);   } else {
                               print("did not initialize all savedlocations")
                            }
                            
                        }}
                        if let orderDict = userDict["Orders"] as? [String: AnyObject] {
                            for child in orderDict as [String: AnyObject] {
                                print("Found order: \(child.key)")
                                let orderId = child.key
                                let order = Order(id: orderId, onDataRetreieved: {})
                                order.dbFill {
                                    print("dbFill callback, Appending order")
                                    self.orders!.append(order)
                                    print("With order appended, orders now contains \(self.orders!.count) elements")
                                    self.orderUpdater?.update(with: order)
                                }
                            }
                        }
                        print(self.simpleDescription())
                    
                    print("finishing dbFill, all data should be in");
                    finished()
                } else { finished() } })
        } else { finished() }
    }
    
    func dbFill2(finished: @escaping ()->()) {
        if let clientId = id {
            print(0)
            FIRDatabase.database().reference().child("Users").child(clientId).child("clientInfo").observeSingleEvent(of: .value, with: { (userSnap) in
                print(1)
                if let userDict = userSnap.value as? [String: AnyObject] {
                    print(2)
                    print(userDict["email"] as? String);print(userDict["firstName"] as? String);print(userDict["lastName"] as? String);print(userDict["phoneNumber"] as? String);print(userDict["homeAddress"] as? [String: AnyObject]);
                    if let uEmail = userDict["email"] as? String { self.email = uEmail };
                    if let uFirstName = userDict["firstName"] as? String { self.firstName = uFirstName }
                    if let uLastName = userDict["lastName"] as? String { self.lastName = uLastName }
                    if let uPhoneNumber = userDict["phoneNumber"] as? String { self.phoneNumber = uPhoneNumber }
                    if let addressDict = userDict["homeAddress"] as? [String: AnyObject] {
                        if let zip = addressDict["zipCode"] as? String, let state = addressDict["state"] as? String, let city = addressDict["city"] as? String, let streetAddress = addressDict["streetAddress"] as? String, let aptNumber = addressDict["apartmentNumber"] as? String, let latitude = addressDict["latitude"] as? Double, let longitude = addressDict["longitude"] as? Double {
                            let newAddress = HomeAddress(aStreetAddress: streetAddress, aCity: city, aState: state, aZip: zip, aptNumber: aptNumber)
                            let lat: CLLocationDegrees = CLLocationDegrees(latitude);let long: CLLocationDegrees = CLLocationDegrees(longitude)
                            newAddress.geoLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            self.homeAddress = newAddress;   }}
                    if let prefDict = userDict["savedOrderingPreferences"] as? [String: AnyObject] { print(9)
                        print(prefDict)
                        for child in prefDict as [String: AnyObject] {
                            print(10)
                            print(child)
                            if let preference = child.value as? [String] {
                                print(121)
                                let preferenceName = child.key
                                let newSavedOrderPreference: (String, String) = (preferenceName, preference[0] as! String)
                                self.savedOrderingPreferences?.append(newSavedOrderPreference);   }
                        }}
                    
                    if let locDict = userDict["savedLocations"] as? [String: AnyObject] {
                        print("init savedLocations")
                        for child in locDict as [String: AnyObject] {
                            print()
                            print("savedLocations child x")
                            print(child.value["streetAddress"] as? String)
                            print(locDict["zipCode"] as? String)
                            print(locDict["city"] as? String)
                            print(locDict["state"] as? String)
                            print(locDict["apartmentNumber"] as? String)
                            print(locDict["latitude"] as? Double)
                            print(locDict["longitude"] as? Double)
                            print()
                            if let zip = child.value["zipCode"] as? String, let state = child.value["state"] as? String, let city = child.value["city"] as? String, let streetAddress = child.value["streetAddress"] as? String, let aptNumber = child.value["apartmentNumber"] as? String, let latitude = child.value["latitude"] as? Double, let longitude = child.value["longitude"] as? Double {
                                print("initialized everything")
                                let newLocation = HomeAddress(aStreetAddress: streetAddress, aCity: city, aState: state, aZip: zip, aptNumber: aptNumber)
                                let lat: CLLocationDegrees = CLLocationDegrees(latitude);let long: CLLocationDegrees = CLLocationDegrees(longitude)
                                newLocation.geoLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                let newLocationName = child.key
                                let newSavedLocation: (String, HomeAddress) = (newLocationName, newLocation)
                                self.savedLocations?.append(newSavedLocation);   } else {
                                print("did not initialize all savedlocations")
                            }
                            
                        }}
                    if let orderDict = userDict["Orders"] as? [String: AnyObject] {
                        for child in orderDict as [String: AnyObject] {
                            print("Found order: \(child.key)")
                            let orderId = child.key
                            let order = Order(id: orderId, onDataRetreieved: {})
                            order.dbFill {
                                print("dbFill callback, Appending order")
                                self.orders!.append(order)
                                print("With order appended, orders now contains \(self.orders!.count) elements")
                                self.orderUpdater?.update(with: order)
                            }
                        }
                    }
                    print(self.simpleDescription())
                    
                    print("finishing dbFill, all data should be in");
                    finished()
                } else { finished() } })
        } else { finished() }
    }
    
    var json: JSON? {
        get{
            if let cId = self.id, let cEmail = self.email, let cFirstName = self.firstName, let cLastName = self.lastName, let cPhoneNumber = self.phoneNumber, let cOrders = orders, let address = homeAddress {
                if address.infoValid() {
                let jsonData: JSON = [
                    "id": cId,
                    "email": cEmail,
                    "firstName": cFirstName,
                    "lastName": cLastName,
                    "homeAddress": homeAddress!.json()!.dictionaryObject,
                    "phoneNumber":cPhoneNumber,
                    "savedOrderingPreferences": convertedOrderingPreferences,
                    "savedLocations": convertedSavedLocations,
                    "orders": convertedOrders,
                ]
                    return jsonData
                    
                } else { return nil }
            } else { return nil } }
    }
    
    var printableJSON: JSON? {
        get{
                    let jsonData: JSON = [
                        "id": self.id,
                        "email": self.email,
                        "firstName": self.firstName,
                        "lastName": self.lastName,
                        "homeAddress": homeAddress?.json(),
                        "savedOrderPreferences": convertedOrderingPreferences,
                        "savedLocations": convertedSavedLocations,
                        "orders": convertedOrders,
                        ]
                    return jsonData
                }
    }
    
    func changeEmail(to newEmail: String, finished: @escaping (_ success: Bool) -> ()) {
        if let cID = id {
        FIRAuth.auth()?.currentUser?.updateEmail(newEmail, completion: { (error) in
            if error != nil {
                finished(false)
            } else {
                firebase.child("Users").child(cID).child("clientInfo").child("email").setValue(newEmail)
                finished(true)
            }
        })
        } else { finished(false) }
    }
    
    func saveOnlyOrderPreferences(finished: @escaping (_ success: Bool) -> ()) {
        if let uid = self.id, savedOrderingPreferences != nil {
            firebase.child("Users").child(uid).child("clientInfo").child("savedOrderingPreferences").setValue(convertedOrderingPreferences?.dictionaryObject)
            finished(true)
        } else { finished(false) }
    }
    
    func saveOnlyLocations(finished: @escaping (_ success: Bool) -> ()) {
        if let uid = self.id, savedOrderingPreferences != nil {
            firebase.child("Users").child(uid).child("clientInfo").child("savedLocations").setValue(convertedSavedLocations?.dictionaryObject)
            finished(true)
        } else { finished(false) }
    }
    
    func createClientCredentials(withPassword password: String, finished: @escaping (_ success: Bool, _ user: FIRUser?) -> ()) {
            FIRAuth.auth()?.createUser(withEmail: self.email!, password: password, completion: { (fUser: FIRUser?, error) in
                if error != nil { finished(false, nil) } else { finished(true, fUser) }
        })
    }
    
    func save(finished: @escaping (_ success: Bool) -> ()) {
        if let cID = self.id {
            firebase.child("Users").child(cID).child("clientInfo").setValue(json?.dictionaryObject)
        finished(true)
        } else { finished(false) }
    }
    
    // Profile Picture stuff
    
    private let firebaseImages = FIRStorage.storage().reference().child("Images")
    
    func getClientPicture(finished: @escaping (_ success: Bool,_ picture: UIImage?) -> ()) {
        if let userId = id {
            
            print("Client: getClientPicture: ✅ FIRUser found!")
            
   //         firebase.child("Users").child(userId).child("images").observeSingleEvent(of: .value, with: { (snap: FIRDataSnapshot) in
   //             print("Client: getClientPicture: User Info Database snapshot found. Testing as [String:AnyObject] . . .")
                
                    // Image
                    let userPhotoLocation = self.firebaseImages.child("Users").child(userId).child("profilePicture.jpg")
                    
                    userPhotoLocation.downloadURL { url, error in
                        print("Client: getClientPicture:  downloadURL callback . . .")
                        if let error = error {
                            // Handle any errors
                            finished(false, nil)
                        } else {
                            
                            let downloadString = "\(url!)"
                            self.ryanSimpleDownloadGetImage(withURLstring: downloadString, finished: { (success, image) in
                                if success {
                                    print("getClientPicture: successful downlaod!!!")
                                } else {
                                    print("getClientPicture: UNsuccessful downlaod!!!")
                                }
                                finished(success, image)
                                
                            })
                            
                        }}
                
   //         })
        } else {
            print("Exit 1")
            finished(false, nil)
        }
    }
    
    func ryanSimpleDownload(withURLstring string: String, finished: @escaping (_ success: Bool) -> ()) {
        
        if let url = URL(string: string) {
            let data: Data = NSData(contentsOf: url) as! Data
            if let image = UIImage(data: data) {
                profilePicture = image
                finished(true)
            } else {
                print("RyanSimpleDownload: can't create image")
                finished(false)
            }
        } else {
            print("RyanSimpleDownload: can't create URL")
            finished(false)
        }
        
    }
    
    func ryanSimpleDownloadGetImage(withURLstring string: String, finished: @escaping (_ success: Bool, _ image: UIImage?) -> ()) {
        
        if let url = URL(string: string) {
            let data: Data = NSData(contentsOf: url) as! Data
            if let image = UIImage(data: data) {
                profilePicture = image
                finished(true, image)
            } else {
                print("RyanSimpleDownload: can't create image")
                finished(false, nil)
            }
        } else {
            print("RyanSimpleDownload: can't create URL")
            finished(false, nil)
        }
        
    }
    
    func storeProfilePic() {
        if let userId = self.id {
            let userPhotoLocation = self.firebaseImages.child("Users").child(userId).child("profilePicture.jpg")
            if let picture = profilePicture {

            if let data = UIImagePNGRepresentation(picture) as Data? {
                let uploadTask = userPhotoLocation.put(data, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        print("ClientInfo: storeProfilePict: ❌ Error Uploading Image") // Error
                        return
                    }
                    
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata.downloadURL()
                    let downloadURLstring = downloadURL?.absoluteString
                    firebase.child("Users").child(userId).child("Images").child("profilePicture").child("downloadURL").setValue(downloadURLstring)
                    print("ClientInfo: storeProfilePic:  Expected behavior -> storing downloadURL String . . .")
                    
                }
            } else {
                print("❌❌❌ Could not initialize Data")
                print(profilePicture.debugDescription)
            }
            }
        }
    }
    
    
    /// Stores Stripe token variable into database
    ///
    /// - Parameter finished: Upon completion, this callback method will execute specifying the success of saving the token.
    func storeStripeToken(finished: @escaping (_ success: Bool) -> ()) {
        if let token = stripeToken, let uid = self.id { // good
            firebase.child("Users").child(uid).child("paymentInfo").child("stripeToken").setValue(token)
            finished(true)
        } else { // no stripe token or uid
            finished(false)
        }
    }
    
    func getStripeToken(finished: @escaping (_ token: String?) -> ()) {
        if let uid = self.id { // good
        firebase.child("Users").child(uid).child("paymentInfo").observeSingleEvent(of: .value, with: { (snap) in
            if let value = snap.value as? [String: AnyObject] {
                if let token = value["stripeToken"] as? String {
                    finished(token)
                } else { finished(nil) }
            } else { finished(nil) }
            
        })
    } else { finished(nil) }
    }
    
    
    // [ source ID --> 
    //       Last 4 digits (card)
    //       Email (paypal)
    // ]
    //
    //
    
    
    
    func storeStripeSource(withID sourceID: String, last4digits: String?, email: String?, finished: @escaping (_ success: Bool) -> ()) {
        if let uid = self.id { // good
            if let last4 = last4digits {
                let sourceObject = [ "last4digits": last4,
                                                      "email": nil, ]
                firebase.child("Users").child(uid).child("paymentInfo").child("stripeSources").child(sourceID).setValue(sourceObject)
                finished(true)
            } else if let sEmail = email {
                let sourceObject = [ "last4digits": nil,
                                                           "email": sEmail, ]
                firebase.child("Users").child(uid).child("paymentInfo").child("stripeSources").child(sourceID).setValue(sourceObject)
                finished(true)
            } else {
                finished(false)
            }
            
            
        } else { // no stripe token or uid
            finished(false)
        }
    }

    func getStripeSources(finished: @escaping (_ sources: [bSource]?) -> ()) {
        var sources = [bSource]()
        if let uid = self.id { // good
            firebase.child("Users").child(uid).child("paymentInfo").child("stripeSources").observeSingleEvent(of: .value, with: { (snap) in
                if let value = snap.value as? [String: AnyObject] {
                    for child in value {
                        let sourceID = child.key
                        let source = bSource(sourceID)
                        if let email = child.value["email"] as? String {
                            source.email = email
                            sources.append(source)
                        } else if let last4 = child.value["last4digits"] as? String {
                            source.last4digits = last4
                            sources.append(source)
                        }
                    }
                    finished(sources)
                } else { finished(nil) }
                
            })
        } else { finished(nil) }
    }
    
    
}

























