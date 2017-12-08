//
//  AppDelegate.swift
//  laundry-ios
//
//  Created by Lavo Logistics Inc on 03/05/2017.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import Firebase
import GoogleSignIn
import Google
import FacebookLogin
import FBSDKCoreKit
import SCLAlertView
import FBSDKLoginKit
import IQKeyboardManagerSwift

let firebase = FIRDatabase.database().reference() // --> This is the FirebaseDatabase variable used throughout the rest of the application

var stripe_customer_id: String?

var firebaseId: String? {
    get {
        if let id = FIRAuth.auth()?.currentUser?.uid {
            return id
        } else { return nil }
    }
}

var firebaseUser: FIRUser? {
    get {
        if let user = FIRAuth.auth()?.currentUser {
            return user
        } else { return nil }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , GIDSignInDelegate {

    var window: UIWindow?

    /**
     Fill in your Stripe publishable key here. This can be either your
     test or live publishable key. The key should begin with "pk_".
     
     You can find your publishable key in the Stripe Dashboard after you've
     signed up for an account.
     
     @see https://dashboard.stripe.com/account/apikeys
     
     If you'd like to use this app with https://rocketrides.io (see below),
     you can use our test publishable key: "pk_test_hnUZptHh36jRUveejCXqRoVu".
     */
    private let publishableKey: String = "pk_test_lg4KhXtxw5kCceuSCGEz2k8M"
    
    /**
     Fill in your backend URL here to try out the full payment experience
     
     Ex: "http://localhost:3000" if you're running the Node server locally,
     or "https://rocketrides.io" to try the app using our hosted version.
     */
    private let baseURLString: String = ""
    
    /**
     Optionally, fill in your Apple Merchant identifier here to try out the
     Apple Pay payment experience. We can use the "merchant.xyz" placeholder
     here when testing in the iOS simulator.
     
     @see https://stripe.com/docs/apple-pay/apps
     */
    private let appleMerchantIdentifier: String = "merchant.com.lavologistics.clientTransactions"

    
    
    
    override init() {
        super.init()
        FIRApp.configure() //this is the changed version.
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        Stripe.setDefaultPublishableKey("pk_test_lg4KhXtxw5kCceuSCGEz2k8M")
        STPPaymentConfiguration.shared().publishableKey = publishableKey
        STPPaymentConfiguration.shared().appleMerchantIdentifier = appleMerchantIdentifier
        STPPaymentConfiguration.shared().companyName = "Lavo Logistics"

        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
       self.window!.makeKeyAndVisible()
      //  signOutOfFirebase()
        
        let facebookAppID = "712223508956296"
        FBSDKSettings.setAppID(facebookAppID)
        
        setupFIrebaseAuthStateListener()
        
        if let id = firebaseId {
            let client = Client(id: id)
            client.getStripeCustomerId(finished: { (cust_id) in
                if cust_id != nil {
                    stripe_customer_id = cust_id
                }
            })
        }
        
        
    }
    
    func toAuth() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let to = storyboard.instantiateViewController(withIdentifier: "mNameVC") // We already have their email & password
        self.window!.rootViewController = to
    }
    
    func requestInfo() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Verify", action: {
            self.toAuth()
        })
        alert.showError("Oops", subTitle: "We don't quite have all your information, please verify your information in the following steps")
    }
    
    func toMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let to = storyboard.instantiateViewController(withIdentifier: "RevealControllerOriginVC")
        self.window!.rootViewController = to
    }
    
    func setupFIrebaseAuthStateListener() {
        FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user: FIRUser?) in
            if user != nil {
                print("\nAppDelegate: setupFirebaseAuthStateListener:   ✅ : Firebase Sign In   \n")
                    print("AppDelegate: setupFirebaseAuthStateListener: vc initialized")
                        let client = Client(id: user!.uid)
                   //     print(client.simpleDescription())
                    client.dbFill2 {
                        print("AppDelegate: setupFirebaseAuthStateListener: client finished filling")
                        if client.valid() {
                            print("✅ Client is valid!")
                            self.toMain()
                        } else {
                            print("❌ Client needs more information!")
                            self.requestInfo() }
                    }
            } else { print("AppDelegate: setupFirebaseAuthStateListener: user is nil") }
        })
    }
    
    

    
    // Google User Signs in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        print("Google User did sign in")
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (fireUser:FIRUser?, error:Error?) in
            if user != nil {
                print("\nAppDelegate: sigIn(GID):   ✅ : Firebase Sign In   \n")
                if let vc = self.window!.rootViewController {
                    let client = Client(id: fireUser!.uid)
                    client.dbFill {
                        print("AppDelegate: sigIn(GID): client finished filling")
                   //     print(client.simpleDescription())
                        if client.valid() {
                            self.toMain()
                        } else { self.requestInfo() }
                    }}}
        })
        
        printSignIn(signInType: 1)
    }
 
    // Handles Sign In
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            
            // Should
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func printSignIn(signInType: Int) {
        switch signInType {
        case 1:
            print("\n\n\nUser Signed in using Option 1 Google Sign In")
        case 2:
            print("\n\n\nUser Signed in using Option 2 Google Sign In")
        default:
            print("\n\n\nI have no idea how the user signed in")
        }
    }
    
    
    // App Finishes Launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        // End of Google Sign-In
        
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions:launchOptions)
        
        IQKeyboardManager.sharedManager().enable = true
        
        return true
    }
    
    // [START old_delegate]
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // [END old_delegate]
        if GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication: sourceApplication,
                                             annotation: annotation) {
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     // [START old_options]
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    // [END old_options]
    
    
    // Google User Disconnects
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }


    func signOutOfFirebase() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

    func showMessage(message: String) {
        let alertController = UIAlertController(title: "Lavo", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        
        presentedViewController.present(alertController, animated: true, completion: nil)
    }
    var contactStore = CNContactStore()
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message: message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

extension UIViewController {
    
    // Begin SIGN OUT classes //
    func signOutOfFirebase() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func signOutOfGoogle() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func signOutOfFacebook() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
    // End SIGN OUT classes //
    
}


 public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
}
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
