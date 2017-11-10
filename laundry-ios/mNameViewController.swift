//
//  mNameViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/15/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import Hero
class mNameViewController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    
    @IBOutlet weak var lastNameTF: UITextField!
    
    @IBOutlet weak var nextViewB: UIButton!
    @IBOutlet weak var lastViewB: UIButton!
    
    var animations: [HeroDefaultAnimationType] = [
        .push(direction: .left),
        .pull(direction: .left),
        .slide(direction: .left),
        .zoomSlide(direction: .left),
        .cover(direction: .up),
        .uncover(direction: .up),
        .pageIn(direction: .left),
        .pageOut(direction: .left),
        .fade,
        .zoom,
        .zoomOut,
        .none
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDefaults()
        
        nextViewB.tintColor = UIColor.lavoLightGray
        lastViewB.tintColor = UIColor.lavoLightGray
        fillAppropriately()
    }
    
    func fillAppropriately() {
        if let user = FIRAuth.auth()?.currentUser { print("user found")
            let client = Client(id: user.uid)
            client.dbFill {
                print(client.simpleDescription())
                self.firstNameTF.text = client.firstName
                self.lastNameTF.text = client.lastName
            }
        } else { print("no user found") }
    }
    
    @IBAction func toLastView(_ sender: Any) {
        self.showConfirm { (isExiting) in
            if isExiting {
                self.saveDefaults()
                let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "mLoginVC") as! mLoginViewController
                vc.heroModalAnimationType = HeroDefaultAnimationType.push(direction: .right)
                self.present(vc, animated: true, completion: nil)
            }}
    }

    
    
    @IBAction func toNextView(_ sender: Any) {
        self.saveDefaults()
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "mInfoVC") as! mInfoViewController
        vc.heroModalAnimationType = HeroDefaultAnimationType.push(direction: .left)
        self.present(vc, animated: true, completion: nil)

    }
    
    func getDefaults() {
        let defaults = UserDefaults()
        if let firstName = defaults.string(forKey: "firstName") {
            firstNameTF.text = firstName
        }
        if let lastName = defaults.string(forKey: "lastName") {
            lastNameTF.text = lastName
        }
    }
    
    func saveDefaults() {
        let defaults = UserDefaults()
        if let firstName = firstNameTF.text {
            defaults.set(firstName, forKey: "firstName")
        }
        
        if let lastName = lastNameTF.text {
            defaults.set(lastName, forKey: "lastName")
        }
        
    }
    
    
    func showConfirm(finished: @escaping (_ confirmed: Bool) -> ()) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Continue", action: {
            finished(false)
        })
        alert.addButton("Exit", action: {
            finished(true)
        })
        alert.showWait("Exit?", subTitle: "Are you sure you want to exit?")
    }
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
