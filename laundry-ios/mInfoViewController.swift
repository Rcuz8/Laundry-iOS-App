//
//  mInfoViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/15/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import Hero

class mInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var nextViewButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var dropDownButton: UIButton!
    
    @IBOutlet weak var streetTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var aptTF: UITextField!
    
    @IBOutlet weak var statePicker: UIPickerView!
    
    @IBOutlet weak var line7: UIView!
    @IBOutlet weak var line4: UIView!
    @IBOutlet weak var line5: UIView!
    @IBOutlet weak var line6: UIView!
    @IBOutlet weak var line3: UIView!
    
    @IBOutlet weak var staticStateLabel: UILabel!
    
    let stateNames = ["AL","AK","AR","AZ","CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MH", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDefaults()
        if let user = FIRAuth.auth()?.currentUser{
            let client = Client(id: user.uid)
            client.dbFill {
                if let email = client.email { self.emailTF.text = email }
                if let phone = client.phoneNumber { self.emailTF.text = phone }
                if let home = client.homeAddress { if home.infoValid() {
                    self.streetTF.text = home.streetAddress
                    self.statePicker.selectRow(self.stateNames.index(of: home.state)!, inComponent: 0, animated: false)
                    self.zipTF.text = home.zip
                    self.aptTF.text = home.apartmentNumber
                    } }
             self.dbFilled = true
            }
        }
    
        statePicker.delegate = self
        statePicker.dataSource = self
        fillAppropriately()
        checkForExisting()
        hideDropped()
    }
    
    func fillAppropriately() {
        if let user = FIRAuth.auth()?.currentUser {
            let client = Client(id: user.uid)
            client.dbFill {
                if let email = client.email { self.emailTF.text = email }
                if let phoneNumber = client.phoneNumber { self.phoneTF.text = phoneNumber }
                if let address = client.homeAddress, address.infoValid() {
                if let street = client.homeAddress?.streetAddress { self.streetTF.text = street }
                if let city = client.homeAddress?.city { self.cityTF.text = city }
                if let state = client.homeAddress?.state { self.statePicker.selectRow(self.stateNames.index(of: state)!, inComponent: 0, animated: false) }
                if let zip = client.homeAddress?.zip { self.zipTF.text = zip }
                    if let apt = client.homeAddress?.apartmentNumber { if apt != "" { self.aptTF.text = apt }}
                }
            
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func seeMyAddressFields(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.dropDownButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        if zipTF.alpha == 0 { showDropped() } else { hideDropped() }
    }

    @IBAction func toLastView(_ sender: Any) {
        self.saveDefaults()
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "mNameVC") as! mNameViewController
        vc.heroModalAnimationType = HeroDefaultAnimationType.push(direction: .right)
        self.present(vc, animated: true, completion: nil)

    }
    
    func toNextView() {
        self.saveDefaults()
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "mPasswordVC") as! mAuthPasswordViewController
        vc.heroModalAnimationType = HeroDefaultAnimationType.push(direction: .left)
        self.present(vc, animated: true, completion: nil)

    }
    
    func getDefaults() {
        let defaults = UserDefaults()
        if let email = defaults.string(forKey: "email") {
            emailTF.text = email
        }
        if let phoneNumber = defaults.string(forKey: "phoneNumber") {
            phoneTF.text = phoneNumber
        }
        if let street = defaults.string(forKey: "streetAddress") {
            streetTF.text = street
        }
        if let city = defaults.string(forKey: "city") {
            cityTF.text = city
        }
        if let state = defaults.string(forKey: "state") {
            statePicker.selectRow(stateNames.index(of: state)!, inComponent: 0, animated: false)
        }
        if let zip = defaults.string(forKey: "zipCode") {
            zipTF.text = zip
        }
        if let apt = defaults.string(forKey: "apartmentNumber") {
            aptTF.text = apt
        }
    }
    
    func saveDefaults() {
        let defaults = UserDefaults()
        if let phone = phoneTF.text {
            defaults.set(phone, forKey: "phoneNumber")
        }
        
        if let streetAddress = streetTF.text {
            defaults.set(streetAddress, forKey: "streetAddress")
        }
        
        if let apartmentNumber = aptTF.text {
            defaults.set(apartmentNumber, forKey: "apartmentNumber")
        }
        
        if let email = emailTF.text {
            defaults.set(email, forKey: "email")
        }
        
        if let zipCode = zipTF.text {
            defaults.set(zipCode, forKey: "zipCode")
        }
        if let city = cityTF.text {
            defaults.set(city, forKey: "city")
        }
        
         let state = stateNames[statePicker.selectedRow(inComponent: 0)]
            defaults.set(state, forKey: "state")

        defaults.synchronize()
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
        alert.showError("Exit?", subTitle: "Are you sure you want to exit?")
    }
    
    
    
    func hideDropped() {
        line4.alpha = 0
        line5.alpha = 0
        line6.alpha = 0
        line7.alpha = 0
        staticStateLabel.alpha = 0
        streetTF.alpha = 0
        cityTF.alpha = 0
        zipTF.alpha = 0
        aptTF.alpha = 0
        statePicker.alpha = 0
    }
    func showDropped() {
        line4.alpha = 1
        line5.alpha = 1
        line6.alpha = 1
        line7.alpha = 1
        staticStateLabel.alpha = 1
        streetTF.alpha = 1
        cityTF.alpha = 1
        zipTF.alpha = 1
        aptTF.alpha = 1
        statePicker.alpha = 1
    }
    
    
    // BEGIN Picker View
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateNames.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stateNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Do nothing
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = stateNames[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Futura", size: 13.0)!,NSForegroundColorAttributeName:UIColor.lavoLightGray])
        return myTitle
    }
    
    //  END Picker Methods
    
    
    
    
    
    
    
    
    
    
    
    
    func checkForExisting() {
        if let user = FIRAuth.auth()?.currentUser {
            let addPerson = UIImage(named:"ic_person_add_white_24dp_2x")?.withRenderingMode(
                UIImageRenderingMode.alwaysTemplate)
            
            nextViewButton.setImage(addPerson, for: .normal)
            nextViewButton.addTarget(self, action: #selector(createUser), for: .touchUpInside)
            let c = Client(id: user.uid)
            c.dbFill {
                if c.email != nil {
                    self.emailTF.isHidden = true
                    self.line1.isHidden = true
                }
            }
            
        } else {
            nextViewButton.addTarget(self, action: #selector(toNextView), for: .touchUpInside)
        }
    }
    
    
    // Existing User Case
    
    @IBOutlet weak var line1: UIView!
    func createUser() {
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
                            } else { self.infoError() }
                        })
                    } else { self.infoError() }
                })
            }
    }
    
    var dbFilled = false
    
    func getDefaultsInfo(finished: @escaping (_ success: Bool,_ client: Client?) -> ()) {
        if dbFilled {
        let defaults = UserDefaults()
        if let firstName = defaults.string(forKey: "firstName"), let lastName = defaults.string(forKey: "lastName"), let email = self.emailTF.text, let phoneNumber = phoneTF.text, let street = self.streetTF.text, let city = self.cityTF.text, let zip = self.zipTF.text {
             let state = self.stateNames[statePicker.selectedRow(inComponent: 0)]
            var apt = ""
            if aptTF.text != nil && aptTF.text != "" { apt = aptTF.text! }
            let homeAddress = HomeAddress(aStreetAddress: street, aCity: city, aState: state, aZip: zip, aptNumber: apt)
            homeAddress.getGeo(finished: { (locationRetrieved) in
                if locationRetrieved {
                    print(homeAddress.simpleDescription())
                    if homeAddress.infoValid() {
                        let client = Client()
                        client.email = email; client.firstName = firstName; client.lastName = lastName; client.homeAddress = homeAddress; client.phoneNumber = phoneNumber;
                        finished(true, client)
                    } else { finished(false, nil); print("Failed at point 2"); self.infoError(); } // info not valid
                } else { finished(false, nil); print("Failed at point 1"); self.infoError(); } // location not retrieved
            })
            print(homeAddress.printablejson()?.dictionaryObject)
            
        } else { finished(false, nil); print("Failed at point 0"); self.infoError(); } // standard info
        } else { finished(false, nil); print("db not filled yet"); self.infoError(); }
    }
    
    func infoError() {
        SCLAlertView().showError("Oops", subTitle: "Cannot save your information, please re-check and try again!")
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
