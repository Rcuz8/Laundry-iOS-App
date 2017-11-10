//
//  mAuthPasswordViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/15/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import Hero

class mAuthPasswordViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var confirmTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func createUser(_ sender: Any) {
        if passwordCheck() {
            print("password good")
        if FIRAuth.auth()?.currentUser != nil { // handle user process
            print("current user exists")
            getDefaultsInfo(finished: { (success, client) in                print("defaults info")
                if success {
                    print("defaults success")
                    let id = FIRAuth.auth()!.currentUser!.uid
                    client?.id = id
                    print(client?.simpleDescription())
                    client?.save(finished: { (saved) in
                        if saved {
                            print("save success")
                            print(client?.printableJSON)
                            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                            UserDefaults.standard.synchronize()
                            self.goTo(storyboardName: "Main", viewControllerName: "RevealControllerOriginVC")
                        } else {
                            // Error
                            SCLAlertView().showError("Oops", subTitle: "Cannot save your information, please re-check and try again!")
                        }
                    })
                } else {
                    // Error
                    SCLAlertView().showError("Oops", subTitle: "Cannot save your information, please re-check and try again!")
                }
                
            })
        } else {
            print("no current user")
            getDefaultsInfo(finished: { (success, client) in
                print("defaults info")
                if success {
                    print(client?.simpleDescription())
                    print("defaults success")
                    client!.createClientCredentials(withPassword: self.passwordTF.text!, finished: { (creationSuccess, user) in
                        if creationSuccess {
                            print("creation success")
                            client?.id = user!.uid
                            client?.save(finished: { (saveSuccess) in
                                print(client?.simpleDescription())
                                if saveSuccess {
                                    print("save success")
                                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                                    UserDefaults.standard.synchronize()
                                    self.goTo(storyboardName: "Main", viewControllerName: "RevealControllerOriginVC")
                                    
                                } else {
                                    // Error
                                    SCLAlertView().showError("Oops", subTitle: "Cannot save your information, please re-check and try again!")
                                }
                            })
                        } else {
                            print(client?.simpleDescription())
                            // Error
                            SCLAlertView().showError("Oops", subTitle: "Cannot create your account. If this persists, please try with a different email address!")
                        }
                    })
                } else {
                    // Error
                    SCLAlertView().showError("Oops", subTitle: "Cannot save your information, please re-check and try again!")
                }
            })
        }
        } else {
            // Error
            SCLAlertView().showError("Oops", subTitle: "Please enter a valid password (must be 6+ letters)")
        }
    }
    
    func passwordCheck() -> Bool {
        if let text = passwordTF.text {
            if text.length > 6 { return true } else { return false }
        } else { return false }
    }
    
    func getDefaultsInfo(finished: @escaping (_ success: Bool,_ client: Client?) -> ()) {
        
        let defaults = UserDefaults()
        if let firstName = defaults.string(forKey: "firstName"), let lastName = defaults.string(forKey: "lastName"), let email = defaults.string(forKey: "email"), let phoneNumber = defaults.string(forKey: "phoneNumber"), let street = defaults.string(forKey: "streetAddress"), let city = defaults.string(forKey: "city"), let state = defaults.string(forKey: "state"), let zip = defaults.string(forKey: "zipCode"), let apt = defaults.string(forKey: "apartmentNumber") {
            let homeAddress = HomeAddress(aStreetAddress: street, aCity: city, aState: state, aZip: zip, aptNumber: apt)
            homeAddress.getGeo(finished: { (locationRetrieved) in
                if locationRetrieved {
                    print(homeAddress.simpleDescription())
                    if homeAddress.infoValid() {
                        let client = Client()
                        client.email = email; client.firstName = firstName; client.lastName = lastName; client.homeAddress = homeAddress; client.phoneNumber = phoneNumber;
                        finished(true, client)
                    } else { finished(false, nil); print("Failed at point 2"); } // info not valid
                } else { finished(false, nil); print("Failed at point 1"); } // location not retrieved
                
            })
                    print(homeAddress.printablejson()?.dictionaryObject)
            
        } else { finished(false, nil); print("Failed at point 0"); } // standard info
    }
    
    
    @IBAction func toLastView(_ sender: Any) {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "mInfoVC") as! mInfoViewController
        vc.heroModalAnimationType = HeroDefaultAnimationType.push(direction: .right)
        self.present(vc, animated: true, completion: nil)

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
