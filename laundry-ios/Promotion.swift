//
//  Promotion.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/12/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

//import Foundation
//import Firebase
//import SwiftyJSON
//enum PromoType { case percentage, dollarAmount; var descr: String { get{ switch self { case .percentage: return "percentage" case .dollarAmount: return "dollarAmount" } } } }
//
//class Promotion {
//    
//    var id: String?
//    
//    var type: PromoType?
//    
//    var amount: Float?
//    
//    init(id pID: String, type pType: PromoType, amount pAmount: Float) {
//        self.id = pID; self.type = pType; self.amount = pAmount;
//    }
//    
//    init() {
//        
//    }
//    
//    var json: JSON? {
//        if valid() {
//            let jsonData: JSON = [
//            "id": self.id!,
//            "type": type?.descr,
//            "amount": amount,
//            ]
//        return jsonData
//        } else { return nil }
//    }
//    
//    func valid() -> Bool { if let pID = self.id, let pType = self.type, let pAmount = self.amount { return true } else { return false } }
//    
//    
//    
//}
