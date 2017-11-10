//
//  PaymentVC.swift
//  laundry-ios
//
//  Created by Kevin Lu on 8/9/17.
//  Copyright © 2017 Leo Vigna. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var paymentTableView: UITableView!
    
    // MARK: Buttons
    
    @IBAction func backButton(_ sender: Any) {
        goTo(storyboardName: "Auth", viewControllerName: "PasswordVC")
    }
    
    @IBAction func forwardButton(_ sender: Any) {
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
