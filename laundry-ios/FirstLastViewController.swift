//
//  ConfirmViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 5/21/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class FirstLastViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var lNameField: UITextField!
    
    var fNameField: UITextField!
    
    var backButton: UIButton!
    
    var continueButton: UIButton!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUIelementBackButton()
        addUIelementContinueButton()
        addUIelementfNameField()
        addUIelementlNameField()
        createKeyboardObervers()
        addDismissalFeature()
        getUserDefaultsFieldsInfo()
        // Do any additional setup after loading the view.
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
                fNameField.frame.dilate(y: -Float(keyboardHeight/2))
                lNameField.frame.dilate(y: -Float(keyboardHeight/2))
            }
        }
        keyboardIsPresented = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            fNameField.frame.dilate(y: Float(keyboardHeight/2))
            lNameField.frame.dilate(y: Float(keyboardHeight/2))
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
        backButton.addTarget(self, action: #selector(backToUniversityVC), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    func addUIelementfNameField() {
        fNameField = UITextField()
        fNameField.initializeRect()
        fNameField.frame.dilate(y: -Float(fNameField.frame.height))
        fNameField.placeholder = "Enter First Name"
        fNameField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(fNameField)
        
    }
    
    func addUIelementlNameField() {
        lNameField = UITextField()
        lNameField.initializeRect()
        lNameField.frame.dilate(y: Float(lNameField.frame.height))
        lNameField.placeholder = "Enter Last Name"
        lNameField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(lNameField)
        
    }
    
    
    func checkInfoToChangeBorderColor(textfield: UITextField) {
        
        if verifyGeneralField(textfield: textfield) {
            textfield.layer.borderColor = UIColor.lightGreen.cgColor
            textfield.layer.borderWidth = 2
        } else {
            textfield.layer.borderColor = UIColor.lightRed.cgColor
            textfield.layer.borderWidth = 2
        }
        
    }
    
    
    // true means field is complete
    func verifyGeneralField(textfield: UITextField) -> Bool {
        
        if let text = textfield.text {
            if text != "" {
                return true
            }
        }
        
        return false
    }
    
    func getUserDefaultsFieldsInfo() {
        let defaults = UserDefaults()
        if let firstName = defaults.string(forKey: "firstName") {
            fNameField.text = firstName
        }
        if let lastName = defaults.string(forKey: "lastName") {
            lNameField.text = lastName
        }
    }
    
    func saveInfoToDefaults() {
        let defaults = UserDefaults()
        if let firstName = fNameField.text {
            defaults.set(firstName, forKey: "firstName")
        }
        
        if let lastName = lNameField.text {
            defaults.set(lastName, forKey: "lastName")
        }
        
    }
    
    func backToUniversityVC() {
        self.dismissKeyboard()
        saveInfoToDefaults()
        goTo(storyboardName: "Auth", viewControllerName: "UniversityVC")
    }
    
    func continueToNextAuthScreen() {
        if verifyGeneralField(textfield: fNameField) && verifyGeneralField(textfield: lNameField) {
            // segue to vc
            saveInfoToDefaults()
            goTo(storyboardName: "Auth", viewControllerName: "PhoneNumberVC")
        } else {
            SCLAlertView().showError("Oops", subTitle: "It seems that there are incorrect fields. Please double check and try again!")
        }
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
