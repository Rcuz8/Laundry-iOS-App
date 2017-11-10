//
//  PageViewCounter.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/11/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation
import Firebase
class PageViewCounter {
    
    var clientID: String!
    
    init(clientId: String) {
        self.clientID = clientId
    }
    
    func viewed(viewController: String) {
        if let id = clientID {
            firebase.child("Users").child(id).child("pageViewCounter").observeSingleEvent(of: .value, with: { (pageViewShot) in
                if let pageViewDict = pageViewShot.value as? [String: AnyObject] { // Exists, update by 1
                    if let count = pageViewDict["\(viewController)"] as? Int {
                        var mutableCount = count; mutableCount += 1;
                        firebase.child("Users").child(id).child("pageViewCounter").child(viewController).setValue(mutableCount)
                    } else {
                        firebase.child("Users").child(id).child("pageViewCounter").child(viewController).setValue(0)
                    }
                } else { // Does not exist yet
                    firebase.child("Users").child(id).child("pageViewCounter").child(viewController).setValue(0)
                }
            })
        }
    }
    
}
