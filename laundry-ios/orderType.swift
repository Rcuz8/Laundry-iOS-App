//
//  orderType.swift
//  TBVIEW
//
//  Created by Anagh Telluri on 8/11/17.
//  Copyright © 2017 Anagh Telluri. All rights reserved.
//
import UIKit
import SCLAlertView

protocol orderTypeDelegate {
    func cellButtonTapped(cell: orderType)
    func transferCellState(expressOrStandard: String!, dryCleaningCheckBox : Bool!, laundryCheckbox: Bool!)
    func cancelOrderScheme()
}

protocol sendOrderDataDelegate {
    func chosenOptions(cell: orderType, standardOrExpress : String!)
    
}

class orderType: UITableViewCell {
    
    @IBOutlet weak var expressAndStandardBackgroundLabel: UILabel!
    @IBOutlet weak var expressButton: UIButton!
    @IBOutlet weak var standardButton: UIButton!
    
    //    @IBOutlet weak var scheduleAndInstantBackgroundLabel: UILabel!
    //    @IBOutlet weak var scheduleButton: UIButton!
    //    @IBOutlet weak var instantButton: UIButton!
    
    var expressBool : Bool = false
    var standardBool : Bool = false
    
    @IBOutlet weak var laundryBackgroundLabel: UILabel!
    @IBOutlet weak var laundryCheckBox: UIButton!
    
    @IBOutlet weak var dryCleaningBackgroundLabel: UILabel!
    @IBOutlet weak var dryCleaningCheckBox: UIButton!
    
    @IBOutlet weak var navigationBar: UILabel!
    @IBOutlet weak var typeOfOrderNextButton: UIButton!
    
    var delegate: orderTypeDelegate?
    var sendOrderDelegate : sendOrderDataDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkBoxSetup()
        
        expressAndStandardSetup()
        
        
        navigationBar.layer.cornerRadius = 15
        
        typeOfOrderNextButton.layer.cornerRadius = 10
        
        
        
        
    }
    
    func expressAndStandardSetup(){
        
        expressButton.layer.masksToBounds = true
        expressButton.layer.cornerRadius = 10
        
        standardButton.layer.masksToBounds = true
        standardButton.layer.cornerRadius = 10
        
        expressAndStandardBackgroundLabel.layer.masksToBounds = true
        expressAndStandardBackgroundLabel.layer.cornerRadius = 15
        
        
        
    }
    
    
    
    
    func checkBoxSetup(){
        
        
        laundryCheckBox.setBackgroundImage(UIImage(named: "ic_check_box_outline_blank_black_24dp_2x"), for: .normal)
        laundryCheckBox.isSelected = false
        
        dryCleaningCheckBox.setBackgroundImage(UIImage(named: "ic_check_box_outline_blank_black_24dp_2x"), for: .normal)
        dryCleaningCheckBox.isSelected = false
        
    }
    
    @IBAction func cancelledPressed(_ sender: Any) {
        
        UserDefaults.standard.removeAll()
        standardButton.layer.borderWidth = 0
        expressButton.layer.borderWidth = 0
        
        dryCleaningCheckBox.isSelected = false
        laundryCheckBox.isSelected = false
        
        
        delegate?.cancelOrderScheme()
        
    }
    
    @IBAction func expressClicked(_ sender: Any) {

            expressButton.layer.borderWidth = 2.0
            expressButton.layer.borderColor = UIColor.black.cgColor
            expressBool = true
            expressButton.isSelected = true
            standardBool = false
            standardButton.isSelected = false
            standardButton.layer.borderWidth = 0
        
            UserDefaults.standard.set(true, forKey: "isExpress")
        
        
    }
    
    
    @IBAction func standardClicked(_ sender: Any) {
        
            standardBool = true
        
            standardButton.layer.borderWidth = 2.0
            standardButton.layer.borderColor = UIColor.black.cgColor
            
            
            expressButton.layer.borderWidth = 0
            
            expressBool = false
            UserDefaults.standard.set(false, forKey: "isExpress")
        expressButton.isSelected = false
        standardButton.isSelected = true
        
    }
    
    
    
    @IBAction func dryCleaningCheckBoxClicked(_ sender: Any) {
        
        
        if(dryCleaningCheckBox.isSelected)
        {
            dryCleaningCheckBox.isSelected = false
            
            
            
            dryCleaningCheckBox.setBackgroundImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
            
            
            UserDefaults.standard.set(nil, forKey: "isLaundry")
            
            
        }
        else if(!dryCleaningCheckBox.isSelected){
            
            dryCleaningCheckBox.isSelected = true
            
            
            
            dryCleaningCheckBox.setBackgroundImage(UIImage(named: "ic_check_box"), for: .selected)
            
            laundryCheckBox.isSelected = false
            
            
            UserDefaults.standard.set(false, forKey: "isLaundry")
            
        }
        
        
        
        
    }
    
    
    
    @IBAction func laundryCheckBoxClicked(_ sender: Any) {
        
        
        
        
        if(laundryCheckBox.isSelected)
        {
            laundryCheckBox.isSelected = false
            
            
            laundryCheckBox.setBackgroundImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
            
            
            UserDefaults.standard.set(nil, forKey: "isLaundry")
            
        }
        else  if(!laundryCheckBox.isSelected){
            
            laundryCheckBox.isSelected = true
            
            
            laundryCheckBox.setBackgroundImage(UIImage(named: "ic_check_box"), for: .selected)
            
            //dryCleaningCheckBox.setImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
            
            dryCleaningCheckBox.isSelected = false
            
            
            
            UserDefaults.standard.set(true, forKey: "isLaundry")
            
        }
        
        
        
    }
    
    func allSelected() -> Bool {
        if (standardButton.isSelected || expressButton.isSelected) && (dryCleaningCheckBox.isSelected || laundryCheckBox.isSelected) { return true } else { return false }
    }
    
    func expressSelected() -> Bool {
        if (standardButton.isSelected || expressButton.isSelected) { return true } else { return false }
    }
    
    func laundrySelected() -> Bool {
        if (dryCleaningCheckBox.isSelected || laundryCheckBox.isSelected) { return true } else { return false }
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        
        
        if(!allSelected()){
            SCLAlertView().showTitle("Error", subTitle: "You must select exactly 1 option from standard and express. You must check exactly one option from dry cleaning and laundry", style: SCLAlertViewStyle.error)
            
            print("Both not selected")
        }
            
        else if (!expressSelected()) {
            
            SCLAlertView().showTitle("Error", subTitle: "You must select exactly 1 option from standard and express" , style: SCLAlertViewStyle.error)
            print("isExpress not selected")
            
        }
            
        else if(!laundrySelected()){
            SCLAlertView().showTitle("Error", subTitle: "You must check exactly one option from dry cleaning and laundry", style: SCLAlertViewStyle.error)
            print("isLaundry not selected")
            
        }
            
        else {
            print("All good, proceeding...")
            delegate?.cellButtonTapped(cell: self)
            //sendOrderDelegate?.chosenOptions(cell: self, standardOrExpress: "standard")
        }
        
    }
    
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        laundryBackgroundLabel.layer.masksToBounds = true
        laundryBackgroundLabel.layer.cornerRadius = 15
        
        dryCleaningBackgroundLabel.layer.masksToBounds = true
        dryCleaningBackgroundLabel.layer.cornerRadius = 15
        
        // dryCleaningCheckBox.setImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
        
        // dryCleaningCheckBox.setImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
        
    }
    
    
    
}

extension UserDefaults {
    func removeAll() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}

