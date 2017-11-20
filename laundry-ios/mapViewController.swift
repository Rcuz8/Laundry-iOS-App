//
//  mapViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 7/23/17.
//  Copyright © 2017 Leo Vigna. All rights reserved.
//
import UIKit
import MapKit
import Stripe
import Alamofire
import JTAppleCalendar
import Firebase
import IQKeyboardManagerSwift
import FSCalendar
import CoreLocation


protocol clearDataAfterLetsGetWashingGetsPressed {
    
    func clearInfo(expStanString: String)
    
    
}

protocol scheduleScreenDelegate {
    func highlightInstant(high: Bool!)
    
}

protocol closeSearch {
    func closeSearchField(but: UIButton!)
}

struct cellData{
    
    let cell : Int!
    let height : CGFloat!
    let yCoor : CGFloat!
    
}

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class mapViewController: UIViewController, STPPaymentCardTextFieldDelegate, UITableViewDelegate, UITableViewDataSource, orderTypeDelegate, dryCleaningDelegate, laundryDelegate, specialPreferencesDelegate, orderSummaryDelegate, paymentDelegate, openCalendar, hide_Show_Button, straightToGetWashing, FSCalendarDataSource, FSCalendarDelegate, closed {
    
    //saving data user defaults
    
    var SavedStates : UserDefaults = UserDefaults.standard
    
    //feebdback screens
    @IBOutlet weak var orderReturnedLabel: UnderlinedLabel!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var reportIssueButton: UIButton!
    @IBOutlet weak var doneButtonFeedback: UIButton!
    
    //report to us screens
    
    
    
    
    @IBAction func closeButton(_ sender: Any) {
        
        self.reportIssueView.isHidden = true
        self.feedbackView.isHidden = false
        
        
    }
    
    var times : String!
    
    @IBOutlet weak var reportIssueLabel: UnderlinedLabel!
    @IBOutlet weak var reportIssueView: UIView!
    @IBOutlet weak var reportIssueTextView: UITextView!
    @IBOutlet weak var reportIssueSubmitButton: UIButton!
    
    //Contact us screen
    @IBAction func contactUsClose(_ sender: Any) {
        
        self.contactUsView.isHidden = true
        self.feedbackView.isHidden = false
        
        
    }
    @IBOutlet weak var contactUsLabel: UnderlinedLabel!
    @IBOutlet weak var contactUsView: UIView!
    @IBOutlet weak var contactUsSubmitButton: UIButton!
    @IBOutlet weak var contactUsTextView: UITextView!
    
    var delegate3 : closeSearch?
    
    //landing/map page
    var searchBarPlaceHolder : UIView!
    @IBOutlet weak var getWashing: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var overlayBlur : UIView!
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    var subView : UIView!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var calendarView: UIView!
    
    
    @IBOutlet weak var instantButton: UIButton!
    @IBOutlet weak var scheduledButton: UIButton!
    @IBOutlet weak var instantAndScheduledLabelBackground: UILabel!
    
    
    //order state variables for Type of Order Screen Back button pressed
    var expOrStan : String = " "
    var drycleaningCheckboxClicked : Bool = false
    var laundryCheckBoxClicked : Bool = false
    
    
    //temp data to transfer data from drycleaningCell to OrderSummaryCell
    var address : String!
    
    var numberOfShirts: String!
    var numberOfPants: String!
    var numberOfSuits: String!
    var numberOfJackets : String!
    
    //table view for order screens layour
    var tableView : UITableView!
    
    //cell data
    var arrayOfCellData = [cellData]()
    
    var arr = [String!]()
    
    @IBOutlet weak var orderSchedulingMainPageNextButton: UIButton!
    
    var events = [String]()
    var numberOfEvents = [Int]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //type of order cell
        SavedStates.set(nil, forKey: "StandardOrExpress")
        
        SavedStates.set(nil, forKey: "isLaundry")
        
        
        print("OJOJOJOJOK")
        //drycleaning cell
        
        SavedStates.set(0, forKey: "genderOptions")
        SavedStates.set(0, forKey: "numberOfShirts")
        SavedStates.set(0, forKey: "numberOfPants")
        SavedStates.set(0, forKey: "numberOfSuits")
        SavedStates.set(0, forKey: "numberOfJackets")
        
        //laundry
        SavedStates.set(0, forKey: "numberOfBags")
        
        UserDefaults.standard.set(" ", forKey: "Instant")
        
        
        //  let x = FSCalendar()
        let testVc = schedulePickerViewController()
        testVc.delegate = self
        
        
        //special preferences
        
        UserDefaults.standard.set(nil, forKey: "specialTableView")
        
        //order summary
        UserDefaults.standard.set(" ", forKey: "termsCheckBox")
        UserDefaults.standard.set(" ", forKey: "Scheduled")
        
        UserDefaults.standard.set(" ", forKey: "getWashing")
        
        UserDefaults.standard.set(" ", forKey: "search")
        
        UserDefaults.standard.set(" ", forKey: "address")
        
        UserDefaults.standard.set(" ", forKey: "preferencesString")
        
        UserDefaults.standard.set("", forKey: "t")
        
        
        self.navigationItem.titleView?.isHidden = true
        
        
        addTableview()
        sideMenus()
        mapViewSettings()
        addOverlay()
        feedbackScreens()
        
        arrayOfCellData = [cellData(cell: 1, height: 400, yCoor: 0), cellData(cell: 2, height: 370, yCoor: 400), cellData(cell: 3, height: 340, yCoor: 770), cellData(cell: 4, height: 462, yCoor: 1110), cellData(cell: 5, height: 450, yCoor: 1572), cellData(cell: 6, height: 230, yCoor: 2022), cellData(cell: 7, height: 525, yCoor: 2352)]
        
        feedbackView.isHidden = true
        tableView.isHidden = true
        
        
        orderSchedulingMainPageNextButton.layer.cornerRadius = 10
        
        
        
        
        
        scheduledButton.layer.masksToBounds = true
        scheduledButton.layer.cornerRadius = 10
        scheduledButton.layer.borderWidth = 2.0
        scheduledButton.layer.borderColor = UIColor.black.cgColor
        
        
        
        instantButton.layer.masksToBounds = true
        instantButton.layer.cornerRadius = 10
        
        
        
        instantAndScheduledLabelBackground.layer.masksToBounds = true
        instantAndScheduledLabelBackground.layer.cornerRadius = 15
        
        
        calendarView.isHidden = true
        //calendar.allowsMultipleSelection = true
        
        
        calendar.layer.cornerRadius = 20
        calendar.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        calendar.layer.borderWidth = 2.0
        
        
        
        
        
        
    }
    
    func mapViewSettings(){
        
        
        
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
        
        
        //
        
        //
        
        searchBarPlaceHolder = UIView(frame: CGRect(x: 50, y: 20, width: self.view.frame.width-50, height: 36))
        searchBarPlaceHolder.backgroundColor = UIColor.black
        searchBarPlaceHolder.layer.cornerRadius = 10
        
        self.view.addSubview(searchBarPlaceHolder)
        
        searchBar.frame = CGRect(x: 0, y:0, width: searchBarPlaceHolder.frame.width, height: 36)
        
        
        
        searchBarPlaceHolder.addSubview(searchBar)
        //
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        //search bar properties
        definesPresentationContext = true
        
        searchBar.barTintColor = UIColor.white
        searchBar.layer.cornerRadius = 10
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.init(red: 72/255, green: 160/255, blue: 192/255, alpha: 1).cgColor
        var searchbarTextField = searchBar.value(forKey: "searchField") as? UITextField
        
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        
        definesPresentationContext = true
        
        // searchbarTextField?.textColor = UIColor.
        
        //setText()
        
        
        
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        
        
        
    }
    
    func addTableview(){
        
        tableView = UITableView(frame: CGRect(x: 10, y: self.view.frame.height-330, width: self.view.frame.width-20, height: 339))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.allowsSelection = false
        tableView.layer.cornerRadius = 15
        
        self.view.addSubview(tableView)
        
        self.tableView.isScrollEnabled = false
        self.tableView.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
    }
    
    func addOverlay(){
        
        
        overlayBlur = UIView(frame: CGRect(x: 0, y: 0, width: self.mapView.frame.width+100, height: self.mapView.frame.height+100))
        overlayBlur.blur(style: UIBlurEffectStyle.dark)
        
    }
    
    func transferCellState(expressOrStandard: String!, dryCleaningCheckBox: Bool!, laundryCheckbox: Bool!) {
        
        
        self.expOrStan = expressOrStandard
        self.drycleaningCheckboxClicked = dryCleaningCheckBox
        self.laundryCheckBoxClicked = laundryCheckbox
        
        
    }
    
    func setText(){
        self.resultSearchController.searchBar.text = "OK"
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfCellData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let defaults = UserDefaults.standard
        
        if(arrayOfCellData[indexPath.row].cell == 1){
            
            let cell = Bundle.main.loadNibNamed("orderType", owner: self, options: nil)?.first as! orderType
            
            cell.delegate = self
            
            if let express = defaults.object(forKey: "isExpress") as? Bool {
                if express {
                    cell.expressButton.layer.borderWidth = 2.0
                    cell.expressButton.layer.borderColor = UIColor.black.cgColor
                } else {
                    cell.standardButton.layer.borderWidth = 2.0
                    cell.standardButton.layer.borderColor = UIColor.black.cgColor
                }
                
            }
            
            if let laundry = defaults.object(forKey: "isLaundry") as? Bool {
                if laundry {
                    cell.laundryCheckBox.isSelected = true
                    cell.laundryCheckBox.setBackgroundImage(UIImage(named: "ic_check_box"), for: .selected)
                } else {
                    cell.dryCleaningCheckBox.isSelected = true
                    cell.dryCleaningCheckBox.setBackgroundImage(UIImage(named: "ic_check_box"), for: .selected)
                }

            }
 
            return cell
            
        }
            
            
        else if(arrayOfCellData[indexPath.row].cell == 2){
            let cell = Bundle.main.loadNibNamed("dryCleaningCell", owner: self, options: nil)?.first as! dryCleaningCell
            
            cell.delegate = self
            
            if let numShirts = defaults.object(forKey: "numShirts"), let numPants = defaults.object(forKey: "numPants"), let numSuits = defaults.object(forKey: "numSuits"), let numJackets = defaults.object(forKey: "numJackets") {
                // set sliders
                cell.shirtSlider.value = numShirts as! Float; cell.pantSlider.value = numPants as! Float;cell.suitSlider.value = numSuits as! Float; cell.jacketSlider.value = numJackets as! Float;
                // set text
                cell.shirtSliderValue.text = "\(numShirts)"
                cell.pantSliderValue.text = "\(numPants)"
                cell.suitSliderValue.text = "\(numSuits)"
                cell.jacketSliderValue.text = "\(numJackets)"
            }
            
            if(defaults.object(forKey: "genderOptions") as! Int! == 1){
                cell.optionsSegment.selectedSegmentIndex = 0
            }
            else if(defaults.object(forKey: "genderOptions") as! Int! == 2){
                cell.optionsSegment.selectedSegmentIndex = 1
            }
            else if(defaults.object(forKey: "genderOptions") as! Int! == 3){
                cell.optionsSegment.selectedSegmentIndex = 2
            }
            
            
            return cell
        }
        else if(arrayOfCellData[indexPath.row].cell == 3){
            let cell = Bundle.main.loadNibNamed("laundryCell", owner: self, options: nil)?.first as! laundryCell
            cell.delegate = self
            if let bagCount = defaults.object(forKey: "bagCount") as? Int {
                cell.bagSlider.value = Float(bagCount)
                cell.bagSliderValue.text = "\(bagCount)"
            }
            return cell
            
        }
        else if(arrayOfCellData[indexPath.row].cell == 4){
            let cell = Bundle.main.loadNibNamed("specialPreferencesCell", owner: self, options: nil)?.first as! specialPreferencesCell
            cell.delegate = self
            return cell
        }
        else if(arrayOfCellData[indexPath.row].cell == 5){
            
            let cell = Bundle.main.loadNibNamed("orderSummaryCell", owner: self, options: nil)?.first as! orderSummaryCell
            
            cell.delegate = self
            if let numShirts = defaults.object(forKey: "numShirts"), let numPants = defaults.object(forKey: "numPants"), let numSuits = defaults.object(forKey: "numSuits"), let numJackets = defaults.object(forKey: "numJackets") {
                cell.numberOfPants.text = "\(numPants)"
                cell.numberOfSuits.text = "\(numSuits)"
                cell.numberOfShirts.text = "\(numShirts)"
                cell.numberOfJackets.text = "\(numJackets)"
            }
            if let address = defaults.object(forKey: "address") as? String {
                cell.addressLabel.text = address
            }

            cell.addressLabel.layer.cornerRadius = 15
            if let checkedTerms = defaults.object(forKey: "checkedTermsOfOrdering") as? Bool {
                if checkedTerms {
                    cell.termsCheckBox.isSelected = true
                } else {
                    cell.termsCheckBox.isSelected = false
                }
            }
            
            return cell
            
        }
            
            
        else if(arrayOfCellData[indexPath.row].cell == 6){
            
            let cell = Bundle.main.loadNibNamed("scheduleCalendar", owner: self, options: nil)?.first as! scheduleCalendar
            
            cell.delegate = self
            
            if let onDemand = defaults.object(forKey: "isOnDemand") as? Bool {
                if onDemand {
                cell.instantBtn.layer.borderWidth = 2.0
                cell.instantBtn.layer.borderColor = UIColor.black.cgColor
                }
            }
            
            return cell
            
        }
            
        else{
            
            let cell = Bundle.main.loadNibNamed("paymentCell", owner: self, options: nil)?.first as! paymentCell

            cell.delegate = self
            
            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return arrayOfCellData[indexPath.row].height
        
    }
    
    func feedbackScreens(){
        
        orderReturnedLabel.text = "Ordered Returned"
        feedbackView.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        feedbackView.layer.borderWidth = 2.0
        feedbackView.layer.cornerRadius = 30
        
        doneButtonFeedback.layer.cornerRadius = 6
        doneButtonFeedback.layer.borderWidth = 2.0
        doneButtonFeedback.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        
        
        reportIssueView.layer.borderWidth = 2.0
        reportIssueView.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        reportIssueView.layer.cornerRadius = 30
        reportIssueLabel.text = "Report an Issue"
        
        
        
        reportIssueButton.layer.cornerRadius = 6
        reportIssueButton.layer.borderWidth = 2.0
        reportIssueButton.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        reportIssueView.isHidden = true
        
        reportIssueTextView.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        reportIssueTextView.layer.borderWidth = 2.0
        
        reportIssueTextView.layer.cornerRadius = 12
        
        reportIssueSubmitButton.layer.cornerRadius = 6.0
        reportIssueSubmitButton.layer.borderWidth = 2.0
        reportIssueSubmitButton.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        
        
        contactUsView.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        contactUsView.layer.borderWidth = 2.0
        contactUsView.layer.cornerRadius = 30
        contactUsLabel.text = "Contact Us"
        
        contactUsButton.layer.cornerRadius = 6
        contactUsButton.layer.borderWidth = 2.0
        contactUsButton.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        contactUsView.isHidden = true
        
        contactUsTextView.layer.cornerRadius = 12.0
        contactUsTextView.layer.borderWidth = 2.0
        contactUsTextView.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        
        contactUsSubmitButton.layer.cornerRadius = 6.0
        contactUsSubmitButton.layer.borderWidth = 2.0
        contactUsSubmitButton.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        
        
        
        
    }
    
    @IBAction func feedbackDonePressed(_ sender: Any) {
        
        
        self.feedbackView.isHidden = true
        self.overlayBlur.removeFromSuperview()
        
        self.getWashing.isHidden = false
        self.resultSearchController.searchBar.isHidden = false
        
        self.view.viewWithTag(100)?.isHidden = false
        self.searchBarPlaceHolder.isHidden = false
        menuB.isHidden = false
        
        UserDefaults.standard.set("undone", forKey: "search")
        
    }
    
    @IBAction func reportIssuePressed(_ sender: Any) {
        
        feedbackView.isHidden = true
        reportIssueView.isHidden = false
        
        
    }
    
    @IBAction func reportIssueSubmitButtonPressed(_ sender: Any) {
        
        
        feedbackView.isHidden = false
        reportIssueView.isHidden = true
        
        
        
    }
    
    
    
    @IBAction func contactUsButtonClicked(_ sender: Any) {
        
        
        self.feedbackView.isHidden = true
        self.contactUsView.isHidden = false
        
    }
    
    @IBAction func contactUsSubmitButtonClicked(_ sender: Any) {
        
        self.contactUsView.isHidden = true
        self.feedbackView.isHidden = false
        
        
    }
    
    func transferInfo(cell: dryCleaningCell, shirts: Int!, pants: Int!, suits: Int!, jackets: Int!) {
        
        numberOfShirts = String(shirts)
        numberOfPants = String(pants)
        numberOfSuits = String(suits)
        numberOfJackets = String(jackets)
        
        
    }
    
    func cellButtonTapped(cell: orderType) { // Order Type Chosen
        UIView.animate(withDuration: 0.3) {
            if let isLaundry = UserDefaults.standard.object(forKey: "isLaundry") as? Bool {
                if isLaundry {
                    self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-350, width: self.view.frame.width-20, height: 340)
                    self.view.addSubview(self.tableView)
                    
                    self.tableView.scrollRectToVisible( CGRect(x: 0, y: self.arrayOfCellData[1].yCoor+self.arrayOfCellData[1].height, width: self.view.frame.width, height: 340), animated: true)
                    
                    IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = true
                } else {
                    self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-374, width: self.view.frame.width-20, height: 364)
                    // self.view.addSubview(self.tableView)
                    
                    self.tableView.scrollRectToVisible( CGRect(x: 0, y:self.arrayOfCellData[0].yCoor+self.arrayOfCellData[0].height, width: self.view.frame.width, height: 364), animated: true)
                }
            }
        }
    }
    
    func nextPressed(cell: dryCleaningCell) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-410, width: self.view.frame.width-20 , height: 400)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: self.arrayOfCellData[2].yCoor+self.arrayOfCellData[2].height, width: self.view.frame.width, height: 400), animated: true)
            
        }
    }
    
    
    func backPressed(cell: dryCleaningCell) {
        
        UIView.animate(withDuration: 0.3) {
            
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-340, width: self.view.frame.width-20, height: 330)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 330), animated: true)
            
            //self.view.addSubview(self.tableView)
            
        }
    }
    
    
    func laundryCellButtonTapped(cell: laundryCell) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-410, width: self.view.frame.width-20 , height: 400)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: self.arrayOfCellData[2].yCoor+self.arrayOfCellData[2].height, width: self.view.frame.width, height: 400), animated: true)
            
        }
    }
    
    func specialNextPressed(cell: specialPreferencesCell) {
        
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-460, width: self.view.frame.width-20 , height: 450)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: self.arrayOfCellData[3].yCoor+self.arrayOfCellData[3].height, width: self.view.frame.width, height: 450), animated: true)
            
        }
        
        print(numberOfShirts)
    }
    
    func addSpecialPreferences(cell: specialPreferencesCell, h: Int) {
        
    }
    
    func cancelPressed(cell: specialPreferencesCell) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-410, width: self.view.frame.width-20 , height: 400)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: self.arrayOfCellData[2].yCoor+self.arrayOfCellData[2].height, width: self.view.frame.width, height: 400), animated: true)
            
        }
    }
    
    
    func donePressed(cell: specialPreferencesCell) {
        
        UIView.animate(withDuration: 0.1) {
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-410, width: self.view.frame.width-20 , height: 400)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: self.arrayOfCellData[2].yCoor+self.arrayOfCellData[2].height, width: self.view.frame.width, height: 400), animated: true)
        }
        
    }
    
    func schedulePressed() {
        
        UIView.animate(withDuration: 0.3) {
            
            self.calendarView.isHidden = false
            self.tableView.isHidden = true
            
        }

    }
    
    func orderSummaryNextClicked(cell: orderSummaryCell) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-200, width: self.view.frame.width-20 , height: 190)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: 2022, width: self.view.frame.width, height: 190), animated: true)
            
        }
        
    }
    
    
    func OrderPressed(cell: paymentCell) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.isHidden = true
            self.feedbackView.isHidden = false
            
        }
        
        let ud = UserDefaults.standard
        ud.set(" ", forKey: "StandardOrExpress")
        ud.set(" ", forKey: "dryCleaningCheckBox")
        
        if let express = ud.object(forKey: "isExpress") as? Bool, let laundry = ud.object(forKey: "isLaundry") as? Bool, let onDemand = ud.object(forKey: "isOnDemand") as? Bool, let address = ud.object(forKey: "address") as? String, let clientId = FIRAuth.auth()?.currentUser?.uid, let prefs = ud.object(forKey: "specialPreferences") as? String, let price = ud.object(forKey: "price") {
            
            // un-geocode address
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                }
                if let pm = placemarks.first {
                    if let street = pm.thoroughfare, let city = pm.locality, let state = pm.administrativeArea, let zip = pm.postalCode {
                        
                        // Address Info Good
                        
                        let h = HomeAddress(aStreetAddress: street, aCity: city, aState: state, aZip: zip, aptNumber: nil)
                        h.getGeo(finished: { (success) in
                            if success {
                                
                                // Check Ordering Situation
                                if onDemand {
                                    let order = Order()
                                    order.orderID = firebase.childByAutoId().key
                                    order.clientID = clientId
                                    order.isOnDemand = onDemand
                                    order.location = h
                                    order.isExpress = express
                                    order.isLaundry = laundry
                                    order.specialPreferences = prefs
                                    order.review = OrderReview() // Changed later when order comes back
                                    order.status = OrderStatus.readyForPickup
                                    order.price = 15 // Algorithm should be here
                                 //   order.scheduledTimes
                                    
                                } else {
                                    let order = Order()
                                    order.orderID = firebase.childByAutoId().key
                                    order.clientID = clientId
                                    order.isOnDemand = onDemand
                                    order.location = h
                                    order.isExpress = express
                                    order.isLaundry = laundry
                                    order.specialPreferences = prefs
                                    order.review = OrderReview() // Changed later when order comes back
                                    order.status = OrderStatus.readyForPickup
                                    order.price = 15 // Algorithm should be here
                                    var inv = Inventory()
                                    
                                    // init inventory
                                    if laundry {
                                        if let bags = ud.integer(forKey: "bagCount") as? Int{
                                            inv.bagCount = bags
                                        } else { /* Error */ }
                                    } else {
                                        if let shirts = ud.integer(forKey: "numShirts") as? Int, let pants = ud.integer(forKey: "numPants") as? Int,  let ties = ud.integer(forKey: "numTies") as? Int, let suits = ud.integer(forKey: "numSuits") as? Int, let jackets = ud.integer(forKey: "numJackets") as? Int, let dresses = ud.integer(forKey: "numDresses") as? Int {
                                            inv.numSuits = suits; inv.numTies = ties; inv.numShirts = shirts; inv.numPants = pants; inv.numDresses = dresses; inv.numJackets = jackets;
                                        }
                                    }
                                    order.inventory = inv
                                    
                                    // init scheduled orders
                                    if let orderDates = ud.array(forKey: "scheduledOrderDates") as? [String] {
                                        for date in orderDates {
                                            order.scheduledTimes?.append(date)
                                        }
                                     
                                    } else if let dayOfWeek = ud.object(forKey: "scheduledDayOfWeek") as? String, let dowTime = ud.object(forKey: "scheduledDayOfWeekTime") as? String {
                                        order.scheduledTimes?.append("\(dayOfWeek) at \(dowTime)")
                                    }
                                
                                    
                                    // Create Order
                                    
                                    order.findLaundromat(finished: { (success) in
                                        if success {
                                            order.dbCreate(finished: { (success) in
                                                
                                                if success {
                                                    
                                                    order.moveToOpenOrders()
                                                    
                                                } else {
                                                    // Error
                                                }
                                            })
                                        } else {
                                            // Error
                                        }
                                    })
                                    
                                    
                                    
                                }
                                
                                
                                
                            }
                        })
                        
                    } else {
                        // Error
                    }
                
                } else {
                    // Error
                }
                // Use your location
            }
            
            
        }
 
    }
    
    @IBOutlet weak var calendar: FSCalendar!
    
    
    func backBtnPressed() {
        
        
        UIView.animate(withDuration: 0.3) {2
            
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-460, width: self.view.frame.width-20 , height: 450)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: self.arrayOfCellData[3].yCoor+self.arrayOfCellData[3].height, width: self.view.frame.width, height: 450), animated: true)
            
            
            
        }
        
    }
    
    func paymentScreenBackPressed() {
        
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-200, width: self.view.frame.width-20 , height: 190)
            
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: 2022, width: self.view.frame.width, height: 190), animated: true)
            
        }
        
    }
    
    @IBOutlet weak var menuB: UINavigationBar!
    
    @IBAction func LetsGetWashingAction(_ sender: Any) {
        
        print(self.resultSearchController.searchBar.text)
        LetsGetWashingActionCode()
    }
    
    func LetsGetWashingActionCode(){
        
        
        delegate3?.closeSearchField(but: self.getWashing)
        UserDefaults.standard.set("done", forKey: "search")
        
        //self.mapView.blur(style: UIBlurEffectStyle.dark)
        self.getWashing.isHidden = true
        self.resultSearchController.searchBar.isHidden = true
        self.view.viewWithTag(100)?.isHidden = true
        self.navigationController?.isToolbarHidden = true
        self.searchBarPlaceHolder.isHidden = true
        
        
        
        menuB.isHidden = true
        
        print("LETSGETWASHINGMETHOD")
        print(UserDefaults.standard.object(forKey: "search"))
        
        
        self.tableView.isHidden = false
        self.tableView.scrollsToTop = true
        
        tableView.frame = CGRect(x: 10, y: self.view.frame.height-340, width: self.view.frame.width-20, height: 330)
        
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 330), animated: false)
        
        self.view.addSubview(tableView)
        
        resultSearchController.searchBar.isHidden = true
        
        resultSearchController.dismiss(animated: true, completion: nil)
        
        
        
        
        
        SavedStates.set(" ", forKey: "StandardOrExpress")
        
        SavedStates.set(" ", forKey: "dryCleaningCheckBox")
        
        SavedStates.set(" ", forKey: "isLaundry")
        
        
        //drycleaning cell
        
        SavedStates.set(0, forKey: "genderOptions")
        SavedStates.set(0, forKey: "numberOfShirts")
        SavedStates.set(0, forKey: "numberOfPants")
        SavedStates.set(0, forKey: "numberOfSuits")
        SavedStates.set(0, forKey: "numberOfJackets")
        
        //laundry
        SavedStates.set(0, forKey: "numberOfBags")
        
        
        //       UserDefaults.standard.set(resultSearchController.searchBar.text, forKey: "address")
        
        feedbackView.isHidden = true
        reportIssueView.isHidden = true
        
        laundryCheckBoxClicked = false
        drycleaningCheckboxClicked = false
        
        //self.view.addSubview(overlayBlur)
        
        
        
        mapView.addSubview(overlayBlur)
        
        
        
    }
    
    func backButtonPressed() {
        
        UIView.animate(withDuration: 0.3) {
            
            
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-340, width: self.view.frame.width-20, height: 330)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 330), animated: true)
            
            
        }
        
    }
    
    func getDirections(){
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
        
    }
    
    func sideMenus(){
        
        if revealViewController() != nil{
            
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 200
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            
        }
        
    }
    
    @IBAction func calendarNextButtonPressed(_ sender: Any) {
        
        
        
        
        UIView.animate(withDuration: 0.3) {
            
            self.calendarView.isHidden = true
            
            self.tableView.isHidden = false
            
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-535, width: self.view.frame.width-20 , height: 525)
            
            
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: 2352, width: self.view.frame.width, height: 525), animated: true)
            
            
            UserDefaults.standard.set("Selected", forKey: "Scheduled")
            UserDefaults.standard.set("Unselected", forKey: "Instant")
            
            
        }
        
    }
    
    func cancelOrderScheme() {
        
        self.tableView.isHidden = true
        self.overlayBlur.removeFromSuperview()
        
        self.getWashing.isHidden = false
        self.resultSearchController.searchBar.isHidden = false
        
        self.view.viewWithTag(100)?.isHidden = false
        self.menuB.isHidden = false
        self.searchBarPlaceHolder.isHidden = false
        
        
        
        
    }
    
    var delegate1 : scheduleScreenDelegate?
    
    func buttonHeight() -> Int!{
        
        return Int(self.getWashing.frame.height)
        
        
    }
    
    @IBAction func instantButtonPressed(_ sender: Any) {
        
        print("FUCKFUCKFUCKUFCKMEMEMEME")
        UserDefaults.standard.set("Selected", forKey: "Instant")
        UserDefaults.standard.set("Unselected", forKey: "Scheduled")
        UIView.animate(withDuration: 0.3) {
            
            self.calendarView.isHidden = true
            
            self.tableView.isHidden = false
            self.tableView.reloadData()
            
            
        }
        
        
        print(UserDefaults.standard.object(forKey: "Instant"))
        
        delegate1?.highlightInstant(high: true)
        
        
    }
    
    func backPressed() {
        
        let ud = UserDefaults.standard
        
        if let laundry = ud.bool(forKey: "isLaundry") as? Bool {
            if !laundry {
                UIView.animate(withDuration: 0.3) {
                    
                    self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-374, width: self.view.frame.width-20, height: 364)
                    // self.view.addSubview(self.tableView)
                    
                    self.tableView.scrollRectToVisible( CGRect(x: 0, y:self.arrayOfCellData[0].yCoor+self.arrayOfCellData[0].height, width: self.view.frame.width, height: 364), animated: true)
                    
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    
                    
                    
                    
                    self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-350, width: self.view.frame.width-20, height: 340)
                    self.view.addSubview(self.tableView)
                    
                    self.tableView.scrollRectToVisible( CGRect(x: 0, y: self.arrayOfCellData[1].yCoor+self.arrayOfCellData[1].height, width: self.view.frame.width, height: 340), animated: true)
                    
                    IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = true
                    
                }
            }
            
            
        } else {
            // Error
        }
    }
    
    func orderSummaryBack() {
        
        UIView.animate(withDuration: 0.3) {
            
            
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-410, width: self.view.frame.width-20 , height: 400)
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: self.arrayOfCellData[2].yCoor+self.arrayOfCellData[2].height, width: self.view.frame.width, height: 400), animated: true)
            
        }
        
        
    }
    
    func nextPressed() {
        
        UIView.animate(withDuration: 0.3) {
            
            
            //self.tableView.isHidden = false
            
            
            self.tableView.frame = CGRect(x: 10, y: self.view.frame.height-535, width: self.view.frame.width-20 , height: 525)
            
            
            
            self.view.addSubview(self.tableView)
            
            self.tableView.scrollRectToVisible(CGRect(x: 0,y: 2352, width: self.view.frame.width, height: 525), animated: true)
            
        }
        
    }
    
    func show() {
        self.getWashing.isHidden = false
        
    }
    func hide() {
        self.getWashing.isHidden = true
        
        
    }
    
    func currLocPressed(addy: String!) {
        
        LetsGetWashingActionCode()
        
        
    }
 
    func addToCalendar(date: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        var c : Int = 0
        
        if(calendar.cell(for: date, at: .current).numberOfEvents != 0){
            
            c = events.index(of: formatter.string(from: date))!
            
            let temp = numberOfEvents[c] + 1
            numberOfEvents[c] = temp
            
        }
        else{
            events.append(formatter.string(from: date))
            numberOfEvents.append(1)
            
        }
        
        //events.append(formatter.string(from: date))
        calendar.reloadData()
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        if(self.events.contains(formatter.string(from: date))){
            return numberOfEvents[events.index(of: formatter.string(from: date))!]
            
            
        }
        
        return 0
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "s"){
       
            let destVC : schedulePickerViewController = segue.destination as! schedulePickerViewController
            destVC.delegate = self
            
        }

    }

}


extension mapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        //  mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

extension mapViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        
        self.address = placemark.title
        
        print("Address: \(address)")
        
        
        
        
        
        
    }
    
    
    
}

extension mapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
        button.addTarget(self, action: #selector(mapViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
}


class UnderlinedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.characters.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
        }
    }
}


