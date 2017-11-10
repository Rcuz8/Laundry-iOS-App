//
//  savedCreditCardCell.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 9/13/17.
//  Copyright © 2017 Lavo Logistics. All rights reserved.
//

import UIKit

class savedCreditCardCell: UITableViewCell {
    
    @IBOutlet weak var last4: UILabel!
    
    @IBOutlet weak var checkbox: UIButton!
    
    @IBAction func checkBoxClicked(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
