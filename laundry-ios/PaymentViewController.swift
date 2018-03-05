//
//  PaymentViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 2/12/18.
//  Copyright © 2018 Lavo Logistics. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import PromiseKit
import SCLAlertView
import CoreLocation


class PaymentViewController: UIViewController, STPPaymentContextDelegate {

    
    var sourceIDs = [String] () // IDs
    var cardInfos = [String] () // Last 4 digits array
    var paypalEmail: String?
    var selectedPaymentSource: String? // ID
    var paymentContext: STPPaymentContext!
    var hostViewController : UIViewController!
    var customerContext: STPCustomerContext!
    
 
    
    override func viewDidLoad() {
        
        if let uid = firebaseId {
            let client = Client(id: uid)
            client.getStripeSources(finished: { (sources, cardInfos) in
                if !sources.isEmpty {
                    self.sourceIDs = sources
                }
                if !cardInfos.isEmpty {
                    self.cardInfos = cardInfos
                }
            })
        }
        
        let apiKeyObject = MainAPI.shared
        customerContext = STPCustomerContext(keyProvider: apiKeyObject)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self

       
        setupPaymentContext()
        presentPaymentContext()
        //paymentContext.presentPaymentMethodsViewController()
        
        
    }
    
    func setupPaymentContext() {
        
        
        
        
        
        let config = STPPaymentConfiguration()
        config.appleMerchantIdentifier = "merchant.com.lavologistics.clientTransactions"
        config.companyName = "Lavo Logistics"
        config.publishableKey = "pk_test_lg4KhXtxw5kCceuSCGEz2k8M"
        config.shippingType = .delivery;
        config.verifyPrefilledShippingAddress = false
        
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        //  paymentContext.paymentAmount = 100

        
        
        if let total = UserDefaults.standard.double(forKey: "orderTotal") as? Double {
           // totalLbl.text = "$\(total)"
            paymentContext.paymentAmount = Int(total*100)
            
        }
    }
    
    func presentPaymentContext() {
        if let host = paymentContext.hostViewController, let total = UserDefaults.standard.double(forKey: "orderTotal") as? Double {
            SCLAlertView().showError("AYYYY", subTitle: " found your view's host!!!")
            paymentContext.paymentAmount = Int(total*100)
            paymentContext.presentPaymentMethodsViewController()
            
        } else {
            SCLAlertView().showError("Oops", subTitle: "Cannot find your view's host! Please try again later!")
        }
        
        
        //paymentContext.presentPaymentMethodsViewController()
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didCreatePaymentResult paymentResult: STPPaymentResult,
                        completion: @escaping STPErrorBlock) {
        print("didCreatePaymentResult")
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let client = Client(id: uid)
            client.getStripeCustomerId(finished: { (customerId) in
                if let id = customerId {
                    let res = API.createCharge(customerId: id, amount: paymentContext.paymentAmount, source: paymentResult.source.stripeID)
                    completion(nil)
                } else {
                    completion(nil)
                }
            })
        }
        
    }
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFinishWith status: STPPaymentStatus,
                        error: Error?) {
        print("didFinishWithStatus")
        print(status)
        switch status {
        case .error:
            self.showError()
            break
            
        case .success:
            self.showComplete()
            break
            
        case .userCancellation:
            return // Do nothing
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        print("didUpdateShippingAddress")
        //
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFailToLoadWithError error: Error) {
        
        print("didFailToLoadWithError()")
        print("Presenting Error info . . .")
        print("\n - - - - - -")
        print(error)
        print(error.localizedDescription)
        print("\n - - - - - -")
        if let vc = self.parent {
            vc.present(UIAlertController(message: "Could not retrieve customer information", retryHandler: { (action) in
                // Retry payment context loading
                paymentContext.retryLoading()
            }), animated: true)
        }
        
        
    }

    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("paymentContextDidChange")
        //   self.activityIndicator.animating = paymentContext.loading
        //   self.paymentButton.enabled = paymentContext.selectedPaymentMethod != nil
        //   self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
        //   self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
    }
    
    
}
extension PaymentViewController:STPAddCardViewControllerDelegate {
    
    func showAddCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // STPAddCardViewController must be shown inside a UINavigationController.
        //navigationController = UINavigationController(rootViewController: addCardViewController)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController, let nav = self.navigationController {
            if let presentedViewController = topController.presentedViewController {
                presentedViewController.present(nav, animated: true, completion: nil)
            } else {
                print("cannot find presentedViewController")
                topController.present(nav, animated: true, completion: nil)
            }
        } else {
            print("cannot find topController")
        }
    }
    
    func saveCard(token: STPToken) {
        if let uid = firebaseId {
            let client = Client(id: uid)
            client.getStripeCustomerId(finished: { (customerId) in
                if let id = customerId {
                    
                    API.postNewCard(customerId: id, token: token).then { res -> Void in
                        if let vc = self.parent {
                            vc.dismiss(animated: true, completion: {
                                SCLAlertView().showSuccess("Done", subTitle: "Your card has been added!")
                            })
                        }
                        
                        }
                        .catch { err in print(err.localizedDescription) }
                } else {
                    // New Customer
                    client.dbFill {
                        if let email = client.email {
                            API.postNewCustomer(email: email).then(execute: { res -> Void in
                                print("JSON Response: \n- - - - - - -\(res)\n - - - - - - - ")
                                if let id = res["customerId"] as? String {
                                    print("found customer id!")
                                    client.stripeCustomerId = id
                                    client.storeStripeCustomerId(finished: { (success) in
                                        if let vc = self.parent {
                                            vc.dismiss(animated: true, completion: {
                                                SCLAlertView().showSuccess("Done", subTitle: "Your card has been added!")
                                            })
                                        }
                                    })
                                } else {
                                    print("Couldnt find  customer id!!")
                                }
                            })
                        }
                        
                    }
                    
                }
            })
        }
        
        
    }
    
    
    // MARK: STPAddCardViewControllerDelegate
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        addCardViewController.dismiss(animated: true, completion: nil)
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            if let presentedViewController = topController.presentedViewController {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                print("cannot find presentedViewController")
                topController.dismiss(animated: true, completion: nil)
            }
        } else {
            print("cannot find topController")
        }
    }
    
    func showError() {
        SCLAlertView().showError("Oops", subTitle: "Something went wrong in youe purchase!")
    }
    
    func showComplete() {
        SCLAlertView().showSuccess("Ordered!", subTitle: "Your Order has been placed!")
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        print("TOKEN: \(token)")
        saveCard(token: token)
        print(token.stripeID)
        // get token to be saved
        let tokenString  = token.tokenId
        if let last4 = token.card?.last4 {
            savePaymentToken(tokenString: tokenString, last4digits: last4, completion: { (success) in
                completion(nil)
            })
        } else { completion(nil) } // error though
        
    }
    
    func savePaymentToken(tokenString token: String, last4digits last4: String, completion: @escaping (_ success: Bool) -> ()) {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let client = Client(id: uid)
            client.storeStripeSource(withID: token, last4digits: last4, finished: { (success) in
                completion(success)
            })
        } else {
            completion(false)
        }
    }
    
}
