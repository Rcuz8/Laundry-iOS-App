//
//  schedulePickerViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 8/18/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit


protocol closed {
    func addToCalendar(date: Date)
}

class schedulePickerViewController: UIViewController {
    @IBOutlet weak var titleL: UnderlinedLabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //let shared = mapViewController()
    
    var delegate : closed?

    @IBOutlet weak var weekSegControl: UISegmentedControl!
    
    var formatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dates = UserDefaults.standard.object(forKey: "scheduledOrderDates") as? [String] {
            self.scheduledDates = dates
        }
        
        formatter.dateFormat = "dd-MM-yyyy"
        
        formatter.timeZone = TimeZone.current
        
        titleL.text = "Add Scheduled Order(s)"
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clearScheduledTimes(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "scheduledOrderDates")
        scheduledDates.removeAll()
        UserDefaults.standard.set(nil, forKey: "scheduledDayOfWeek")
        UserDefaults.standard.set(nil, forKey: "scheduledDayOfWeekTime")
    }
    @IBOutlet weak var weekTimePicker: UIDatePicker!
    @IBAction func done(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        delegate?.addToCalendar(date: datePicker.date)
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    //adds an event to the array of calendar events
    @IBAction func textFieldApplyButtonPressed(_ sender: Any) {
        let dayOfWeek = weekSegControl.selectedSegmentIndex
        let time = weekTimePicker.date
        UserDefaults.standard.set(dayOfWeek, forKey: "scheduledDayOfWeek")
        let timeString = formatter.string(from: time)
        UserDefaults.standard.set(timeString, forKey: "scheduledDayOfWeekTime")
    }
    
    var scheduledDates = [String] ()
    
    //adds an event to the array of calendar events
    @IBAction func datePickerApplyPressed(_ sender: Any) {
        scheduledDates.append(formatter.string(from: datePicker.date))
        UserDefaults.standard.set(scheduledDates, forKey: "scheduledOrderDates")
    }
    
    //adds all of the calendar events in the array to the calendar. for all dates with pickups and returns, have boxed cells
    
    @IBAction func schedulePickerDonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //once you go back to tableview, it will reload and the database will appear
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
