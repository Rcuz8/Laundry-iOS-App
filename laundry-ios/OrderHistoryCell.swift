//
//  OrderHistoryCell.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/8/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit

protocol OrderHistoryDelegate {
    func infoRequested(cell: OrderHistoryCell)
}

class OrderHistoryCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var firstStar: UIImageView!
    
    @IBOutlet weak var secondStar: UIImageView!
    
    @IBOutlet weak var thirdStar: UIImageView!
    
    @IBOutlet weak var fourthStar: UIImageView!
    
    @IBOutlet weak var fifthStar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func infoRequested(_ sender: Any) {
        self.delegate?.infoRequested(cell: self)
    }
    var delegate: OrderHistoryDelegate?
    
    func shade(stars: Int) {
        switch stars {
        case 0:
            fifthStar.tintColor = UIColor.lavoLightGray
            fourthStar.tintColor = UIColor.lavoLightGray
            thirdStar.tintColor = UIColor.lavoLightGray
            secondStar.tintColor = UIColor.lavoLightGray
            firstStar.tintColor = UIColor.lavoLightGray
            break;
        case 1:
            fifthStar.tintColor = UIColor.lavoLightGray
            fourthStar.tintColor = UIColor.lavoLightGray
            thirdStar.tintColor = UIColor.lavoLightGray
            secondStar.tintColor = UIColor.lavoLightGray
            break;
        case 2:
            fifthStar.tintColor = UIColor.lavoLightGray
            fourthStar.tintColor = UIColor.lavoLightGray
            thirdStar.tintColor = UIColor.lavoLightGray
            break;
        case 3:
            fifthStar.tintColor = UIColor.lavoLightGray
            fourthStar.tintColor = UIColor.lavoLightGray
            break;
        case 4:
            fifthStar.tintColor = UIColor.lavoLightGray
            break;
        case 5:
            // all stars checked
            break;
        default:
            if stars < 0 { shade(stars: 0) }
            if stars > 5 { shade(stars: 5) }
            break;
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
