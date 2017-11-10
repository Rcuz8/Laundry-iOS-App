//
//  Washer.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 7/12/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class Washer {
//    
//    var isActive: Bool?
//    
//    var id: String?
//    
//    var organizationID: String?
//    
//    var pastTrips: [Trip]?
//    
//    
//     init() {
//        id = FIRAuth.auth()?.currentUser?.uid
//        pastTrips = [Trip]()
//        
//    }
//    
//    init(with washerID: String) {
//        id = washerID
//        pastTrips = [Trip]()
//    }
//    
//    func valid() -> Bool {
//        if let active = isActive, let uid = id, let orgID = organizationID, let trips = pastTrips {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func json() -> JSON? {
//        if let active = isActive, let uid = id, let orgID = organizationID, let trips = pastTrips {
//            let jsonData: JSON = [
//            
//                "isActive": isActive,
//                "id": id,
//                "organizationID": organizationID,
//                "pastTrips": convertedPastTrips,
//            
//            ]
//            
//            return jsonData
//        } else {
//            return nil
//        }
//        return nil
//    }
//    
//    var convertedPastTrips: [JSON] {
//        get {
//            var list = [JSON]()
//            if let tripList = pastTrips {
//                for trip in tripList {
//                    let id = trip.tripID!
//                    let info = trip.json()
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
//    func save() {
//        if valid() {
//        if let id = FIRAuth.auth()?.currentUser?.uid {
//            firebase.child("Washers").child(id).child("Info").setValue(json())
//            firebase.child("Organizations").child(organizationID!).child("Washers").child(id).setValue(json())
//        }
//        }
//    }
//    
//    func updateTripStatus() { // to users & employers
//        
//    }
//    
//    func getDataFromDatabase(finished: @escaping () -> ()) {
//        if let wID = id {
//         firebase.child("Washers").child(wID).observeSingleEvent(of: .value, with: { (snap) in
//            
//            if let snapDict = snap.value as? [String: AnyObject] {
//                
//                if let active = snapDict["active"] as? Bool {
//                    self.isActive = active
//                    
//                }
//                
//                if let orgID = snapDict["organizationID"] as? String {
//                    self.organizationID = orgID
//                    
//                }
//                
//                
//                if let trips = snapDict["pastTrips"] as? [String: AnyObject] {
//                    for trip in trips as [String: AnyObject] {
//                        
//                       let tripID = trip.key
//                        let newTripObject = Trip(with: tripID)
//                        newTripObject.getInfoFromDatabase {
//                            self.pastTrips!.append(newTripObject)
//                        }
//                        
//                        
//                    }
//                }
//                
//                
//                
//                
//            }
//            finished()
//         })
//        }
//    }
//    
//    
}
