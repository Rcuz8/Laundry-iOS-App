//
//  mSettingsViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView


class mSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavController()
        self.menuButton.tintColor = UIColor.lavoLightGray
//        self.adminView.layer.borderColor = UIColor.lavoLightBlue.cgColor
//        self.adminView.layer.borderWidth = 3
//        self.adminView.roundCorners(.allCorners, radius: 8)
//        self.accountView.layer.borderColor = UIColor.lavoLightBlue.cgColor
//        self.accountView.layer.borderWidth = 3
//        self.accountView.roundCorners(.allCorners, radius: 8)
        self.privacyPolicyB.roundCorners(.allCorners, radius: 6)
        self.termsB.roundCorners(.allCorners, radius: 6)
        self.supportB.roundCorners(.allCorners, radius: 6)
        self.logoutB.roundCorners(.allCorners, radius: 6)
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

    @IBAction func showSupport(_ sender: Any) {
        SCLAlertView().showInfo("Support", subTitle: "You may reach us for support by sending us an email at support@GetLavo.com. We appreciate your patience!")
    }
    @IBAction func showTerms(_ sender: Any) {
        SCLAlertView().showInfo("Terms of Agreement", subTitle: "This information is available on our website under the Terms of Agreement section. We are under the assumption that those terms have been read and evaluated by all users before using any Lavo Logistics service.")
    }
    @IBAction func showPrivacyPolicy(_ sender: Any) {
        SCLAlertView().showInfo("Privacy Policy", subTitle: "This information is available on our website under the Privacy Policy section. We are under the assumption that the policy have been read and evaluated by all users before using any Lavo Logistics service.")
    }
//    @IBOutlet weak var adminView: UIView!
//    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var logoutB: UIButton!
    
    @IBOutlet weak var termsB: UIButton!
    
    @IBOutlet weak var supportB: UIButton!
    @IBOutlet weak var privacyPolicyB: UIButton!
    @IBAction func logOut(_ sender: AnyObject) {
        signOutOfGoogle()
        signOutOfFirebase()
        signOutOfFacebook()
        goTo(storyboardName: "Auth", viewControllerName: "mLoginVC")
    }
    
}
