//
//  dryCleaningCell.swift
//  TBVIEW
//
//  Created by Anagh Telluri on 8/11/17.
//  Copyright © 2017 Anagh Telluri. All rights reserved.
//

import UIKit

protocol dryCleaningDelegate {
    func nextPressed(cell: dryCleaningCell)
    
    func transferInfo(cell: dryCleaningCell, shirts: Int!, pants: Int!, suits: Int!, jackets: Int!)
    
    func backPressed(cell: dryCleaningCell)
    
}



class dryCleaningCell: UITableViewCell {
    
    var expB : Bool!
    var stanB : Bool!
    
    var schedB : Bool!
    var instB : Bool!
    
    var launB : Bool!
    var dryB : Bool!
    
    
    @IBOutlet weak var optionsSegment: UISegmentedControl!
    @IBOutlet weak var backgroundLabel: UILabel!
    
    @IBOutlet weak var shirtSlider: UISlider!
    @IBOutlet weak var pantSlider: UISlider!
    @IBOutlet weak var suitSlider: UISlider!
    @IBOutlet weak var jacketSlider: UISlider!
    
    @IBOutlet weak var shirtSliderValue: UILabel!
    @IBOutlet weak var pantSliderValue: UILabel!
    @IBOutlet weak var suitSliderValue: UILabel!
    @IBOutlet weak var jacketSliderValue: UILabel!
    
    @IBOutlet weak var dryCleaningNextButton: UIButton!
    
    @IBOutlet weak var shirtButton: UIButton!
    @IBOutlet weak var pantButton: UIButton!
    @IBOutlet weak var jacketButton: UIButton!
    @IBOutlet weak var suitButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var delegate: dryCleaningDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shirtSliderSetup()
        pantSliderSetup()
        suitSliderSetup()
        jacketSliderSetup()
        
        
        backgroundLabel.layer.masksToBounds = true
        backgroundLabel.layer.cornerRadius = 15
        
        dryCleaningNextButton.layer.cornerRadius = 10
        
        shirtButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        
        
