//
//  Cleaner.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/10/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON
import CoreLocation
class Cleaner {
    
    var id: String?
    
    var location: CLLocation?
    
    var finishedOrders: [Order]?
    
    var workingOrders: [Order]?
    
    var openOrders: [Order]?
    
    var customers: [(firstName: String, lastName: String, email: String, phoneNumber: String)]?
    
    var phoneNumber: String?
    
    var email: String?
    
    
    init() {
        
    }
    
    init(with id: String) {
        self.id = id
    }
    
    func dbFill(finished: @escaping (_ valid: Bool) -> ()) {
        
    }
    
    func findPromotions() {}
    
    
}
