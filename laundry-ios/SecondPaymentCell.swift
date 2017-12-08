//
//  SecondPaymentCell.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 11/22/17.
//  Copyright © 2017 Lavo Logistics. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import PromiseKit
import SCLAlertView
import CoreLocation

class SecondPaymentCell: UITableViewCell, /*UITableViewDelegate, UITableViewDataSource,*/ STPPaymentContextDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
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
        
        // Initialization code
        let apiKeyObject = MainAPI.shared
        customerContext = STPCustomerContext(keyProvider: apiKeyObject)
        
        setupPaymentContext()
    }

    var sourceIDs = [String] () // IDs
    var cardInfos = [String] () // Last 4 digits array
    var paypalEmail: String?
    var selectedPaymentSource: String? // ID
    var paymentContext: STPPaymentContext!
    
    var navigationController: UINavigationController?
    
    // unused
    var customerContext: STPCustomerContext!
    
    @IBAction func back(_ sender: Any) {
        delegate.paymentScreenBackPressed()
    }
    
    //  Delegate
    var delegate: paymentDelegate!
    
//    @IBOutlet weak var savedCardsTableView: UITableView!

    // Unused for now
    @IBAction func applyPromoCode(_ sender: Any) {
        // unused right now
    }
    
    @IBAction func selectPayment(_ sender: Any) {
      //  setupPaymentContext()
        presentPaymentContext()
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
        paymentContext.paymentAmount = 100
        if let vc = self.parentViewController {
            paymentContext.hostViewController = vc
        }
        
//        if let topController = UIApplication.shared.keyWindow?.rootViewController{
//            print("topController being made hostViewController . . .")
//            
//            paymentContext.hostViewController = topController
//        } else {        }
        
     ///   presentPaymentContext()
    }
    
    func presentPaymentContext() {
        paymentContext.presentPaymentMethodsViewController()
    }
    
    @IBAction func placeOrder(_ sender: Any) {
        if paymentContext != nil {
            
        }
        if let method = paymentContext.selectedPaymentMethod {
            paymentContext.requestPayment()
            delegate.OrderPressed(cell: self)
        } else {
            // Error
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        return cardInfos.count
//        
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = Bundle.main.loadNibNamed("savedCreditCardCell", owner: self, options: nil)?.first as! savedCreditCardCell
//        
//        cell.last4.text = cardInfos[indexPath.row]
//        
//        return cell
//        
//    }
//    
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedIndex = indexPath.row
//        let selected = sourceIDs[selectedIndex] // selected
//        selectedPaymentSource = selected
//        
//    }

    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("paymentContextDidChange")
     //   self.activityIndicator.animating = paymentContext.loading
     //   self.paymentButton.enabled = paymentContext.selectedPaymentMethod != nil
     //   self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
     //   self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
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
        case .success:
            self.showComplete()
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
        if let vc = self.parentViewController {
            vc.present(UIAlertController(message: "Could not retrieve customer information", retryHandler: { (action) in
                // Retry payment context loading
                paymentContext.retryLoading()
            }), animated: true)
        }
        
        
    }
    
    func showError() {
        SCLAlertView().showError("Oops", subTitle: "Something went wrong in youe purchase!")
    }
    
    func showComplete() {
        SCLAlertView().showSuccess("Ordered!", subTitle: "Your Order has been placed!")
    }
    
}
extension SecondPaymentCell:STPAddCardViewControllerDelegate {
    
