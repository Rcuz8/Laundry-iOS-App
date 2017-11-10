//
//  LoginViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 5/19/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import FacebookLogin
import Firebase
import GoogleSignIn
import SCLAlertView
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController, GIDSignInUIDelegate, UIGestureRecognizerDelegate, LoginButtonDelegate {

   

    var emailField: UITextField!
    
    var passField: UITextField!
    
    var sView: UIView!
    
    var divLine: UIView!
    
    var standardSignInButton: UIButton!
    
    var createAccountPrefaceLabel: UILabel!
    var createAccountSelectableLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blurBackgroundView(addingImage: true)
        
        addGoogleButton()
        addFacebookButton()
        addStandardSignIn()
        addUIelementLavoLabel()
        addDismissalFeature()
        createKeyboardObervers()
        addUIelementLetsGetWashingLabel()
        addUIelementCreateAccountLabels()
    }
    
    var lavoLabel: UILabel!
    
    var letsGetWashing: UILabel!
    
    func addUIelementLavoLabel() {
        //  let width = UIScreen.main.bounds.width
        //  let height = UIScreen.main.bounds.height
        let cgr = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 5), width: Double(partOfScreenWidth_d(percentage: 100)), height: Double(partOfScreenHeight_d(percentage: 10)))
        lavoLabel = UILabel(frame: cgr)
        lavoLabel.text = "Lavo"
        lavoLabel.textColor = UIColor.veryLightGray
        lavoLabel.font = UIFont(name: "Bangla Sangam MN", size: fontSizeWithScreen()*2.4)
        lavoLabel.frame.centerHorizontally()
        lavoLabel.center.x = self.view.center.x
        lavoLabel.textAlignment = .center
        self.view.addSubview(lavoLabel)
        
    }
    
    func addUIelementLetsGetWashingLabel() {
      //  let width = UIScreen.main.bounds.width
      //  let height = UIScreen.main.bounds.height
        
        let cgr = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 20), width: Double(partOfScreenWidth_d(percentage: 100)), height: Double(partOfScreenHeight_d(percentage: 10)))
         letsGetWashing = UILabel(frame: cgr)
        letsGetWashing.text = "Let's Get Washing"
        letsGetWashing.textColor = UIColor.white
        letsGetWashing.font = UIFont(name: "Bangla Sangam MN", size: fontSizeWithScreen()*1.8)
        letsGetWashing.frame.centerHorizontally()
        letsGetWashing.center.x = self.view.center.x
        letsGetWashing.textAlignment = .center
        self.view.addSubview(letsGetWashing)
        
    }
    
    var createAccountLabels: UIView!
    
    func addUIelementCreateAccountLabels() {
        let labelsCGR = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 35), width: Double(partOfScreenWidth_d(percentage: 100)), height: Double(partOfScreenHeight_d(percentage: 4)))
        createAccountLabels = UIView()
        createAccountPrefaceLabel = UILabel()
        createAccountSelectableLabel = UILabel()
        createAccountLabels.frame = labelsCGR
      //  createAccountLabels.addSubview(createAccountPrefaceLabel)
      //  createAccountLabels.addSubview(createAccountSelectableLabel)
      //  createAccountLabels.backgroundColor = UIColor.purple
        var prefaceCGR: CGRect!
        var selectableCGR: CGRect!
        if let height = createAccountPrefaceLabel.superview?.frame.height { // Should be there, but does not matter because we know height
             prefaceCGR = CGRect(x: partOfScreenWidth_d(percentage: 15), y: 0, width: Double(partOfScreenWidth_d(percentage: 40)), height: Double(height))    // -> 15 to 55
             selectableCGR = CGRect(x: partOfScreenWidth_d(percentage: 58), y: 0, width: Double(partOfScreenWidth_d(percentage: 25)), height: Double(height)) // -> 60 to 85
        } else {
            let height = Double(partOfScreenHeight_d(percentage: 5))
             prefaceCGR = CGRect(x: partOfScreenWidth_d(percentage: 15), y: 0, width: Double(partOfScreenWidth_d(percentage: 40)), height: Double(height))    // -> 15 to 55
             selectableCGR = CGRect(x: partOfScreenWidth_d(percentage: 58), y: 0, width: Double(partOfScreenWidth_d(percentage: 25)), height: Double(height)) // -> 60 to 85
        }
        createAccountPrefaceLabel = UILabel(frame: prefaceCGR)
        createAccountSelectableLabel = UILabel(frame: selectableCGR)
        print("\n Created preface label at CGRect -> \n \(createAccountPrefaceLabel.frame))")
        print("\n Created selectable label at CGRect -> \n \(createAccountSelectableLabel.frame))")
        print("\n Label frame in View -> \n \(createAccountLabels.frame))")
        // Preface Label setup
        createAccountPrefaceLabel.textColor = UIColor.veryLightGray
        createAccountPrefaceLabel.text = "Not yet a member?"
        createAccountPrefaceLabel.font = UIFont(name: "Bangla Sangam MN", size: fontSizeWithScreen()*0.6)
        createAccountPrefaceLabel.minimumScaleFactor = 0.3
        createAccountPrefaceLabel.textAlignment = .right
        // End Preface Label Setup
        
        // Selectable Label setup
        createAccountSelectableLabel.textColor = UIColor.white
        createAccountSelectableLabel.text = "Sign Up"
        createAccountSelectableLabel.font = UIFont(name: "Bangla Sangam MN", size: fontSizeWithScreen()*0.62) // Very slight bit bigger
        createAccountSelectableLabel.minimumScaleFactor = 0.3
        createAccountSelectableLabel.isUserInteractionEnabled = true
        let selectRec = UITapGestureRecognizer(target: self, action: #selector(goToCreateAccount))
        createAccountSelectableLabel.addGestureRecognizer(selectRec)
        // End Selectable Label Setup
        
        // Add Labels to view
        createAccountLabels.addSubview(createAccountPrefaceLabel)
        createAccountLabels.addSubview(createAccountSelectableLabel)
        self.view.addSubview(createAccountLabels)
    }
    
    func goToCreateAccount() {
        self.goTo(storyboardName: "Auth", viewControllerName: "EmailAndPasswordVC")
    }
    
    func addStandardSignIn() {
        
        // Create Encapsulating View for Email and Password
        let cgr = CGRect(x: 0, y: 0, width: partOfScreenWidth_d(percentage: 70), height: Double(partOfScreenHeight_d(percentage: 19)))
         sView = UIView(frame: cgr)
        sView.layer.cornerRadius = 6
        sView.layer.borderColor = UIColor.white.cgColor
        sView.layer.borderWidth = 1
        sView.blur(style: .regular)
        sView.frame.centerVertically()
        sView.frame.centerHorizontally()
        self.view.addSubview(sView)
        // End 
        
        // NEXT: Create 2 textfields, create division between them, put in pictures, indent textfields to account for pictures
        let divLineCGR = CGRect(x: 0, y: 0, width: Double(partOfScreenWidth_d(percentage: 70)), height: 1)
         divLine = UIView(frame: divLineCGR)
        divLine.frame.centerHorizontally()
        divLine.frame.centerVertically()
        divLine.backgroundColor =  UIColor.white
        self.view.addSubview(divLine)
        //
        
        emailField = UITextField()
        
        emailField.initializeRectWith(image: "RC-profilePic3", width: Double(partOfScreenWidth_d(percentage: 70)))
        emailField.center = sView.center
        print();print()
        print(emailField.center)
        print(sView.center)
        emailField.textColor = UIColor.white
        emailField.frame.centerHorizontally()
        emailField.frame.dilate(y: -partOfScreenHeight_f(percentage: 5))
        emailField.placeholder = "Enter your email"
        self.view.addSubview(emailField)
        
        passField = UITextField()
        passField.initializeRectWith(image: "RC-lock", width: Double(partOfScreenWidth_d(percentage: 70)))
        passField.center = sView.center
        passField.placeholder = "Enter your password"
        passField.frame.centerHorizontally()
        passField.textColor = UIColor.white
        
        passField.frame.dilate(y: partOfScreenHeight_f(percentage: 5))
        self.view.addSubview(passField)
        //
        
        
        // Create Sign In Button
        let ssbCGR = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 65), width: partOfScreenWidth_d(percentage: 70), height: partOfScreenHeight_d(percentage: 7))
        standardSignInButton = UIButton(frame: ssbCGR)
        standardSignInButton.setTitle("Sign in", for: .normal)
        standardSignInButton.setTitleColor(.white, for: .normal)
        standardSignInButton.backgroundColor = UIColor.lightPurple
        standardSignInButton.addTarget(self, action: #selector(standardSignIn), for: .touchUpInside)
        standardSignInButton.layer.cornerRadius = 6
        standardSignInButton.frame.centerHorizontally()
        self.view.addSubview(standardSignInButton)
    }
    
    func standardSignIn() {
        if emailField.text != nil && passField.text != nil && emailField.text != "" && passField.text != "" {
            if let email = emailField.text {
                if let password = passField.text {
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user:FIRUser?, error:Error?) in
                        if user != nil {
                            self.goTo(storyboardName: "Main", viewControllerName: "RevealControllerOriginVC")
                        } else {
                            SCLAlertView().showError("Oops", subTitle: "There was an issue signing you in. Please double check your Email and Password and try again!")
                        }
                    })
                }
            }
        } else {
            SCLAlertView().showError("Oops", subTitle: "It seems that there are incomplete fields. Please double check and try again!")
        }
    }
    
    
    func addGoogleButton() {
        
        // GIDSignIn setup
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().signInSilently()
        googleSignInButton = GIDSignInButton()
        
        // UI
        googleSignInButton.frame = CGRect(x: Double(partOfScreenWidth_d(percentage: 15)), y: Double(partOfScreenHeight_d(percentage: 90)), width: Double(partOfScreenWidth_d(percentage: 30)), height: Double(partOfScreenHeight_d(percentage: 5)))
        self.view.addSubview(googleSignInButton)
    }
    
    func addFacebookButton() {
    //    let permissions: [ReadPermission]
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.delegate = self
        loginButton.frame = CGRect(x: Double(partOfScreenWidth_d(percentage: 55)), y: Double(partOfScreenHeight_d(percentage: 89.5)), width: Double(partOfScreenWidth_d(percentage: 30)), height: Double(partOfScreenHeight_d(percentage: 5.5)))
        loginButton.center.y = googleSignInButton.center.y
   //     let manager = LoginManager()
    //    manager.logIn([ .publicProfile, .email ], viewController: self) { (result: LoginResult) in
   //         <#code#>
   //     }
        view.addSubview(loginButton)
    }

    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
      //  LoginResult(). // == LoginResult.success(grantedPermissions: [ .email ], declinedPermissions: nil, token: FBSDKAccessToken.current()) //{
            
      //  }
    switch result {
    case .failed(let error):
    print(error)
    case .cancelled:
    print("\n User cancelled login.\n")
    case .success(let grantedPermissions, let declinedPermissions, let accessToken):
    print("\n Logged in! \n")
    }
    
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        // . . .
    }
    
    var googleSignInButton: GIDSignInButton!

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                divLine.frame.dilate(y: -Float(keyboardHeight/2))
                sView.frame.dilate(y: -Float(keyboardHeight/2))
                emailField.frame.dilate(y: -Float(keyboardHeight/2))
                passField.frame.dilate(y: -Float(keyboardHeight/2))
                letsGetWashing.frame.dilate(y: -Float(keyboardHeight/2))
                lavoLabel.frame.dilate(y: -Float(keyboardHeight/2))
                createAccountLabels.frame.dilate(y: -Float(keyboardHeight/2))
                standardSignInButton.frame.dilate(y: -Float(keyboardHeight/2))
            }
        }
        keyboardIsPresented = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
         //   if !keyboardIsPresented {
                if passField.frame.midY < CGFloat(partOfScreenHeight_f(percentage: 50)) {
            let keyboardHeight = keyboardSize.height
            divLine.frame.dilate(y: Float(keyboardHeight/2))
            sView.frame.dilate(y: Float(keyboardHeight/2))
            emailField.frame.dilate(y: Float(keyboardHeight/2))
            passField.frame.dilate(y: Float(keyboardHeight/2))
            letsGetWashing.frame.dilate(y: Float(keyboardHeight/2))
            lavoLabel.frame.dilate(y: Float(keyboardHeight/2))
            createAccountLabels.frame.dilate(y: Float(keyboardHeight/2))
            standardSignInButton.frame.dilate(y: Float(keyboardHeight/2))
                }
       //     }
        }
        keyboardIsPresented = false
    }
    
    func addDismissalFeature() {
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view is GIDSignInButton {
            return false
        }
        return true
    }
    
    /////////////////      END Keyboard Methods      /////////////////
    

}

