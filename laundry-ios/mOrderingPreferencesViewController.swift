//
//  mOrderingPreferencesViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Firebase
import JTAppleCalendar
import QuartzCore

class mOrderingPreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.savedLocationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.savedPreferencesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        fillData()
        self.backButton.tintColor = UIColor.lavoLightGray
        renderButtonImages()
        hideNavController()
        
    }
    
    var preferenceTitles: [String]?
    var locationTitles: [String]?
    
    
    func fillData() {
        preferenceTitles = [String]()
        locationTitles = [String]()
        if let user = FIRAuth.auth()?.currentUser { let client = Client(id: user.uid);
            client.dbFill {
                if client.valid() {
                    let locations = client.savedLocations!
                    for loc in locations { self.locationTitles?.append(loc.name) }
                    let prefs = client.savedOrderingPreferences!
                    for pref in prefs { self.preferenceTitles?.append(pref.name) }
                    self.savedLocationsTableView.reloadData()
                    self.savedPreferencesTableView.reloadData()
                } } }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var addSavedLocationButton: UIButton!
    @IBOutlet weak var addSavedPreferenceButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var savedLocationsTableView: UITableView!
    
    @IBOutlet weak var savedPreferencesTableView: UITableView!
    
    let formatter = DateFormatter()
    
    @IBAction func addSavedLocation(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Add Location")
        vc?.modalPresentationStyle = .overCurrentContext
        self.present(vc!, animated: false, completion: nil)
    }
    
    
    
    
    
    
    // Table View //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == savedLocationsTableView {
            return locationTitles!.count
        } else {
            return preferenceTitles!.count
        }
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        if tableView == savedPreferencesTableView {
            cell.textLabel?.text = preferenceTitles?[indexPath.row]
        } else if tableView == savedLocationsTableView {
            cell.textLabel?.text = locationTitles?[indexPath.row]
        }
        cell.contentView.backgroundColor = UIColor.lavoDarkGray
        cell.layer.masksToBounds = true
        cell.textLabel?.textColor = UIColor.lavoLightGray
        cell.contentView.layer.cornerRadius = 7
        cell.viewWithTag(0)?.layer.cornerRadius = 7
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 3
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
    
    @IBAction func addPreff(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Add Preference")
        vc?.modalPresentationStyle = .overCurrentContext
        self.present(vc!, animated: false, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func renderButtonImages() {
        let locImg = UIImage(named:"ic_add_location_black_24dp")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        let prefImg = UIImage(named:"ic_add_circle_outline")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        
        addSavedLocationButton.setImage(locImg, for: .normal)
        addSavedPreferenceButton.setImage(prefImg, for: .normal)
        
        addSavedLocationButton.tintColor = UIColor.lavoLightBlue
        addSavedPreferenceButton.tintColor = UIColor.lavoLightBlue
        
    }
                                                                                                  
    
    
    

}

extension mOrderingPreferencesViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"; formatter.timeZone = Calendar.current.timeZone; formatter.locale = Calendar.current.locale
        let startDate = formatter.date(from: "2017 8 1")
        let endDate = formatter.date(from: "2020 12 31")
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text

        return cell
    }
    
}


