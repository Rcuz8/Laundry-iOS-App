//
//  AdditionalInfoViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 6/27/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class HomeAddressViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var streetAddressField: UITextField!
    
    var cityField: UITextField!
    
    var zipCodeField: UITextField!
    
    var aptNumberField: UITextField!
    
    var continueButton: UIButton!
    
    var backButton: UIButton!
    
    var statePicker: UIPickerView!
    
    var activeState:String!
    
    let stateNames = ["AL","AK","AR","AZ","CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MH", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // New Info fields
        addUIelementStreetAddressField()
        addUIelementCityField()
        setupStatePicker()
        addUIelementAptNumberField()
        addUIelementZipCodeField()
        
        addUIelementBackButton()
        addUIelementLoginButton()
        
        addKeyBoardDismissFeature()
        createKeyboardObervers()
        getUserDefaultsFieldsInfo()
        
//        if let user = FIRAuth.auth()?.currentUser {
//            let client = Client()
//            client.info?.getInfoFromDatabase()
//            let info = client.info
//            
//            if let cStreetAddress = info?.homeAddress?.streetAddress {
//                streetAddressField.text = cStreetAddress
//            }
//            
//            if let cCity = info?.homeAddress?.city {
//                cityField.text = cCity
//            }
//            if let cZipCode = info?.homeAddress?.zip {
//                zipCodeField.text = cZipCode
//            }
//            if let cState = info?.homeAddress?.state {
//                activeState = cState
//                let i = 0
//                while i < stateNames.count {
//                    if stateNames[i] == cState {
//                        statePicker.selectRow(i, inComponent: 1, animated: true)
//                        break
//                    }
//                }
//            }
//            
//        }
        
    }
    
    /////////////////      BEGIN State Picker Methods      /////////////////

    
    func setupStatePicker() {
        let cgr = CGRect(x: 0, y: UIScreen.main.bounds.height*0.05, width: UIScreen.main.bounds.height*0.9, height: UIScreen.main.bounds.height*0.3) // NOTE: Figure out frames.......!!!!!!!!!!!!!
        statePicker = UIPickerView(frame: cgr)
        statePicker.delegate = self
        statePicker.dataSource = self
        statePicker.frame.centerHorizontally()
        activeState = stateNames[0]
        self.view.addSubview(statePicker)
    }
    
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
        activeState = stateNames[row]
        print(activeState)
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = stateNames[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Futura", size: 15.0)!,NSForegroundColorAttributeName:UIColor.black])
        return myTitle
    }
    
    /////////////////      END State Picker Methods      /////////////////

    
    /////////////////      BEGIN Keyboard Methods      /////////////////
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func createKeyboardObervers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    var keyboardIsPresented = false
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if !keyboardIsPresented {
                streetAddressField.frame.dilate(y: -Float(keyboardHeight/2))
                cityField.frame.dilate(y: -Float(keyboardHeight/2))
                statePicker.frame.dilate(y: -Float(keyboardHeight/2))
                zipCodeField.frame.dilate(y: -Float(keyboardHeight/2))
                aptNumberField.frame.dilate(y: -Float(keyboardHeight/2))
            }
        }
        keyboardIsPresented = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            streetAddressField.frame.dilate(y: Float(keyboardHeight/2))
            cityField.frame.dilate(y: Float(keyboardHeight/2))
            statePicker.frame.dilate(y: Float(keyboardHeight/2))
            zipCodeField.frame.dilate(y: Float(keyboardHeight/2))
            aptNumberField.frame.dilate(y: Float(keyboardHeight/2))
        }
        keyboardIsPresented = false
    }
    
    func addKeyBoardDismissFeature() {
        let tr = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tr)
    }
    
    /////////////////      END Keyboard Methods      /////////////////
    
    /////////////////      BEGIN Verify Methods      /////////////////
    
    // true means field is complete
    func verifyGeneralField(textfield: UITextField) -> Bool { // Applicable to City, Street Address, NOT FOR Apt # bc it is optional
        
        if let text = textfield.text {
            if text != "" {
                return true
            }
        }
        
        return false
    }
    
    func verifyZipCode(textfield: UITextField) -> Bool {
        
        if let text = textfield.text {
            if text != "" {
                if text.characters.count >= 5 && text.characters.count <= 9 {
                    return true
                }
            }
        }
        
        return false
    }
    
    func verifyState() -> Bool {
        if activeState != nil && activeState != "" {
            return true
        }
        return false
    }
    
    /////////////////      END Verify Methods      /////////////////
    
    /////////////////      BEGIN Textfield Color Change Methods      /////////////////
    
    func checkInfoToChangeBorderColor(textfield: UITextField) {
        
        if textfield == zipCodeField {
            if verifyZipCode(textfield: textfield) {
                textfield.layer.borderColor = UIColor.lightGreen.cgColor
                textfield.layer.borderWidth = 2
            } else {
                textfield.layer.borderColor = UIColor.lightRed.cgColor
                textfield.layer.borderWidth = 2
            }
        } else {
            if verifyGeneralField(textfield: textfield) {
                textfield.layer.borderColor = UIColor.lightGreen.cgColor
                textfield.layer.borderWidth = 2
            } else {
                textfield.layer.borderColor = UIColor.lightRed.cgColor
                textfield.layer.borderWidth = 2
            }
        }
    }
    
    
    /////////////////      END Textfield Color Change Methods      /////////////////
    
    /////////////////      BEGIN Screen Change Method      /////////////////
    
    
    
    func completeLogin() { // NOTE: Apt # is optional, do not need to verify
        if verifyZipCode(textfield: zipCodeField) && verifyGeneralField(textfield: cityField) && verifyGeneralField(textfield: streetAddressField)  && verifyState() {
            saveInfoToDefaults()
            // NOTE: Use Defaults info to be saved to Firebase
            // Clear Defaults info
            // Create Client(), fill with info
            // save info to firebase
            // check for credential (if user is logged in). If user is not, create an account for them with email & password
            
            
                // Defaults Info
            let defaults = UserDefaults()
            if let firstName = defaults.string(forKey: "firstName") {
                if let lastName = defaults.string(forKey: "lastName") {
                 //   if let email = defaults.string(forKey: "email") {
                 //       if let password = defaults.string(forKey: "password") {
                            if let phoneNumber = defaults.string(forKey: "phoneNumber") {
                                if let school = defaults.string(forKey: "school") {
                                    // Current Screen's info
                                    if let cityString = cityField.text {
                                        if let zipString = zipCodeField.text {
                                            if let streetAddressString = streetAddressField.text {
                                                print("\n HomeAddressViewController: ✅ All Login Info is usable! \n")
                                                let homeAddress = HomeAddress(aStreetAddress: streetAddressString, aCity: cityString, aState: activeState, aZip: zipString, aptNumber: String(describing: aptNumberField!.text))
                                                let clientInfo = ClientInfo()
                                               // clientInfo.email = email
                                                clientInfo.firstName = firstName
                                                clientInfo.lastName = lastName
                                                clientInfo.homeAddress = homeAddress
                                                clientInfo.phoneNumber = phoneNumber
                                                clientInfo.school = school
                                                if let user = FIRAuth.auth()?.currentUser {
//                                                    clientInfo.id = user.uid
//                                                    clientInfo.email = user.email!
//                                                    let client = Client(clientInfo: clientInfo)
//                                                    let saved = client.saveInfo()
//                                                    print("Information Saving Status: \(saved)")
//                                                    
//                                                        self.clearDefaults()
                                                    
                                                        // show alert
                                                        let appearance = SCLAlertView.SCLAppearance(
                                                            showCloseButton: false
                                                        )
                                                        let alert = SCLAlertView(appearance: appearance)
                                                        alert.addButton("Continue", action: {
                                                            self.goTo(storyboardName: "Main", viewControllerName: "RevealControllerOriginVC")
                                                        })
                                                        alert.showSuccess("All Good", subTitle: "Thank you for verifying your information. Press Continue to enter in the app")
                                                    
                                                }
                                                 else {
                                                       if let email = defaults.string(forKey: "email") {
                                                           if let password = defaults.string(forKey: "password") {
                                                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (newUser: FIRUser?, error: Error?) in
                                                        
                                                        if let user = newUser {
                                                        clientInfo.id = user.uid
                                                   //     let client = Client(clientInfo: clientInfo)
                                                     //   let saved = client.saveInfo()
                                                    //    print("Information Saving Status: \(saved)")
                                                            
                                                            self.clearDefaults()
                                                            
                                                            // show alert
                                                            
                                                            let appearance = SCLAlertView.SCLAppearance(
                                                                showCloseButton: false
                                                            )
                                                            let alert = SCLAlertView(appearance: appearance)
                                                            alert.addButton("Continue", action: {
                                                                self.goTo(storyboardName: "Main", viewControllerName: "RevealControllerOriginVC")
                                                            })
                                                            alert.showSuccess("Account Created", subTitle: "You are now signed up! Press Continue to enter in the app")
                                                        } else {
                                                            self.showErrorLoggingIn(code: 10)
                                                        }
                                                    })
                                                        }
                                                    }
                                                }
                                            } else { self.showErrorLoggingIn(code: 9) }
                                        } else { self.showErrorLoggingIn(code: 8) }
                                    } else { self.showErrorLoggingIn(code: 7) }
                                } else { self.showErrorLoggingIn(code: 6) }
                            } else { self.showErrorLoggingIn(code: 5) }
                    //    } else { self.showErrorLoggingIn(code: 4) }
                  //  } else { self.showErrorLoggingIn(code: 3) }
                } else { self.showErrorLoggingIn(code: 2) }
            } else { self.showErrorLoggingIn(code: 1) }
        
            
            
        } else {
            SCLAlertView().showError("Oops", subTitle: "It seems that there are incorrect fields. Please double check and try again!")
        }
    }
    
    func showErrorLoggingIn(code: Int) {
             SCLAlertView().showError("Oops", subTitle: "There was a problem creating your account, please check your information and try again!")
            print("HomeAddressViewController: ❌ Error logging in: ( code - \(code) )")
        }
        
    func back() {
            self.dismissKeyboard()
            self.saveInfoToDefaults()
            self.goTo(storyboardName: "Auth", viewControllerName: "PhoneNumberVC")
        
    }
    
    /////////////////      END Screen Change Method      /////////////////
    
    /////////////////      BEGIN User Defaults Methods      /////////////////
    
    func getUserDefaultsFieldsInfo() {
        let defaults = UserDefaults()
        if let city = defaults.string(forKey: "city") {
            cityField.text = city
        }
        if let streetAddress = defaults.string(forKey: "streetAddress") {
            streetAddressField.text = streetAddress
        }
        if let state = defaults.string(forKey: "state") {
            activeState = state
            let i = 0
            while i < stateNames.count {
                if stateNames[i] == state {
                    statePicker.selectRow(i, inComponent: 1, animated: true)
                    break
                }
            }
            
        }
        
        if let zipCode = defaults.string(forKey: "zipCode") {
            zipCodeField.text = zipCode
        }
        
    }
    
    func saveInfoToDefaults() {
        let defaults = UserDefaults()
        if let zipCode = zipCodeField.text {
            defaults.set(zipCode, forKey: "zipCode")
        }
        
        if let streetAddress = streetAddressField.text {
            defaults.set(streetAddress, forKey: "streetAddress")
        }
        
        if verifyState() {
            defaults.set(activeState, forKey: "state")
        }
        
        if let city = cityField.text {
            defaults.set(city, forKey: "city")
        }
     //   defaults.synchronize()
        
    }
    
    func clearDefaults() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    
    /////////////////      BEGIN User Defaults Methods      /////////////////
    
    
    /////////////////      BEGIN UI Methods      /////////////////
    
    
    func addUIelementStreetAddressField() {
        streetAddressField = UITextField()
        streetAddressField.initializeRect()
        streetAddressField.frame.dilate(y: -Float(streetAddressField.frame.height*2.2))
        streetAddressField.placeholder = "Enter Street Address"
        streetAddressField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(streetAddressField)
    }
    
    func addUIelementCityField() {
        cityField = UITextField()
        cityField.initializeRect()
        cityField.frame.dilate(y: -Float(cityField.frame.height))
        cityField.placeholder = "Enter City"
        cityField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(cityField)
        
    }
    
    func addUIelementZipCodeField() {
        zipCodeField = UITextField()
        zipCodeField.initializeRect()
        zipCodeField.frame.dilate(y: Float(zipCodeField.frame.height))
        zipCodeField.placeholder = "Enter Zip Code"
        zipCodeField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(zipCodeField)
        
    }
    
    func addUIelementAptNumberField() {
        aptNumberField = UITextField()
        aptNumberField.initializeRect()
        aptNumberField.frame.dilate(y: Float(aptNumberField.frame.height*2.2))
        aptNumberField.placeholder = "Enter Apt. Number (Optional)"
        aptNumberField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(aptNumberField)
    }
    
    func addUIelementLoginButton() {
        let x = UIScreen.main.bounds.width*0.65
        var cgr = CGRect(x: x,y:UIScreen.main.bounds.height/37, width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.height/15)
        continueButton = UIButton(frame: cgr)
        continueButton.setTitle("Next", for: .normal)
        continueButton.setTitleColor(.black, for: .normal)
        continueButton.titleLabel?.font = UIFont(name: "optima", size: fontSizeWithScreen())
        continueButton.titleLabel?.text = "Finish"
        continueButton.titleLabel?.minimumScaleFactor = 0.2
        continueButton.layer.cornerRadius = 6
        continueButton.layer.borderWidth = 4
        continueButton.layer.borderColor = UIColor.black.cgColor
        continueButton.addTarget(self, action: #selector(completeLogin), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    func addUIelementBackButton() {
        let x = UIScreen.main.bounds.width*0.05
        var cgr = CGRect(x: x,y:UIScreen.main.bounds.height/37, width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.height/15)
        backButton = UIButton(frame: cgr)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = UIFont(name: "optima", size: fontSizeWithScreen())
        backButton.titleLabel?.text = "Back"
        backButton.titleLabel?.minimumScaleFactor = 0.2
        backButton.layer.cornerRadius = 6
        backButton.layer.borderWidth = 4
        backButton.layer.borderColor = UIColor.black.cgColor
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    /////////////////      END UI Methods      /////////////////

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Create fields for firstName, lastName, email, school, homeAddress, id
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
