//
//  MainAPI.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 11/23/17.
//  Copyright © 2017 Lavo Logistics. All rights reserved.
//

import Foundation
import Stripe
import Firebase
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

        // the request
        
        func request(id: String) {
            print("creating a eph key request with customerId: \(id)")
            let url = Constants.EPHEMERAL_URL
            
            Alamofire.request(url, method: .post, parameters: [
                "api_version": apiVersion,
                "customerId": id
                ])
                .validate(statusCode: 200..<300)
                .responseJSON { responseJSON in
                    
                    switch responseJSON.result {
                    case .success(let json):
                        print("created customer ephemeral key!")
                        completion(json as? [String: AnyObject], nil)
                    case .failure(let error):
                        print("could not customer ephemeral key!\n Error info: ")
                        print(error.localizedDescription)
                        completion(nil, error)
                        
                    }
                    
            }
        }
        
        
        print("attempting to create customer ephemeral key . . .(createCustomerKey())")
        
        if let id = FIRAuth.auth()?.currentUser?.uid {
            Client(id: id).getStripeCustomerId(finished: { (customerIdOpt) in
                if let customerId = customerIdOpt {
                    request(id: customerId)
                } else {
                    print("Couldn't find id")
                }
            })
            
        }
        
    }
  
    
}

extension UIAlertController {
    
    /// Initialize an alert view titled "Oops" with `message` and single "OK" action with no handler
    convenience init(message: String?) {
        self.init(title: "Oops", message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)
        addAction(dismissAction)
        
        preferredAction = dismissAction
    }
    
    /// Initialize an alert view titled "Oops" with `message` and "Retry" / "Skip" actions
    convenience init(message: String?, retryHandler: @escaping (UIAlertAction) -> Void) {
        self.init(title: "Oops", message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: retryHandler)
        addAction(retryAction)
        
        let skipAction = UIAlertAction(title: "Skip", style: .default)
        addAction(skipAction)
        
        preferredAction = skipAction
    }
    
}


