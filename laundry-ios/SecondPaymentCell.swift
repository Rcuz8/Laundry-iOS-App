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

class SecondPaymentCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource/*, STPPaymentContextDelegate*/ {

    override func awakeFromNib() {
        super.awakeFromNib()
        if let uid = FIRAuth.auth()?.currentUser?.uid {
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
        paymentContext = STPPaymentContext(customerContext: customerContext)
        
    }

    var sourceIDs = [String] () // IDs
    var cardInfos = [String] () // Last 4 digits array
    var paypalEmail: String?
    var selectedPaymentSource: String? // ID
    var paymentContext: STPPaymentContext!
    
    // unused
    var customerContext: STPCustomerContext!
    
    @IBAction func back(_ sender: Any) {
        delegate.paymentScreenBackPressed()
    }
    
    //  Delegate
    var delegate: paymentDelegate!
    
    @IBOutlet weak var savedCardsTableView: UITableView!
    
    
    
    @IBAction func addNewPayment(_ sender: Any) {
        showAddCard()
    }
    // Unused for now
    @IBAction func applyPromoCode(_ sender: Any) {
        paymentContext.presentPaymentMethodsViewController()
      //  self.addSubview(paymentContext)
    }
    
    
    @IBAction func placeOrder(_ sender: Any) {
        delegate.OrderPressed(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cardInfos.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("savedCreditCardCell", owner: self, options: nil)?.first as! savedCreditCardCell
        
        cell.last4.text = cardInfos[indexPath.row]
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        let selected = sourceIDs[selectedIndex] // selected
        selectedPaymentSource = selected
        
    }

    
//    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
//     //   self.activityIndicator.animating = paymentContext.loading
//     //   self.paymentButton.enabled = paymentContext.selectedPaymentMethod != nil
//     //   self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
//     //   self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
//    }
//    
//    func paymentContext(_ paymentContext: STPPaymentContext,
//                        didCreatePaymentResult paymentResult: STPPaymentResult,
//                        completion: @escaping STPErrorBlock) {
//        API.postCharge(customerId: <#T##String#>, amount: <#T##Int#>)
//        MainAPI.createCharge(paymentResult.source.stripeID, completion: { (error: Error?) in
//            if let error = error {
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        })
//    }
//    func paymentContext(_ paymentContext: STPPaymentContext,
//                        didFinishWithStatus status: STPPaymentStatus,
//                        error: Error?) {
//        
//        switch status {
//        case .error:
//            self.showError(error)
//        case .success:
//            self.showReceipt()
//        case .userCancellation:
//            return // Do nothing
//        }
//    }
//    
//    func paymentContext(_ paymentContext: STPPaymentContext,
//                        didFailToLoadWithError error: Error) {
//        self.navigationController?.popViewController(animated: true)
//        // Show the error to your user, etc.
//    }
    
}
extension SecondPaymentCell:STPAddCardViewControllerDelegate {
    
    func showAddCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // STPAddCardViewController must be shown inside a UINavigationController.
        let navigationController = UINavigationController(rootViewController: addCardViewController)

        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            if let presentedViewController = topController.presentedViewController {
                presentedViewController.present(navigationController, animated: true, completion: nil)
            } else {
                print("cannot find presentedViewController")
                topController.present(navigationController, animated: true, completion: nil)
            }
        } else {
            print("cannot find topController")
        }
    }
    
    func saveCard(token: STPToken) {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let client = Client(id: uid)
            client.getStripeCustomerId(finished: { (customerId) in
                if let id = customerId {
                    API.postNewCard(customerId: id, token: token).then { res -> Void in
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
                        .catch { err in print(err.localizedDescription) }
                }
            })
        }
        
        
    }
    
    
    // MARK: STPAddCardViewControllerDelegate
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
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
