//
//  LoginVC.swift
//  laundry-ios
//
//  Created by Kevin Lu on 8/9/17.
//  Copyright © 2017 Leo Vigna. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: Buttons
    
    @IBAction func signInButton(_ sender: Any) {
        
    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "NameVC")
    }
    
    @IBAction func signInUsingGoogleButton(_ sender: Any) {
        
    }
    
    @IBAction func signInUsingFacebookButton(_ sender: Any) {
        
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
