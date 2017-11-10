//
//  specialPreferencesCell.swift
//  TBVIEW
//
//  Created by Anagh Telluri on 8/11/17.
//  Copyright © 2017 Anagh Telluri. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SCLAlertView
import Firebase
protocol specialPreferencesDelegate {
    func specialNextPressed(cell: specialPreferencesCell)
    func addSpecialPreferences(cell: specialPreferencesCell, h: Int)
    func donePressed(cell: specialPreferencesCell)
    func cancelPressed(cell: specialPreferencesCell)
    func backPressed()
    
}



class specialPreferencesCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    var descriptionPreferences : [String]!
    var titlePreferences : [String]!
    var delegate: specialPreferencesDelegate?
    var checkIndexPaths : Array = [Int!]()
    var t1 : Int!
    var num : Int = 0
    var checkboxButton : UIButton!


    
    
    
    @IBOutlet weak var textView12: UITextView!
    
    @IBOutlet weak var backgroundLabel: UILabel!
    //  @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputButton: UIButton!
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var tableViewNested: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var selectedPreference = -1


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        descriptionPreferences = Array<String>()
        titlePreferences = Array<String>()
        if let id = FIRAuth.auth()?.currentUser?.uid {
            let c = Client(id: id)
            c.dbFill {
                if let prefs = c.savedOrderingPreferences as? [(name: String, preferences: String)]{
                    print("prefs: \(prefs)")
                    for pref in prefs {
                        self.titlePreferences.append(pref.name)
                        self.descriptionPreferences.append(pref.preferences)
                        
                    }
                    self.tableViewNested.reloadData()
                } else { print("Couldnt init prefs") }
            }
        }
        textView12.isHidden = true
        
        inputButton.layer.masksToBounds = true
        inputButton.layer.cornerRadius = 15
        
        tableViewNested.delegate = self
        tableViewNested.dataSource = self
        
        nextButton.layer.cornerRadius = 10
        
        backgroundLabelSetup()

        textView12.text = ""
        textView12.placeholderText = "Enter Description"
        
         
        TitleTextField.text = ""
        TitleTextField.isHidden = true
        

        //mask?.frame = layer.bounds
        //textView12.layer.masksToBounds = true
        // textView12.layer.cornerRadius = 15
        // textView12.clipsToBounds = true
  
    }
  
    func backgroundLabelSetup(){
        
        backgroundLabel.layer.masksToBounds = true
        backgroundLabel.layer.cornerRadius = 15
        backgroundLabel.layer.borderWidth = 2.0
        backgroundLabel.layer.borderColor = UIColor.black.cgColor
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("NestedTableViewCell", owner: self, options: nil)?.first as! NestedTableViewCell
        
        if(  descriptionPreferences.count == 0){ }
        else {
            if let checked = UserDefaults.standard.object(forKey:   descriptionPreferences[indexPath.row]) as? String {
                if checked == "Checked" {
                    cell.checkBoxButton.isSelected = true
                    cell.checkBoxButton.setBackgroundImage(UIImage(named: "ic_check_box"), for: .selected)
                } else {
                    cell.checkBoxButton.isSelected = false
                    cell.checkBoxButton.setImage(UIImage(named:"ic_check_box_outline_blank_black_24dp_2x" ) , for: .normal)
                }
            }
        }

        cell.preferenceLabel.text =   titlePreferences[indexPath.row]
        cell.descLabel.text = descriptionPreferences[indexPath.row]
  
        return cell
    
    }
    
    
    func oneIsChecked() -> Bool {
        var i = 0
        for cell in tableViewNested.visibleCells {
            if let prefCell = cell as? NestedTableViewCell {
                if prefCell.checkBoxButton.isSelected { i += 1 }
            }
        }
        if i == 1 {
            return true
        } else { return false }
    }
    
    func indexOfChecked() -> Int {
        var i = 0
        for cell in tableViewNested.visibleCells {
            if let prefCell = cell as? NestedTableViewCell {
                if prefCell.checkBoxButton.isSelected { return i } else { i += 1 }
            }
        }
        return -1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return   descriptionPreferences.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell : NestedTableViewCell = tableView.cellForRow(at: indexPath) as! NestedTableViewCell
        SCLAlertView().showTitle(cell.preferenceLabel.text!, subTitle: cell.descLabel.text!, style: SCLAlertViewStyle.info)
    }

    @IBAction func inputButtonPressed(_ sender: Any) {
        
        delegate?.addSpecialPreferences(cell: self, h: Int(20))
        TitleTextField.isHidden = false
        inputButton.isHidden = true
        textView12.isHidden = false
        textView12.text = ""
                TitleTextField.addRightLeftOnKeyboardWithTarget(self, leftButtonTitle: "Cancel", rightButtonTitle: "Next", rightButtonAction: #selector(keyBoardNextButtonPressed) , leftButtonAction: #selector(cancelButtonPressed(_:)))
        TitleTextField.becomeFirstResponder()
        
        //textView12.becomeFirstResponder()
        
        nextButton.isHidden = true
 
         UserDefaults.standard.set("unchecked", forKey: textView12.text!)
        
    }
    
    func keyBoardNextButtonPressed(){
        
        textView12.addRightLeftOnKeyboardWithTarget(self, leftButtonTitle: "Cancel", rightButtonTitle: "Done", rightButtonAction: #selector(doneButtonPressed(_:)), leftButtonAction: #selector(cancelButtonPressed(_:)))
        textView12.becomeFirstResponder()
    }

     func doneButtonPressed(_ sender: Any) {
        
        
        
        if textView12.text != "", let title = TitleTextField.text, TitleTextField.text != "" {
        
            descriptionPreferences.append(textView12.text)
            titlePreferences.append(title)
            let pref: (name: String, preferences: String) = (title, textView12.text)
            if let id = FIRAuth.auth()?.currentUser?.uid {
                let c = Client(id: id)
                c.dbFill {
                    c.savedOrderingPreferences?.append(pref)
                    c.saveOnlyOrderPreferences(finished: { (saved) in
                        self.nextButton.isHidden = false
                        self.TitleTextField.isHidden = true
                        self.textView12.isHidden = true
                        self.inputButton.isHidden = false
                        self.textView12.resignFirstResponder()
                        self.TitleTextField.resignFirstResponder()
                        self.delegate?.donePressed(cell: self)
                    })
                }
            } else {
                SCLAlertView().showError("Oops", subTitle: "Could not find your information!")
            }
            tableViewNested.reloadData()
            UserDefaults.standard.set("unchecked", forKey: textView12.text!)
            
        }

    }
    
    func cancelButtonPressed(_ sender: Any) {
        
        
        textView12.isHidden = true
        nextButton.isHidden = false
        inputButton.isHidden = false
        TitleTextField.isHidden = true
        self.textView12.resignFirstResponder()
        self.TitleTextField.resignFirstResponder()
        delegate?.cancelPressed(cell: self)
        
    }
    
    @IBAction func specialNextButtonPressed(_ sender: Any) {
        if oneIsChecked() {
            UserDefaults.standard.setValue(descriptionPreferences[indexOfChecked()], forKey: "specialPreferences")
            delegate?.specialNextPressed(cell: self)
        } else {
            SCLAlertView().showError("Oops", subTitle: "Exactly 1 ordering preference must be selected")
        }
        
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        delegate?.backPressed()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
