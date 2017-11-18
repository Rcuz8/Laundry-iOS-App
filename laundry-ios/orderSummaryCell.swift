//
//  orderSummaryCell.swift
//  TBVIEW
//
//  Created by Anagh Telluri on 8/11/17.
//  Copyright © 2017 Anagh Telluri. All rights reserved.
//

import UIKit
import SCLAlertView
protocol orderSummaryDelegate {
    
    func orderSummaryNextClicked(cell: orderSummaryCell)
    func orderSummaryBack()
    
    
}

class orderSummaryCell: UITableViewCell  {
    
    @IBAction func termsOfServiceButton(_ sender: Any) {
        //
        //       let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        //        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.frame = self.bounds
        //        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        self.addSubview(blurEffectView)
        
        termsView.isHidden = false
        
        
    }
    
    
    
    
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var termsView: UIView!
    
    
    @IBOutlet weak var numberOfShirts: UILabel!
    @IBOutlet weak var numberOfPants: UILabel!
    @IBOutlet weak var numberOfSuits: UILabel!
    @IBOutlet weak var numberOfJackets: UILabel!
    
    @IBOutlet weak var termsCheckBox: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    @IBAction func xPressed(_ sender: Any) {
        
        termsView.isHidden = true
    }
    
    
    var delegate : orderSummaryDelegate?
    
    @IBAction func termsOfOrderingCheckBox(_ sender: Any) {
        
        if(termsCheckBox.isSelected)
        {
            termsCheckBox.isSelected = false
            termsCheckBox.setBackgroundImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
            UserDefaults.standard.set(false, forKey: "checkedTermsOfOrdering")
        }
        else  if(!termsCheckBox.isSelected){
            termsCheckBox.isSelected = true
            termsCheckBox.setBackgroundImage(UIImage(named: "ic_check_box"), for: .selected)
            UserDefaults.standard.set(true, forKey: "checkedTermsOfOrdering")
            
        }
        
    }
    
    @IBAction func yourOrderBackPressed(_ sender: Any) {
        delegate?.orderSummaryBack()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        checkoutButton.layer.cornerRadius = 10
        
        addressLabel.layer.cornerRadius = 15
        termsCheckBox.setBackgroundImage(UIImage(named: "ic_check_box_outline_blank_black_24dp_2x"), for: .normal)
        termsCheckBox.isSelected = false
        
        termsView.isHidden = true
        
        termsView.layer.borderWidth = 2.0
        termsView.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
    }
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        if termsCheckBox.isSelected {
        delegate?.orderSummaryNextClicked(cell: self)
        } else {
            SCLAlertView().showError("Unaccepted Terms", subTitle: "You must accept the Terms of Ordering before proceeding")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
