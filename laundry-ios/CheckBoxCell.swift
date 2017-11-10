//
//  CheckBoxCell.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit

protocol CheckToggledDelegate {
    func checkToggled(cell: CheckBoxCell)
}

class CheckBoxCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkMark.alpha = 0
    }

    @IBOutlet weak var checkMark: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    var delegate: CheckToggledDelegate?
    
    @IBAction func toggleCheck() {
        if checkMark.alpha == 0 {
            checkMark.alpha = 1
        } else {
            checkMark.alpha = 0
        }
        delegate?.checkToggled(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
