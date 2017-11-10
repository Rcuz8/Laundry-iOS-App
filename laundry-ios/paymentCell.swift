//
//  paymentCell.swift
//  TBVIEW
//
//  Created by Anagh Telluri on 8/11/17.
//  Copyright © 2017 Anagh Telluri. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import Firebase
import Stripe


protocol paymentDelegate {
    func OrderPressed(cell: paymentCell)
    func paymentScreenBackPressed()
}




class paymentCell: UITableViewCell, UITextFieldDelegate, STPPaymentCardTextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    
    var payment : [STPToken]!
    
    @IBOutlet weak var paymentSegments: UISegmentedControl!
    
    @IBOutlet weak var savedCardsTableView: UITableView!
    @IBOutlet weak var bothPaymentBackgroundView: UIView!
    @IBOutlet weak var paypalView: UIView!
    @IBOutlet weak var paypalSubmitButton: UIButton!
    @IBOutlet weak var paypalEmailTextField: UITextField!
    @IBOutlet weak var paypalPasswordTextField: UITextField!
    
    @IBOutlet weak var creditDebitView: UIView!
    // @IBOutlet weak var submitPaymentButtonStripe: UIButton!
    
    let paymentTextField = STPPaymentCardTextField()
    
    @IBOutlet weak var promoCodeTextField: UITextField!
    @IBOutlet weak var promoCodeApplyButton: UIButton!
    
    @IBOutlet weak var orderButton: UIButton!
    var delegate : paymentDelegate?
    
    @IBOutlet weak var personalOutlet: UIButton!
    
    
    
    @IBAction func personalPressed(_ sender: Any) {
        
        
        savedCardsTableView.isHidden = false
        
        
    }
    
    //@IBOutlet weak var paymentSegments: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //submitStripePaymentSetup()
        
        savedCardsTableView.isHidden = true
        
        
        submitPaypalPaymentSetup()
        
        promoCodeSetup()
        
        paypalUsernameTextFieldSetup()
        
        paypalPasswordTextFieldSetup()
        
        orderButtonSetup()
        
        creditDebitView.isHidden = true
        
        paypalView.isHidden = true
        
        savedCardsTableView.dataSource = self
        savedCardsTableView.delegate = self
        
        
        
        bothPaymentBackgroundView.layer.masksToBounds = true
        bothPaymentBackgroundView.layer.cornerRadius = 12
        
        creditDebitView.layer.masksToBounds = true
        
        creditDebitView.layer.cornerRadius = 12
        
        personalOutlet.layer.masksToBounds = true
        personalOutlet.layer.cornerRadius = 12
        
        
        
        payment = []
        
        //personalOutlet.setTitle(UserDefaults.standard.object(forKey: "t") as! String, for: .normal)
        
        if let id = FIRAuth.auth()?.currentUser?.uid {
            let client = Client(id: id)
            client.getStripeSources(finished: { (unwrappedSources) in
                if let sources = unwrappedSources {
                for source in sources {
                    if let email = source.email { self.paypalEmail = email }
                    self.sourceIDs.append(source.sourceID)
                    if let cardNums = source.last4digits { self.cardInfos.append(cardNums) }
                }
                }
            })
        }
        
        
    }
    
    var sourceIDs = [String] ()
    var cardInfos = [String] ()
    var paypalEmail: String?
    var selectedPaymentSource: String?
    
    func submitPaypalPaymentSetup(){
        
        
        paypalSubmitButton.layer.cornerRadius = 10
        paypalSubmitButton.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        paypalSubmitButton.layer.borderWidth = 2.0
        
    }
    
    
    
    
    func promoCodeSetup(){
        
        
        promoCodeApplyButton.layer.borderWidth = 2.0
        promoCodeApplyButton.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        promoCodeApplyButton.layer.cornerRadius = 10
        
        promoCodeTextField.backgroundColor = UIColor.clear
        
        
        let borderWidth:CGFloat = 2.0 // what ever border width do you prefer
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0.0,y:   promoCodeTextField.frame.height - borderWidth, width:  promoCodeTextField.frame.width, height:  promoCodeTextField.frame.height )
        
        bottomLine.backgroundColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        
        promoCodeTextField.layer.addSublayer(bottomLine)
        promoCodeTextField.layer.masksToBounds = true // the most important line of code
        
        
    }
    
    
    func paypalUsernameTextFieldSetup(){
        
        
        let borderWidth:CGFloat = 2.0 // what ever border width do you prefer
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0.0,y:  paypalEmailTextField.frame.height - borderWidth, width: paypalEmailTextField.frame.width, height: paypalEmailTextField.frame.height )
        
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        paypalEmailTextField.layer.addSublayer(bottomLine)
        paypalEmailTextField.layer.masksToBounds = true // the most important line of code
        
        
    }
    
    
    
    func paypalPasswordTextFieldSetup(){
        
        
        
        let borderWidth:CGFloat = 2.0 // what ever border width do you prefer
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0.0,y:  paypalPasswordTextField.frame.height - borderWidth, width: paypalPasswordTextField.frame.width, height: paypalPasswordTextField.frame.height )
        
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        paypalPasswordTextField.layer.addSublayer(bottomLine)
        paypalPasswordTextField.layer.masksToBounds = true // the most important line of code
        
        
    }
    
    func stripeTextFieldSetup(){
        
        paymentTextField.layer.borderWidth = 0
        
        paymentTextField.frame = CGRect(x: 5, y: 10, width:creditDebitView.frame.width-10, height: 50)
        self.creditDebitView.addSubview(paymentTextField)
        paymentTextField.delegate = self
        // submitPaymentButtonStripe.isHidden = true
        
        let borderWidth:CGFloat = 2.0 // what ever border width do you prefer
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0.0,y:   paymentTextField.frame.height - borderWidth, width:  paymentTextField.frame.width, height:  paymentTextField.frame.height )
        
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        paymentTextField.layer.addSublayer(bottomLine)
        paymentTextField.layer.masksToBounds = true // the most important line of code
        
    }
    
    func orderButtonSetup(){
        
        orderButton.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        orderButton.layer.borderWidth = 2.0
        
        orderButton.layer.cornerRadius = 10
        
        
        
        
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        
        delegate?.paymentScreenBackPressed()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        
        
        if(paymentSegments.selectedSegmentIndex == 0){
            
            
            paypalView.isHidden = true
            creditDebitView.isHidden = false
            stripeTextFieldSetup()
            
            
        }
        else if(paymentSegments.selectedSegmentIndex == 1){
            
            creditDebitView.isHidden = true
            paypalView.isHidden = false
            
            
        }
        else if(paymentSegments.selectedSegmentIndex == 2){
            
            creditDebitView.isHidden = true
            paypalView.isHidden = true
            
        }
    }
    
    
    /////////////Payent stripe methods/////////////
    
    
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        
        if(textField.isValid){
            SCLAlertView().showSuccess("Verified", subTitle: "Your payment has been verified and you are now ready to place your order!")
            
            self.paymentTextField.resignFirstResponder()
            
        }
        
    }
    
    
    
    
    func createCustomerWithoutSource(){
        
        //works
        
        let requestString = "https://secret-atoll-43300.herokuapp.com/addCustomer.php"
        let params = ["stripeSource": "" , "amount": "100", "currency": "usd", "description": "testRunCustomer", "customerID": ""]
        
        
        
        _ = Alamofire.request(requestString, method: .post, parameters: params)
        
        
        
        
        
    }
    
    func createCustomerWithSource(){
        
        //works
        
//        let card = paymentTextField.cardParams
//        
//        let sourceParams = STPSourceParams.cardParams(withCard: card)
//        
//        
//        STPAPIClient.shared().createSource(with: sourceParams){ (source, error) in
//            if let s = source, s.flow == .none && s.status == .chargeable {
//                
//                let requestString = "https://secret-atoll-43300.herokuapp.com/addCustomerWithSource.php"
//                let params = ["stripeSource": s.stripeID , "amount": "100", "currency": "usd", "description": "testRunCustomer", "customerID": ""]
//                
//                
//                
//                _ = Alamofire.request(requestString, method: .post, parameters: params)
//                
//                
//                
//            }
//            
//        }
        
    }
    
    
    func addSource(){
        //works
//        
//        let card = paymentTextField.cardParams
//        
//        let sourceParams = STPSourceParams.cardParams(withCard: card)
//        
//        
//        STPAPIClient.shared().createSource(with: sourceParams){ (source, error) in
//            if let s = source, s.flow == .none && s.status == .chargeable {
//                
//                let requestString = "https://secret-atoll-43300.herokuapp.com/addSource.php"
//                let params = ["stripeSource": s.stripeID , "amount": "100", "currency": "usd", "description": "testRunCustomer", "customerID": "cus_BOEhgyfvu0AmVn"]
//                
//                
//                
//                _ = Alamofire.request(requestString, method: .post, parameters: params)
//                
//                
//                
//            }
//            
//        }
        
        
        
    }
    
    func deleteSource(){
        
        //works
        
        
        let requestString = "https://secret-atoll-43300.herokuapp.com/delete.php"
        let params = ["stripeSource": "src_1B1SQXCiiS6xkBbE6MObMcGv" ,  "customerID": "cus_BOEurQEco53abc"]
        
        
        
        _ = Alamofire.request(requestString, method: .post, parameters: params)
        
        
        
        //code to delete source
        
        
        
    }
    
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        
        
        addSource()
        
        
        
        
        
        
        ////        let cardParams = STPCardParams()
        ////
        ////        cardParams.number = paymentTextField.cardNumber
        ////        cardParams.cvc = paymentTextField.cvc
        ////        cardParams.expMonth = paymentTextField.expirationMonth
        ////        cardParams.expYear = paymentTextField.expirationYear
        ////        cardParams.last4() = paymentTextField.
        //
 //       let card = paymentTextField.cardParams
        
  //      let sourceParams = STPSourceParams.cardParams(withCard: card)
        
        //
        //                need to split up actions
        //                make new customer, charge him, add sources, charge regular customer
        
        
        //making a new customer with a source works
        //making a customer with no source works
        //adding a source to existing customer works
        //charging source works
        //just need to do deleting source
        //single charge also works
        
