//
//  EmailAndPasswordViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 6/29/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class EmailAndPasswordViewController: UIViewController {

    var emailField: UITextField!
    
    var confirmEmailField: UITextField!
    
    var passField: UITextField!
    
    var confirmPassField: UITextField!
    
    var continueButton: UIButton!
    
    var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addUIelementEmailField()
        addUIelementConfirmEmailField()
        addUIelementPassField()
        addUIelementConfirmPassField()
        addUIelementContinueButton()
        addKeyBoardDismissFeature()
        createKeyboardObervers()
        if let user = FIRAuth.auth()?.currentUser {
            
        } else {
             addUIelementBackButton() // --> Only displays when NOT on user track
        }
        
        getUserDefaultsFieldsInfo()
    }
    
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
            emailField.frame.dilate(y: -Float(keyboardHeight/2))
            confirmEmailField.frame.dilate(y: -Float(keyboardHeight/2))
            passField.frame.dilate(y: -Float(keyboardHeight/2))
            confirmPassField.frame.dilate(y: -Float(keyboardHeight/2))
            }
        }
        keyboardIsPresented = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            emailField.frame.dilate(y: Float(keyboardHeight/2))
            confirmEmailField.frame.dilate(y: Float(keyboardHeight/2))
            passField.frame.dilate(y: Float(keyboardHeight/2))
            confirmPassField.frame.dilate(y: Float(keyboardHeight/2))
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
    func verifyGeneralField(textfield: UITextField) -> Bool {
        
            if let text = textfield.text {
                if text != "" {
                    return true
                }
            }
        
        return false
    }
    
    func verifyPassField(textfield: UITextField) -> Bool {
        
        
            if let text = textfield.text {
                if text != "" {
                    if text.characters.count >= 6 {
                        return true
                    }
                }
            }
        
        return false
    }

    func verifyEmailField(textfield: UITextField) -> Bool {
        
            if let text = textfield.text {
                if text != "" {
                    if text.contains("@") && text.contains("."){
                        if text.lastIndexOf(target: "@") != (text.length-1) {
                            if text.lastIndexOf(target: ".") != 0 {
                                if text.lastIndexOf(target: "@") != 0 {
                                    print(text.lastIndexOf(target: "."))
                                    print();print();print();print();print()
                                    return true
                                }
                            }
                        }
                    }
                }
            }
        return false
    }

    func verifyConfirmField(textfield: UITextField, email: Bool) -> Bool {
        
            if let text = textfield.text {
                if text != "" {
                    if email {
                        if let emText = emailField.text {
                            if text == emText {
                                return true
                            }
                        }
                    } else {
                        if let passText = passField.text {
                            if text == passText {
                                return true
                            }
                        }
                    }
                        
                }
            }
            return false
    }
    
        /////////////////      END Verify Methods      /////////////////
    
        /////////////////      BEGIN Textfield Color Change Methods      /////////////////
    
    func checkInfoToChangeBorderColor(textfield: UITextField) {
        
        if textfield == emailField {
            if verifyEmailField(textfield: textfield) {
                textfield.layer.borderColor = UIColor.lightGreen.cgColor
                textfield.layer.borderWidth = 2
            } else {
                textfield.layer.borderColor = UIColor.lightRed.cgColor
                textfield.layer.borderWidth = 2
            }
        } else if textfield == passField {
            if verifyPassField(textfield: textfield) {
                textfield.layer.borderColor = UIColor.lightGreen.cgColor
                textfield.layer.borderWidth = 2
            } else {
                textfield.layer.borderColor = UIColor.lightRed.cgColor
                textfield.layer.borderWidth = 2
            }
        } else if textfield == confirmEmailField {
            if verifyConfirmField(textfield: textfield, email: true) {
                textfield.layer.borderColor = UIColor.lightGreen.cgColor
                textfield.layer.borderWidth = 2
            } else {
                textfield.layer.borderColor = UIColor.lightRed.cgColor
                textfield.layer.borderWidth = 2
            }
        } else if textfield == confirmPassField {
            if verifyConfirmField(textfield: textfield, email: false) {
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
    
    
    
    func continueToNextAuthScreen() {
        if verifyPassField(textfield: passField) && verifyEmailField(textfield: emailField) && verifyConfirmField(textfield: confirmEmailField, email: true) && verifyConfirmField(textfield: passField, email: false) {
            saveInfoToDefaults()
                goTo(storyboardName: "Auth", viewControllerName: "UniversityVC")
        } else {
            SCLAlertView().showError("Oops", subTitle: "It seems that there are incorrect fields. Please double check and try again!")
        }
    }
    
    func exitToHome() {
        self.dismissKeyboard()
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
       
        alert.addButton("Exit") {
            self.saveInfoToDefaults()
            self.goTo(storyboardName: "Auth", viewControllerName: "LoginVC")
        }
        alert.addButton("Stay") { 
            alert.dismiss(animated: true, completion: {
                //..
            })
        }
         alert.showNotice("Exit Login", subTitle: "Exitting login would lose all progress, are you sure you would like to exit?")
    }
    
    /////////////////      END Screen Change Method      /////////////////
    
    /////////////////      BEGIN User Defaults Methods      /////////////////

    func getUserDefaultsFieldsInfo() {
        let defaults = UserDefaults()
        if let password = defaults.string(forKey: "password") {
            passField.text = password
        }
        if let email = defaults.string(forKey: "email") {
            emailField.text = email
        }
    }
    
    func saveInfoToDefaults() {
        let defaults = UserDefaults()
        if let email = emailField.text {
            defaults.set(email, forKey: "email")
        }
        
        if let password = passField.text {
            defaults.set(password, forKey: "password")
        }
        
    }
    
    /////////////////      BEGIN User Defaults Methods      /////////////////

    
        /////////////////      BEGIN UI Methods      /////////////////
    
    
    func addUIelementEmailField() {
        emailField = UITextField()
        emailField.initializeRect()
        emailField.frame.dilate(y: -Float(emailField.frame.height*2.2))
        emailField.placeholder = "Enter Email"
        emailField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
        self.view.addSubview(emailField)
    }
    
    func addUIelementConfirmEmailField() {
        confirmEmailField = UITextField()
        confirmEmailField.initializeRect()
            confirmEmailField.frame.dilate(y: -Float(confirmEmailField.frame.height))
            confirmEmailField.placeholder = "Confirm Email"
            confirmEmailField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
            self.view.addSubview(confirmEmailField)
        
    }
    
    func addUIelementPassField() {
        passField = UITextField()
        passField.initializeRect()
            passField.frame.dilate(y: Float(passField.frame.height))
            passField.placeholder = "Enter Password"
            passField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
            self.view.addSubview(passField)
        
    }
    
    func addUIelementConfirmPassField() {
            confirmPassField = UITextField()
            confirmPassField.initializeRect()
            confirmPassField.frame.dilate(y: Float(confirmPassField.frame.height*2.2))
            confirmPassField.placeholder = "Confirm Password"
            confirmPassField.addTarget(self, action: #selector(checkInfoToChangeBorderColor(textfield:)), for: UIControlEvents.editingChanged)
            self.view.addSubview(confirmPassField)
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
        backButton.addTarget(self, action: #selector(exitToHome), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
        /////////////////      END UI Methods      /////////////////
    
//   /* NOT USING, LOGIC ERRORs
//    func initRect(onCompletion: () -> Void) -> UITextField{
//        var cgr = CGRect(x: 0,y:0, width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height/15)
//        cgr.centerHorizontally()
//        cgr.centerVertically()
//        var textfield = UITextField(frame: cgr)
//        
//        indentTextField(textfield: textfield)
//        onCompletion()
//        return textfield
//        
//    }
//    */
//    func indentTextField(textfield: UITextField) {
//        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
//        textfield.leftViewMode = UITextFieldViewMode.always
//        textfield.leftView = spacerView
//    }
    
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

extension UIViewController {
    
    func goTo(storyboardName: String, viewControllerName: String) {
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            let goingTo = storyboard.instantiateViewController(withIdentifier: viewControllerName)
            self.present(goingTo, animated: true, completion: nil)
    }
    
    func goTo(storyboardName: String, viewControllerName: String, animated: Bool) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let goingTo = storyboard.instantiateViewController(withIdentifier: viewControllerName)
        self.present(goingTo, animated: animated, completion: nil)
    }
    
    func goTo(storyboardName: String, viewControllerName: String, animated: Bool, presentationStyle: UIModalPresentationStyle) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let goingTo = storyboard.instantiateViewController(withIdentifier: viewControllerName)
        goingTo.modalPresentationStyle = presentationStyle
        self.present(goingTo, animated: animated, completion: nil)
    }
    
}

extension String {

    var firstCharacter: Character {
        get {
            var returnChar: Character!
            for char in self.characters {
                returnChar = char
                break
            }
            return returnChar
        }
    }
    
}

extension UITextField {
    
    func indent() {
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = spacerView
    }
    
    func initializeRect() {
        
        func indentTextField(textfield: UITextField) {
            let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
            textfield.leftViewMode = UITextFieldViewMode.always
            textfield.leftView = spacerView
        }
        
        var cgr = CGRect(x: 0,y:0, width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height/15)
        cgr.centerHorizontally()
        cgr.centerVertically()
        self.frame = cgr
        indentTextField(textfield: self)
        self.layer.cornerRadius = 5
    }
    
}

extension UIViewController {
    
    // GOAL: Determine Font Size based on the screen size
    func fontSizeWithScreen () -> CGFloat{
        // NOTE: 25 pt font works well with a 7+ Screen, this logic is to get that same proportion on an screen size
        
        return UIScreen.main.bounds.height * 0.035
    }
    
}

extension UIColor {
    
    class var lightGreen: UIColor {
        get {
            return UIColor(red: 0, green: 138/255, blue: 28/255, alpha: 0.7)
        }
    }
    
    class var lightRed: UIColor {
        get {
            return UIColor(red: 219/255, green: 112/255, blue: 112/255, alpha: 1)
        }
    }
    
}


extension String {
    
    var length:Int {
        return self.characters.count
    }
    
    func indexOf(target: String) -> Int? {
        
        let range = (self as NSString).range(of: target)
        
        guard range.toRange() != nil else {
            return nil
        }
        
        return range.location
        
    }
    func lastIndexOf(target: String) -> Int? {
        
        
        
        let range = (self as NSString).range(of: target, options: NSString.CompareOptions.caseInsensitive)
        
        guard range.toRange() != nil else {
            return nil
        }
        
        return self.length - range.location - 1
        
    }
    func contains(s: String) -> Bool {
        return (self.range(of: s) != nil) ? true : false
    }
}