        // Initialization code
        
        
    }
    
    func shirtSliderSetup(){
        
        
        shirtSlider.minimumValue = 0
        shirtSlider.maximumValue = 25
        shirtSlider.value = 0
        
        shirtSlider.thumbTintColor = UIColor.init(red: 72/255, green: 160/255, blue: 194/255, alpha: 1)
        shirtSlider.tintColor = UIColor.init(red: 172/255, green: 233/255, blue: 255/255, alpha: 1)
        
        
        
        
    }
    
    func pantSliderSetup(){
        
        
        pantSlider.minimumValue = 0
        pantSlider.maximumValue = 25
        pantSlider.value = 0
        
        pantSlider.thumbTintColor = UIColor.init(red: 72/255, green: 160/255, blue: 194/255, alpha: 1)
        pantSlider.tintColor = UIColor.init(red: 172/255, green: 233/255, blue: 255/255, alpha: 1)
        
        pantSlider.isHidden = true
        pantSliderValue.isHidden = true
        
    }
    
    func suitSliderSetup(){
        
        suitSlider.minimumValue = 0
        suitSlider.maximumValue = 25
        suitSlider.value = 0
        
        suitSlider.thumbTintColor = UIColor.init(red: 72/255, green: 160/255, blue: 194/255, alpha: 1)
        suitSlider.tintColor = UIColor.init(red: 172/255, green: 233/255, blue: 255/255, alpha: 1)
        
        suitSlider.isHidden = true
        suitSliderValue.isHidden = true
        
    }
    
    func jacketSliderSetup(){
        
        
        jacketSlider.minimumValue = 0
        jacketSlider.maximumValue = 25
        jacketSlider.value = 0
        
        
        jacketSlider.thumbTintColor = UIColor.init(red: 72/255, green: 160/255, blue: 194/255, alpha: 1)
        jacketSlider.tintColor = UIColor.init(red: 172/255, green: 233/255, blue: 255/255, alpha: 1)
        
        jacketSlider.isHidden = true
        jacketSliderValue.isHidden = true
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        delegate?.nextPressed(cell: self)

        
        
        
    }
    
    
    @IBAction func genderOptionsChanged(_ sender: Any) {
        
        
        
        if(optionsSegment.selectedSegmentIndex == 0){
            UserDefaults.standard.set(1, forKey: "genderOptions")
        }
        
        if(optionsSegment.selectedSegmentIndex == 1){
            UserDefaults.standard.set(2, forKey: "genderOptions")
        }
        
        if(optionsSegment.selectedSegmentIndex == 2){
            UserDefaults.standard.set(3, forKey: "genderOptions")
        }
        
    }

    @IBAction func shirtButtonClicked(_ sender: Any) {
        
        nameLabel.text = "Shirts"
        
        shirtSlider.isHidden = false
        shirtSliderValue.isHidden = false
        
        shirtButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        
        pantSlider.isHidden = true
        pantSliderValue.isHidden = true
                pantButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        jacketSlider.isHidden = true
        jacketSliderValue.isHidden = true
                jacketButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        suitSliderValue.isHidden = true
        suitSlider.isHidden = true
                suitButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        
        
    }
    
    @IBAction func pantButtonClicked(_ sender: Any) {
        
        nameLabel.text = "Pants"
        
        pantSlider.isHidden = false
        pantSliderValue.isHidden = false
        pantButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        
        shirtSlider.isHidden = true
        shirtSliderValue.isHidden = true
        shirtButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        jacketSlider.isHidden = true
        jacketSliderValue.isHidden = true
                jacketButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        suitSliderValue.isHidden = true
        suitSlider.isHidden = true
                suitButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        
        
    }
    
    @IBAction func jacketButtonClicked(_ sender: Any) {
        
        
        nameLabel.text = "Jackets"
        
        pantSlider.isHidden = true
        pantSliderValue.isHidden = true
        pantButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        shirtSlider.isHidden = true
        shirtSliderValue.isHidden = true
        shirtButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        jacketSlider.isHidden = false
        jacketSliderValue.isHidden = false
        jacketButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        
        
        suitSliderValue.isHidden = true
        suitSlider.isHidden = true
        suitButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
    }
    
    @IBAction func suitButtonClicked(_ sender: Any) {
        
        
        nameLabel.text = "Suits"
        
        pantSlider.isHidden = true
        pantSliderValue.isHidden = true
        pantButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        shirtSlider.isHidden = true
        shirtSliderValue.isHidden = true
        shirtButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        jacketSlider.isHidden = true
        jacketSliderValue.isHidden = true
        jacketButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        
        suitSliderValue.isHidden = false
        suitSlider.isHidden = false

           suitButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        
    }
    

    
    @IBAction func shirtChanged(_ sender: Any) {
        
        let roundedValue = roundf(shirtSlider.value / 0.5) * 0.5
        shirtSlider.value = roundedValue
        
        
        
        shirtSliderValue.text = String(Int(shirtSlider.value))
        UserDefaults.standard.set(Int(shirtSlider.value), forKey: "numberOfShirts")
        
    }
    
    @IBAction func pantChanged(_ sender: Any) {
        
        let roundedValue = roundf(pantSlider.value / 0.5) * 0.5
        pantSlider.value = roundedValue
        
        
        pantSliderValue.text = String(Int(pantSlider.value))
        UserDefaults.standard.set(Int(pantSlider.value), forKey: "numberOfPants")
        
    }
    
    @IBAction func suitChanged(_ sender: Any) {
        
        let roundedValue = roundf(suitSlider.value / 0.5) * 0.5
        suitSlider.value = roundedValue
        
        
        suitSliderValue.text = String(Int(suitSlider.value))
        UserDefaults.standard.set(Int(suitSlider.value), forKey: "numberOfSuits")
        
        
    }
    
    @IBAction func jacketChanged(_ sender: Any) {
        
        let roundedValue = roundf(jacketSlider.value / 0.5) * 0.5
        jacketSlider.value = roundedValue
        
        
        jacketSliderValue.text = String(Int(jacketSlider.value))
        UserDefaults.standard.set(Int(jacketSlider.value), forKey: "numberOfJackets")
        
        
    }
    
    

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        
        delegate?.backPressed(cell: self)
        
    }

    
}
