//
//  mPromotionsViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit

class mPromotionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavController()
        self.menuButton.tintColor = UIColor.lavoLightGray
    }
    
    
    @IBOutlet weak var menuButton: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggle(_ sender: Any) {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = 200
            self.revealViewController().revealToggle(animated: true)
        }
    }

}
