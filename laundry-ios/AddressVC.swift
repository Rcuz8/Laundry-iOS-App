//
//  AddressVC.swift
//  laundry-ios
//
//  Created by Kevin Lu on 8/9/17.
//  Copyright © 2017 Leo Vigna. All rights reserved.
//

import UIKit

class AddressVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneNoField: UITextField!
    
    @IBOutlet weak var addressSelectionLabel: UILabel!
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var zipcodeField: UITextField!
    @IBOutlet weak var aptNoField: UITextField!
    
    @IBOutlet weak var statePicker: UIPickerView!
    
    // MARK: Buttons
    
    @IBAction func backButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "NameVC")
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "PasswordVC")
    }
    
    @IBAction func addressSelectionButton(_ sender: Any) {
        
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
