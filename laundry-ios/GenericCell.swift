//
//  GenericCell.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 7/10/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit

class GenericCell: UITableViewCell {

    @IBOutlet weak var centerText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
