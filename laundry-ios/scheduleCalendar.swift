//
//  scheduleCalnedar.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 8/17/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit

protocol openCalendar {
    func schedulePressed()
    func nextPressed()
    func backBtnPressed()
}
   // Instant = On Demand
class scheduleCalendar: UITableViewCell, scheduleScreenDelegate  {

    var instantOrScheduleBool : Bool = false
    
    @IBOutlet weak var instantBtn: UIButton!
    @IBAction func instantBtnPressed(_ sender: Any) {
        
        instantOrScheduleBool = !instantOrScheduleBool
        
        
        
                if(instantOrScheduleBool){
                    instantBtn.layer.borderWidth = 2.0
                    instantBtn.layer.borderColor = UIColor.black.cgColor
        
        
        
        
    }
    }
    
    func highlightInstant(high: Bool!) {
        
        print(high)
        
        if((UserDefaults.standard.object(forKey: "Instant") as! String!) == "Selected"){
            print("LOLOLOLOLOLOLOLO")
            instantBtn.layer.borderWidth = 2.0
            instantBtn.layer.borderColor = UIColor.black.cgColor
            
            
        }
        
    }
    
    @IBOutlet weak var scheduledBtn: UIButton!
    
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBAction func back(_ sender: Any) {
        
        delegate?.backBtnPressed()
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let ud = UserDefaults.standard
        instantBtn.layer.cornerRadius = 10
        scheduledBtn.layer.cornerRadius = 10
        backgroundLabel.layer.cornerRadius = 15
        if let onDemand = ud.bool(forKey: "isOnDemand") as? Bool{
            if onDemand {
                instantBtn.layer.borderWidth = 2.0
                instantBtn.layer.borderColor = UIColor.black.cgColor
            } else {
                scheduledBtn.layer.borderWidth = 2.0
                scheduledBtn.layer.borderColor = UIColor.black.cgColor
            }
        }

        nextButton.layer.cornerRadius = 10
        backgroundLabel.layer.masksToBounds = true
        backgroundLabel.layer.cornerRadius = 15
        
        
        
        // Initialization code
    }
    
    
    
    var delegate : openCalendar?
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func openCalendarViewController(_ sender: Any) {
        
        instantBtn.layer.borderWidth = 0
        instantBtn.isSelected = false
        
        
        delegate?.schedulePressed()
 
    }
    
    @IBAction func nextPressedCalendar(_ sender: Any) {
        
        delegate?.nextPressed()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    

}
