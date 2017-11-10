//
//  NameVC.swift
//  laundry-ios
//
//  Created by Kevin Lu on 8/9/17.
//  Copyright © 2017 Leo Vigna. All rights reserved.
//

import UIKit

class NameVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    // MARK: Buttons
    
    @IBAction func backButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "LoginVC")
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "AddressVC")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