extension UIViewController {
    
    func blurBackgroundView () {
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
    }
    
    func blurBackgroundView (addingImage: Bool) {
        if addingImage {
            let image = UIImage(named: "wallpaperr2") // Generic wallpaper background
            let imgView = UIImageView(image: image)
            imgView.frame = self.view.frame
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = self.view.frame
        self.view.addSubview(imgView)
        self.view.addSubview(visualEffectView)
        } else {
            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            visualEffectView.frame = self.view.frame
            self.view.addSubview(visualEffectView)
        }
    }
    
    // UI Helper Methods //
    
    func partOfScreenWidth_d(percentage: Double) -> Double{
        let mult = percentage * 0.01
        let screenSize = Double(UIScreen.main.bounds.width)
        let part = screenSize * mult
        return part
    }
    
    func partOfScreenHeight_d(percentage: Double) -> Double{
        let mult = percentage * 0.01
        let screenSize = Double(UIScreen.main.bounds.height)
        let part = screenSize * mult
        return part
    }
    
    func partOfScreenWidth_f(percentage: Float) -> Float{
        let mult = percentage * 0.01
        let screenSize = Float(UIScreen.main.bounds.width)
        let part = screenSize * mult
        return part
    }
    
    func partOfScreenHeight_f(percentage: Float) -> Float{
        let mult = percentage * 0.01
        let screenSize = Float(UIScreen.main.bounds.height)
        let part = screenSize * mult
        return part
    }
    
