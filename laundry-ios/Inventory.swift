//
//  Inventory.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/10/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation

class Inventory {
    
    var numShirts = 0, numDresses = 0, numTies = 0, numJackets = 0, numPants = 0, numSuits = 0, bagCount = 0;
    
    init() {}
    
    func simpleDescription() -> String {
        if bagCount == 0 {
            return "Shirts: \(numShirts) \nDresses: \(numDresses) \nTies: \(numTies) \nJackets: \(numJackets) \nPants: \(numPants) \nSuits: \(numSuits) \n"
        } else { return "Bags: \(bagCount)" }
    }
    
}

