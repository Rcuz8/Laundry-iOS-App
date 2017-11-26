//
//  MainAPI.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 11/23/17.
//  Copyright © 2017 Lavo Logistics. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class MainAPI:NSObject, STPEphemeralKeyProvider {
    
 //   override init(){}
    
    static let shared = MainAPI()
    
    var baseURLString = Constants.BASE_URL
    
    // MARK: STPEphemeralKeyProvider
    
    enum CustomerKeyError: Error {
        case missingBaseURL
        case invalidResponse
    }
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURLString.appending("ephemeral_keys")//.appendingPathComponent("ephemeral_keys")
        Alamofire.request(url, method: .post, parameters: [
            "api_version": apiVersion
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
  
    
}