//        if let id = FIRAuth.auth()?.currentUser?.uid {
//            let client = Client(id: id)
//            client.getStripeToken(finished: { (customerID) in
//                if let cID = customerID {
//                    if let amount = UserDefaults.standard.integer(forKey: "price"), let selectedSource = selectedPaymentSource {
//                        let requestString = "https://secret-atoll-43300.herokuapp.com/charge.php"
//                        let params = ["stripeSource": selectedSource,
//                                      "amount": "\(amount)",
//                            "currency": "usd",
//                            "description": "Order",
//                            "customerID": cID]
//                        
//                        
//                        
//                        _ = Alamofire.request(requestString, method: .post, parameters: params)
//                    }
//                }
//            })
//        }
        
        
        
        
        
        //
        ////
        //
        //
        //
        //        STPAPIClient.shared().createToken(withCard: card, completion: {(token, error) -> Void in
        //            if let error = error {
        //                print(error)
        //                //SCLAlertView().showError("Error!", subTitle: "Your payment information is not valid")
        //
        //            }
        //            else if let token = token {
        //                print(token)
        //                self.chargeUsingToken(token)
        //               // SCLAlertView().showSuccess("Success", subTitle: "Your payment information is valid")
        //                self.delegate?.OrderPressed(cell: self)
        //
        //
        //
        //              //  UserDefaults.standard.set(token.card?.last4(), forKey: "t")
        //
        //
        //
        //
        //
        //
        //
        
        //        })
        
        
        
        //    }
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sourceIDs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("savedCreditCardCell", owner: self, options: nil)?.first as! savedCreditCardCell
        
        cell.last4.text = cardInfos[indexPath.row]
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        /*
         
         
         
         when the source is added to the database, give it a number, in the order it was added. the first source is 0, second source is 1 and ...
         when a row is clicked, check the source with the clicked row number, and use that as the source
         when the user deletes it, reload the tableview
         
         
         
         
         
         */
        
    }
    
    func chargeUsingToken(_ token:STPToken) {
        
        
        
    }
    
}
