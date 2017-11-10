//
//  mLoginViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/15/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import FacebookLogin
import GoogleSignIn
import SCLAlertView
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import Hero
class mLoginViewController: UIViewController, GIDSignInUIDelegate, LoginButtonDelegate {

    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGoogleButton()
        
    }
    

    
    @IBAction func signIn(_ sender: Any) {
        if let email = emailTF.text, let password = passTF.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil { self.showOops() } else {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RevealControllerOriginVC")
                    vc.heroModalAnimationType = HeroDefaultAnimationType.zoom
                    self.present(vc, animated: true, completion: nil)

                }
            })
        } else { self.showOops() }
    }
    
    func addGoogleButton() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        googleSignInButton = GIDSignInButton()
        googleSignInButton.frame = CGRect(x: 0, y: 0, width: 1, height: 1); googleSignInButton.alpha = 0;
        self.view.addSubview(googleSignInButton)
    }
    
    func showOops() {
       SCLAlertView().showError("Oops", subTitle: "There was an issue signing you in. Please double check your Email and Password and try again!")
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
    
    @IBAction func signInGoogleAction(_ sender: Any) {
                googleSignInButton.sendActions(for: UIControlEvents.touchUpInside)
    }
    func loginButtonDidLogOut(_ loginButton: LoginButton) { }

    @IBAction func loginFacebookAction(sender: AnyObject) {
        getFacebookUserInfo()
    }
    
    func getFacebookUserInfo(){
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email ], viewController: self) { (result) in
            switch result{
            case .cancelled:
                print("Cancel button click")
            case .success:
                let params = ["fields" : "id, name, first_name, last_name, picture.type(large), email "]
                let graphRequest = FBSDKGraphRequest.init(graphPath: "/me", parameters: params)
                let Connection = FBSDKGraphRequestConnection()
                Connection.add(graphRequest) { (Connection, result, error) in
                    let info = result as! [String : AnyObject]
                    if let first = info["first_name"] as? String, let last = info["last_name"] as? String, let email = info["email"] as? String, let id = info["id"] as? String {
                        let cl = Client(id: id)
                        cl.dbFill {
                            if cl.valid() {
                                self.goTo(storyboardName: "Main", viewControllerName: "RevealViewControllerVC", animated: true, presentationStyle: .fullScreen)
                            } else {
                                let def = UserDefaults.standard
                                def.set(first, forKey: "firstName")
                                def.set(last, forKey: "lastName")
                                def.set(email, forKey: "email")
                                def.synchronize()
                                self.showMoreInfoAlert()
                            }
                        }
                        
                    }
                    
                }
                Connection.start()
                
            default:
                print("??")
            }
        }
    }
    
    
    @IBAction func toCreateAccountFlow(_ sender: Any) {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "mNameVC") as! mNameViewController
        vc.heroModalAnimationType = HeroDefaultAnimationType.push(direction: .left)
        self.present(vc, animated: true, completion: nil)

    }
    
    var googleSignInButton: GIDSignInButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMoreInfoAlert() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Verify", action: {
            self.goTo(storyboardName: "Auth", viewControllerName: "mNameVC")
        })
        alert.showError("Oops", subTitle: "We don't quite have all your information, please verify your information in the following steps")
    }
    


}
