//
//  PaymentViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 5/27/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Stripe
import Alamofire


class PayViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    
    let paymentTextField = STPPaymentCardTextField()
    var custID = ""
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad();
        paymentTextField.frame = CGRect(x: 20, y: 80, width:self.view.frame.width - 40, height: 50)
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        payButtonOutlet.isHidden = false;
        
        
        //change custId depending on new user or not
        custID = "cus_Ah2oASWBOgVJXj"
        
        
        /*
         here you get the user thats currently logged in, and the corresponding customer id on stripe, which is stored in firebase
         then pass that through the request, into the php file, which will determine to create a new id or charge an existing one
         
         */
        
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        
        if(textField.isValid){
            payButtonOutlet.isHidden = false
        }
        
    }
    
    
    @IBOutlet weak var payButtonOutlet: UIButton!
    
    @IBAction func payButtonAction(_ sender: Any) {
        
        let card = paymentTextField.cardParams
        
        STPAPIClient.shared().createToken(withCard: card, completion: {(token, error) -> Void in
            if let error = error {
                print(error)
            }
            else if let token = token {
                print(token)
                self.chargeUsingToken(token: token)
            }
        })
        
        
        
    }
    
    func chargeUsingToken(token:STPToken) {
        let requestString = "https://secret-atoll-43300.herokuapp.com/charge.php"
        let params = ["stripeToken": token.tokenId, "amount": "100", "currency": "usd", "description": "testRunCustomer", "customerID": custID]
        
        _ = Alamofire.request(requestString, method: .post, parameters: params)
    }
    
}


