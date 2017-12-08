//
//  AddPreferenceView.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/9/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase
import SCLAlertView
class AddPreferenceView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.roundCorners(corners: .allCorners, radius: 5)
        containerView.roundCorners(corners: .bottomLeft, radius: 6)
        
        let cancelImg = UIImage(named:"ic_remove_circle")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        cancelButton.setBackgroundImage(cancelImg, for: .normal)
        cancelButton.layer.borderWidth = 0
        cancelButton.tintColor = UIColor.darkRed
        if let u = FIRAuth.auth()?.currentUser {
            let c = Client(id: u.uid)
            c.dbFill {
             //   print(c.simpleDescription())
            }
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var prefTitle: UITextField!
    
    @IBOutlet weak var prefDescription: UITextView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissMe(animated: false, completion: nil)
        let pres = self.presentingViewController as? mOrderingPreferencesViewController
        pres?.presentedViewController?.dismissMe(animated: false, completion: nil)
        pres?.savedLocationsTableView.reloadData()
        pres?.savedPreferencesTableView.reloadData()
    }

    @IBAction func addPreference(_ sender: Any) {
        if prefTitle.text != nil, prefTitle.text != "", prefDescription.text != nil, prefDescription.text != "" {
            let newPref: (name: String, preferences: String) = (name: prefTitle!.text!, preferences: prefDescription!.text)
            if let user = FIRAuth.auth()?.currentUser {
                let client = Client(id: user.uid)
                client.dbFill {
                    if client.valid() {
                        client.savedOrderingPreferences?.append(newPref)
                        client.saveOnlyOrderPreferences(finished: { (saved) in
                            if saved {
                                SCLAlertView().showSuccess("Saved", subTitle: "You may now use your newly saved preference")
                                self.navigationController?.popViewController(animated: false)
                            } else {
                                SCLAlertView().showError("Oops", subTitle: "Could not save your preference!")
                            }
                        })
                        
                    } else {
                        
                    }
                }
            }
        } else {
            SCLAlertView().showError("Incomplete Fields", subTitle: "Please fill each field completely and try again!")
        }

        

    }


    
}

extension UIViewController {
    
    func pop() {
        self.navigationController?.popViewController(animated: false)
    }
    
         func dismissMe(animated: Bool, completion: (()->())?) {
            var count = 0
            if let c = self.navigationController?.childViewControllers.count {
                count = c
            }
            if count > 1 {
                //Pop the last view controller off navigation controller list
                self.navigationController!.popViewController(animated: animated)
                if let handler = completion {
                    handler()
                }
            } else {
                //Dismiss the last vc or vc without navigation controller
                dismiss(animated: animated, completion: completion)
            }
        }
    
}


extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

