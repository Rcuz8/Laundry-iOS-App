//
//  NestedTableViewCell.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 8/17/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView

protocol checkPressed {
    //func press()
}

class NestedTableViewCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        checkBoxButton.setImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
        
        
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        
        if(checkBoxButton.isSelected)
        {
            checkBoxButton.isSelected = false
            
            
            checkBoxButton.setImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
            //
            
            UserDefaults.standard.set("Unchecked", forKey: preferenceLabel.text!)
            
            
            
        }
        else  if(!checkBoxButton.isSelected){
            
            checkBoxButton.isSelected = true
            
            
            //
            checkBoxButton.setBackgroundImage(UIImage(named: "ic_check_box"), for: .selected)
            
            UserDefaults.standard.set("Checked", forKey: preferenceLabel.text!)
            
            UserDefaults.standard.set(descLabel.text!, forKey: "specialPreferences")
            
        }
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // Configure the view for the selected state
    }
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var preferenceLabel: UILabel!
    
}

