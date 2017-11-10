//
//  laundryCell.swift
//  TBVIEW
//
//  Created by Anagh Telluri on 8/11/17.
//  Copyright © 2017 Anagh Telluri. All rights reserved.
//

import UIKit

protocol laundryDelegate {
    func laundryCellButtonTapped(cell: laundryCell)
    func backButtonPressed()
}




class laundryCell: UITableViewCell {
    @IBOutlet weak var bigBackgroundLabel: UILabel!
    @IBOutlet weak var smallBackgroundLabel: UILabel!
    
    @IBOutlet weak var bagSliderValue: UILabel!
    @IBOutlet weak var bagSlider: UISlider!
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    var delegate: laundryDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nextButton.layer.cornerRadius = 10
        
        bagSliderSetup()
        backgroundLabelsSetup()
        
        
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        delegate?.backButtonPressed()
        
    }
    
    
    
    
    func bagSliderSetup(){
        
        
        bagSlider.minimumValue = 0
        bagSlider.maximumValue = 25
        bagSlider.value = 0
        bagSlider.thumbTintColor = UIColor.init(red: 72/255, green: 160/255, blue: 194/255, alpha: 1)
        bagSlider.tintColor = UIColor.init(red: 172/255, green: 233/255, blue: 255/255, alpha: 1)
        
    }
    
    func backgroundLabelsSetup(){
        
        bigBackgroundLabel.layer.masksToBounds = true
        bigBackgroundLabel.layer.cornerRadius = 15
        
        smallBackgroundLabel.layer.masksToBounds = true
        smallBackgroundLabel.layer.cornerRadius = 15
        
        smallBackgroundLabel.layer.borderColor = UIColor.init(red: 72/255, green: 160/255, blue: 194/255, alpha: 1.0).cgColor
        smallBackgroundLabel.layer.borderWidth = 2.0
        
    }
    
    @IBAction func valueChangedSlider(_ sender: Any) {
        
        let roundedValue = roundf(bagSlider.value / 0.5) * 0.5
        
        bagSlider.value = roundedValue
        bagSliderValue.text = "  "+String(Int(bagSlider.value))
        
        UserDefaults.standard.set(Int(bagSlider.value), forKey: "numberOfBags")
        UserDefaults.standard.set(Int(bagSlider.value), forKey: "bagCount")
    }
    
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        delegate?.laundryCellButtonTapped(cell: self)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
