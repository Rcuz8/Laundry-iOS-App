//
//  PhoneNumberViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 5/24/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
class PhoneNumberViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var phoneNumField: UITextField!
    
    var backButton: UIButton!
    
    var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUIelementBackButton()
        addUIelementContinueButton()
        addUIelementPhoneNumField()
        createKeyboardObervers()
        addDismissalFeature()
        getUserDefaultsFieldsInfo()
        // Do any additional setup after loading the view.
//        if let user = FIRAuth.auth()?.currentUser {
//            let client = Client()
//            client.info?.getInfoFromDatabase()
//            let info = client.info
//            if let cPhoneNumber = info?.phoneNumber {
//                phoneNumField.text = cPhoneNumber
//            }
//            
//        }
    }
    
    func addDismissalFeature() {
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    var keyboardIsPresented = false
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func createKeyboardObervers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if !keyboardIsPresented {
                phoneNumField.frame.dilate(y: -Float(keyboardHeight/2))
            }
        }
        keyboardIsPresented = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            phoneNumField.frame.dilate(y: Float(keyboardHeight/2))
        }
        keyboardIsPresented = false
    }
    
    func addUIelementContinueButton() {
        let x = UIScreen.main.bounds.width*0.65
        var cgr = CGRect(x: x,y:UIScreen.main.bounds.height/37, width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.height/15)
        continueButton = UIButton(frame: cgr)
        continueButton.setTitle("Next", for: .normal)
        continueButton.setTitleColor(.black, for: .normal)
        continueButton.titleLabel?.font = UIFont(name: "optima", size: fontSizeWithScreen())
        continueButton.titleLabel?.text = "Next"
        continueButton.titleLabel?.minimumScaleFactor = 0.2
        continueButton.layer.cornerRadius = 6
        continueButton.layer.borderWidth = 4
        continueButton.layer.borderColor = UIColor.black.cgColor
        continueButton.addTarget(self, action: #selector(continueToNextAuthScreen), for: .touchUpInside)
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
        backButton.addTarget(self, action: #selector(backToFirstLastVC), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    func addUIelementPhoneNumField() {
        phoneNumField = UITextField()
        phoneNumField.initializeRect()
        phoneNumField.frame.dilate(y: -Float(phoneNumField.frame.height))
        phoneNumField.placeholder = "Enter Phone Number"
        phoneNumField.keyboardType = UIKeyboardType.phonePad//.numberPad
        phoneNumField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(phoneNumField)
        //
    }
    
    
    func checkInfoToChangeBorderColor(textfield: UITextField) {
        
        if verifyPhoneNumberField(textfield: textfield) {
            textfield.layer.borderColor = UIColor.lightGreen.cgColor
            textfield.layer.borderWidth = 2
        } else {
            textfield.layer.borderColor = UIColor.lightRed.cgColor
            textfield.layer.borderWidth = 2
        }
        
    }
    
    
    // true means field is complete
    func verifyPhoneNumberField(textfield: UITextField) -> Bool {
        
        if let text = textfield.text {
            if text != "" {
                if text.characters.count == 10 { // NOTE: We assume 10-digit Phone Number
                return true
                }
            }
        }
        
        return false
    }
    
    func getUserDefaultsFieldsInfo() {
        let defaults = UserDefaults()
        if let phoneNumber = defaults.string(forKey: "phoneNumber") {
            phoneNumField.text = phoneNumber
        }
    }
    
    func saveInfoToDefaults() {
        let defaults = UserDefaults()
        if let phoneNumber = phoneNumField.text {
            defaults.set(phoneNumber, forKey: "phoneNumber")
        }
        
        
    }
    
    func backToFirstLastVC() {
        self.dismissKeyboard()
        saveInfoToDefaults()
        goTo(storyboardName: "Auth", viewControllerName: "FirstLastVC")
    }
    
    func continueToNextAuthScreen() {
        if verifyPhoneNumberField(textfield: phoneNumField) {
            // segue to vc
            saveInfoToDefaults()
            goTo(storyboardName: "Auth", viewControllerName: "HomeAddressVC")
        } else {
            SCLAlertView().showError("Oops", subTitle: "It seems that there are incorrect fields. Please double check and try again!")
        }
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
