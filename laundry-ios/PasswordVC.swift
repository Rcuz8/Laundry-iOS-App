//
//  PasswordVC.swift
//  laundry-ios
//
//  Created by Kevin Lu on 8/9/17.
//  Copyright © 2017 Leo Vigna. All rights reserved.
//

import UIKit

class PasswordVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var passworldField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    // MARK: Buttons
    
    @IBAction func backButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "AddressVC")
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "PaymentVC")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
