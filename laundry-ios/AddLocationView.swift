//
//  AddLocationView.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/25/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DropDown

class AddLocationView: UIViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var streetTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var aptNumberTF: UITextField!
    @IBOutlet weak var stateButton: UIButton!
    var drop = DropDown()
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var activeState = ""
    
    @IBOutlet weak var cancelButton: UIButton!
    let stateNames = ["AL","AK","AR","AZ","CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MH", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drop.anchorView = stateButton
        drop.dataSource = stateNames
        drop.dismissMode = .onTap
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            self.activeState = item
            self.stateButton.setTitle(item, for: .normal)
            self.stateButton.setTitleColor(UIColor.lavoDarkBlue, for: .normal)
            self.drop.hide()
        }
        DropDown.startListeningToKeyboard()
        drop.direction = .any
        drop.width = CGFloat(partOfScreenWidth_f(percentage: 25))
        stateButton.contentHorizontalAlignment = .left
        cancelButton.tintColor = UIColor.darkRed
        if let u = FIRAuth.auth()?.currentUser {
        let c = Client(id: u.uid)
            c.dbFill {
           //     print(c.simpleDescription())
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showStateDropDown(_ sender: Any) {
        drop.show()
    }
    
    @IBAction func save(_ sender: Any) {
        if fieldsAreCompleted() {
                let address = HomeAddress(aStreetAddress: streetTF.text!, aCity: cityTF.text!, aState: activeState, aZip: zipTF.text!, aptNumber: aptNumberTF?.text)
                address.getGeo(finished: { (success) in
                    let title = self.titleTF.text!
                    print("getGeo callback . . .")
                    if success {
                        print("getGeo successful . . .")
                        
                        let addressStr = "\(address.apartmentNumber) \(address.streetAddress) \(address.city), USA"
                        
                        let newSavedAddress = (name: title, location: addressStr)
                        
                        let db = UserDB()
                        
                        if let user = db.getUser() {
                            print(" User Found!")
                            db.getLocations(forUserWithId: user.uid, finished: { (savedLocs, recentLocs) in
                                var saved = savedLocs
                                saved.append(newSavedAddress)
                                db.postSavedLocations(forUserWithId: user.uid, locations: saved, finished: {
                                    SCLAlertView().showSuccess("Great", subTitle: "New Location Saved!")
                                })
                            })
                        } else { SCLAlertView().showError("Oops", subTitle: "We cannot find your personal information!") }
                    } else { SCLAlertView().showError("Oops", subTitle: "Please re-check the address information!")
                        print(address.printablejson())
                    }
                })
            
            
            
        } else { SCLAlertView().showError("Oops", subTitle: "It seems you have invalid information!") }
    }

    
    @IBAction func cancel(_ sender: Any) {
        //  pop()
        
        dismissMe(animated: false, completion: nil)
        let pres = self.presentingViewController as? mOrderingPreferencesViewController
        pres?.presentedViewController?.dismissMe(animated: false, completion: nil)
        pres?.savedLocationsTableView.reloadData()
        pres?.savedPreferencesTableView.reloadData()
    }

    func fieldsAreCompleted() -> Bool {
        if let str = streetTF.text, let ci = cityTF.text, let z = zipTF.text, activeState != "", let title = titleTF.text {
            return true
        } else { return false }
    }
    
}