    func showAddCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // STPAddCardViewController must be shown inside a UINavigationController.
         navigationController = UINavigationController(rootViewController: addCardViewController)
        
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
                        if let vc = self.parentViewController {
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
                                        if let vc = self.parentViewController {
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


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension SecondPaymentCell {
    
    func createOrder(finished: @escaping (_ success: Bool) -> ()) {
        let ud = UserDefaults.standard
        ud.set(" ", forKey: "StandardOrExpress")
        ud.set(" ", forKey: "dryCleaningCheckBox")
        
        if let express = ud.object(forKey: "isExpress") as? Bool, let laundry = ud.object(forKey: "isLaundry") as? Bool, let onDemand = ud.object(forKey: "isOnDemand") as? Bool, let address = ud.object(forKey: "address") as? String, let clientId = FIRAuth.auth()?.currentUser?.uid, let prefs = ud.object(forKey: "specialPreferences") as? String, let price = ud.object(forKey: "price") {
            
            // un-geocode address
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        // handle no location found
                        finished(false)
                        return
                }
                if let pm = placemarks.first {
                    if let street = pm.thoroughfare, let city = pm.locality, let state = pm.administrativeArea, let zip = pm.postalCode {
                        
                        // Address Info Good
                        let h = HomeAddress(aStreetAddress: street, aCity: city, aState: state, aZip: zip, aptNumber: nil)
                        h.getGeo(finished: { (success) in
                            if success {
                                
                                // Check Ordering Situation
                                if onDemand {
                                    let order = Order()
                                    order.orderID = firebase.childByAutoId().key
                                    order.clientID = clientId
                                    order.isOnDemand = onDemand
                                    order.location = h
                                    order.isExpress = express
                                    order.isLaundry = laundry
                                    order.specialPreferences = prefs
                                    order.review = OrderReview() // Changed later when order comes back
                                    order.status = OrderStatus.readyForPickup
                                    order.price = 15 // Algorithm should be here
                                    //   order.scheduledTimes
                                    
                                } else {
                                    let order = Order()
                                    order.orderID = firebase.childByAutoId().key
                                    order.clientID = clientId
                                    order.isOnDemand = onDemand
                                    order.location = h
                                    order.isExpress = express
                                    order.isLaundry = laundry
                                    order.specialPreferences = prefs
                                    order.review = OrderReview() // Changed later when order comes back
                                    order.status = OrderStatus.readyForPickup
                                    order.price = 15 // Algorithm should be here
                                    var inv = Inventory()
                                    
                                    // init inventory
                                    if laundry {
                                        if let bags = ud.integer(forKey: "bagCount") as? Int{
                                            inv.bagCount = bags
                                        } else { /* Error */ }
                                    } else {
                                        if let shirts = ud.integer(forKey: "numShirts") as? Int, let pants = ud.integer(forKey: "numPants") as? Int,  let ties = ud.integer(forKey: "numTies") as? Int, let suits = ud.integer(forKey: "numSuits") as? Int, let jackets = ud.integer(forKey: "numJackets") as? Int, let dresses = ud.integer(forKey: "numDresses") as? Int {
                                            inv.numSuits = suits; inv.numTies = ties; inv.numShirts = shirts; inv.numPants = pants; inv.numDresses = dresses; inv.numJackets = jackets;
                                        }
                                    }
                                    order.inventory = inv
                                    
                                    // init scheduled orders
                                    if let orderDates = ud.array(forKey: "scheduledOrderDates") as? [String] {
                                        for date in orderDates {
                                            order.scheduledTimes?.append(date)
                                        }
                                        
                                    } else if let dayOfWeek = ud.object(forKey: "scheduledDayOfWeek") as? String, let dowTime = ud.object(forKey: "scheduledDayOfWeekTime") as? String {
                                        order.scheduledTimes?.append("\(dayOfWeek) at \(dowTime)")
                                    }
                                    
                                    
                                    // Create Order
                                    
                                    order.findLaundromat(finished: { (success) in
                                        if success {
                                            order.dbCreate(finished: { (success) in
                                                
                                                if success {
                                                    
                                                    // Charge User:
                                                    //    1. Create User
                                                    //    2. Add Payment Method
                                                    //    3. Pay
                                                    
                                                    func postCharge(id customerId: String) {
                                                        let orderPrice = Int(order.price!) * 100 // Converted
                                                        API.postCharge(customerId: customerId, amount: orderPrice)
                                                            .then { res -> Void in
                                                                print("Charge Result:")
                                                                print(res)
                                                            }.catch { err in print(err.localizedDescription) }
                                                    }
                                                    
                                                    let client = Client(id: clientId)
                                                    
                                                    client.getStripeCustomerId(finished: { (stripeIdTokenString) in
                                                        if let id = stripeIdTokenString {
                                                            postCharge(id: id)
                                                            order.dbCreate(finished: { (good) in
                                                                if good {
                                                                    
                                                                } else {
                                                                   finished(false)
                                                                }
                                                            })
                                                            order.moveToOpenOrders()
                                                        } else {
                                                            client.dbFill {
                                                                
                                                                // We now have Client info
                                                                if let email = client.email {
                                                                    API.postNewCustomer(email: email).then { res -> Void in
                                                                        print("Result")
                                                                        print(res)
                                                                        let customerId = res["customerId"] as! String;
                                                                        client.stripeCustomerId = customerId
                                                                        client.storeStripeCustomerId(finished: { (stored) in
                                                                            finished(true)
                                                                        })
                                                                        
                                                                        // charge
                                                                        postCharge(id: customerId)
                                                                        
                                                                        }.catch { err in print(err.localizedDescription)
                                                                        finished(false)
                                                                    }
                                                                    
                                                                } else {
                                                                    print("Error code 5")
                                                                    // Error
                                                                    finished(false)
                                                                }
                                                                order.moveToOpenOrders()
                                                                
                                                            }}})
                                                } else {
                                                    // Error
                                                    print("Error code 4")
                                                    finished(false)
                                                }
                                            })
                                        } else {
                                            // Error
                                            print("Error code 3")
                                            finished(false)
                                        }})}} })
                    } else {
                        // Error
                        print("Error code 2")
                        finished(false)
                    }
                    
                } else {
                    // Error
                    print("Error code 1")
                    finished(false)
                }
                // Use your location
            }
        }
        
    }
    
}