    // End of UI Helpers //
    
}

extension UIView {
    
    func blur(style: UIBlurEffectStyle) {
            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
            visualEffectView.frame = self.frame
            self.addSubview(visualEffectView)
    }
    
}

extension UITextField {
    
    func fontSizeWithScreenForLogin () -> CGFloat{
        // NOTE: 25 pt font works well with a 7+ Screen, this logic is to get that same proportion on an screen size
        
        return UIScreen.main.bounds.height * 0.02
    }
    
    func initializeRectWith(image named: String, width: Double) {
        
        func indentTextField(textfield: UITextField) {
            let spacerView = UIView(frame:CGRect(x:0, y:0, width:45, height:Double(UIScreen.main.bounds.height/20)))
            // Add image
            let img = UIImage(named: named)
            let imgView = UIImageView(image: img)
            imgView.frame = CGRect(x:0, y:0, width:25, height:Double(UIScreen.main.bounds.height/20))
            imgView.center = spacerView.center
            spacerView.addSubview(imgView)
            // End Add Image
            textfield.leftViewMode = UITextFieldViewMode.always
            textfield.leftView = spacerView
        }
        
        var cgr = CGRect(x: 0,y:0, width: width, height: Double(UIScreen.main.bounds.height/20))
        cgr.centerHorizontally()
        cgr.centerVertically()
        self.frame = cgr
        indentTextField(textfield: self)
        self.font = UIFont(name: "Bangla Sangam MN", size: fontSizeWithScreenForLogin())
        self.layer.cornerRadius = 5
    }
    
}

extension UIColor {
    
    class var lightPurple: UIColor {
        get {
            return UIColor(red: 193/255, green: 195/255, blue: 232/255, alpha: 1)
        }
    }
    
    class var veryLightGray: UIColor {
        get {
            return UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
        }
    }
    
    class var veryVeryLightGray: UIColor {
        get {
            return UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        }
    }
    
}
