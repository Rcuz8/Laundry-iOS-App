//
//  OrderStatus.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/10/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation

enum OrderStatus {
    
    case readyForPickup, pickedUp, processing, readyForDelivery, delivered;
    
    func simpleDescription() -> String {
        switch self {
        case .readyForPickup:
            return "Ready for Pickup"
        case .processing:
            return "Processing"
        case .pickedUp:
            return "Picked Up"
        case .readyForDelivery:
            return "Ready for Delivery"
        case .delivered:
            return "Delivered"
        default:
            return "Status not available"
        }
    }
    
}
