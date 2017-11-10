//
//  OrderReview.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/10/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation

class OrderReview {
    
    var overallRating = 0, pricingRating = 0, pickupRating = 0, dropoffRating = 0, customerServiceRating = 0;
    
    init(overall: Int, pricing: Int, pickup: Int, dropoff: Int, customerService: Int) {
        overallRating = overall; pricingRating = pricing; pickupRating = pickup; dropoffRating = dropoff; customerServiceRating = customerService;
    }
    
    init() {}
    
}
