//
//  SimplePay.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 11/21/17.
//  Copyright © 2017 Lavo Logistics. All rights reserved.
//

import Foundation
import PromiseKit
import Stripe
import Alamofire

extension String: Error {}

struct API {
    static func postNewCustomer(email: String) -> Promise<Dictionary<String,Any>> {
        print("Posting new account...")
        let params:Parameters = ["email":email]
        return Network.post(url: "/api/new_customer", parameters: params)
    }
    static func postNewCard(customerId: String,token:STPToken) -> Promise<Dictionary<String,Any>> {
        print("Posting new card...")
        let params:Parameters = ["customerId":customerId, "token":token.tokenId]
        return Network.post(url: "/api/new_card", parameters: params)
    }
    static func postCharge(customerId: String, amount: Int) -> Promise<Dictionary<String,Any>> {
        print("Posting new charge...")
        let params:Parameters = ["customerId":customerId, "amount": amount]
        return Network.post(url: "/api/new_charge", parameters: params)
    }
    
    static func createCharge(customerId: String, amount: Int, source: String) -> Promise<Dictionary<String,Any>> {
        print("Posting new charge...")
        let params:Parameters = ["customerId":customerId, "amount": amount, "source": source]
        return Network.post(url: "/api/new_charge", parameters: params)
    }
}


struct Constants {
    static let STRIPE_KEY = "pk_test_lg4KhXtxw5kCceuSCGEz2k8M"
    static let BASE_URL = "http://localhost:1337" //"https://api.myapp.com" // Heroku Generated Link that
}

struct Network {
    
    ///Base App API url.
    static let BASE_URL = Constants.BASE_URL
    
    /**
     HTTP GET request to App API.
     
     - parameter url: The API endpoint.
     - returns: A Promise with the formatted JSON respones.
     
     */
    static func get(url:String) -> Promise<Dictionary<String,Any>> {
        
        return Promise {fulfill, reject in
            let full_url =  BASE_URL + url
            let headers: HTTPHeaders = [
                "Accept": "application/json"
            ]
            Alamofire.request(full_url, method: .get, headers: headers).responseJSON { response in
                if let JSON = response.result.value as? Dictionary<String,Any> {
                    print("JSON response received")
                    fulfill(JSON)
                }
                else {
                    print("No JSON response")
                    reject("No JSON response")
                }
            }
        }
    }
    
    /**
     HTTP POST request to App API.
     
     - parameter url: The API endpoint.
     - parameter parameters: The request parmeters.
     - returns: A Promise with the formatted JSON response.
     
     */
    static func post(url:String,parameters:Parameters?=nil) -> Promise<Dictionary<String,Any>> {
        return Promise {fulfill, reject in
            let full_url = BASE_URL + url
            let headers: HTTPHeaders = [
                "Accept": "application/json"
            ]
            Alamofire.request(full_url, method: .post, parameters:parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if let JSON = response.result.value as? Dictionary<String,Any>, response.response?.statusCode == 200 {
                    print("JSON Succesful response received")
                    fulfill(JSON)
                }
                else {
                    print("Http Error: No JSON response")
                    print(response)
                    reject("Http Error: No JSON response")
                }
            }
        }
    }
}

