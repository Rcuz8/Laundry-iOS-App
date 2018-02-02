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
import SCLAlertView

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

class mapViewController: UIViewController, STPPaymentCardTextFieldDelegate, UITableViewDelegate, UITableViewDataSource, orderTypeDelegate, dryCleaningDelegate, laundryDelegate, specialPreferencesDelegate, orderSummaryDelegate, paymentDelegate, openCalendar, hide_Show_Button, straightToGetWashing, FSCalendarDataSource, FSCalendarDelegate, closed, MenuDisplay {
    
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
    var getWashing: UIButton!
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
    
    var menu: UIButton?
    
    var stripeCustomerId: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   UserDefaults.standard.removeAll()
        
        
        
        //  let x = FSCalendar()
        let testVc = schedulePickerViewController()
        testVc.delegate = self
        
        
        
        self.navigationItem.titleView?.isHidden = true
        
        
        addTableview()
        sideMenus()
        mapViewSettings()
        addOverlay()
        feedbackScreens()
        addgetWashing()
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
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40.0)
        
        addMenu()
        
    }
    
    func addMenu() {
        let x = partOfScreenWidth_d(percentage: 3)
        let y = partOfScreenWidth_d(percentage: 12)
        let w = partOfScreenWidth_d(percentage: 10)
        let h = partOfScreenWidth_d(percentage: 10)
        
        // make temp menu
        let temporaryMenu = UIButton(frame: CGRect(x: x, y: y, width: w, height: h))
        let menuOnTap = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        let img = UIImage(named: "menu")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        temporaryMenu.tintColor = UIColor.black
        temporaryMenu.setImage(img, for: .normal)
        temporaryMenu.addGestureRecognizer(menuOnTap)
        
        self.menu = temporaryMenu
        after(0.05) {
            if let m = self.menu {
                self.view.addSubview(m)
            } else {
                self.view.addSubview(temporaryMenu)
                print("Not good . .  could not get menu? value")
            }
        }
    }
    
    func showMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = 200
            self.revealViewController().revealToggle(animated: true)
        }else {
            print("MapVC: showMenu: Error: cannot find revealVC")
        }
    }
    
   
    
    func addgetWashing() {
        getWashing = UIButton(type: UIButtonType.system)
        print(getWashing)
        print(searchBarPlaceHolder)
        
        getWashing.frame = CGRect(x: searchBarPlaceHolder.frame.origin.x+10, y: searchBarPlaceHolder.frame.origin.y+searchBarPlaceHolder.frame.height+10, width: self.view.frame.width-(2*(searchBarPlaceHolder.frame.origin.x+10)), height: 36)
        getWashing.backgroundColor = UIColor.lavoDarkBlue
        getWashing.setTitle("Let's Get Washing", for: .normal)
        getWashing.layer.cornerRadius = 8
        getWashing.setTitleColor(UIColor.white, for: .normal)
        
        getWashing.addTarget(self, action: #selector(LetsGetWashingActionCode), for: .touchUpInside)
        
        self.view.addSubview(getWashing)
    }
    
    func mapViewSettings(){

        
        
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.menuDisplay = self
        locationSearchTable.delegate1 = self
        let selectLocationVC = storyboard!.instantiateViewController(withIdentifier: "selectLocationViewController2") as! SelectLocationViewController2
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        var searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
       // locationSearchTable.searchBar = searchBar
        let font = UIFont(name: "AppleColorEmoji", size: 15)
        
        let searchBarY = CGFloat(partOfScreenHeight_f(percentage: 7))
        let searchBarW = CGFloat(partOfScreenWidth_f(percentage: 70))
        searchBarPlaceHolder = UIView(frame: CGRect(x: self.view.frame.width/6, y: searchBarY ,width: searchBarW, height: 42))
        searchBarPlaceHolder.backgroundColor = UIColor.black
        searchBarPlaceHolder.layer.cornerRadius = 10
        
        
        self.view.addSubview(searchBarPlaceHolder)
    //    searchBar = themedSearchBar(searchBar: searchBar, mainColor: UIColor.lavoSlightlyDarkBlue, secondaryColor: UIColor.white)
     //   searchBar.setTheme(mainColor: UIColor.lavoSlightlyDarkBlue, secondaryColor: UIColor.white)
        searchBar.frame = CGRect(x: 0, y:0, width: searchBarPlaceHolder.frame.width, height: 42)
        
        definesPresentationContext = true
        
      // BEGIN
        
        searchBar.barTintColor = UIColor.white
        searchBar.layer.cornerRadius = 10
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.init(red: 72/255, green: 160/255, blue: 192/255, alpha: 1).cgColor
        var searchbarTextField = searchBar.value(forKey: "searchField") as? UITextField
        
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true

        
        
        searchBar.tintColor = UIColor.lavoSlightlyDarkBlue
        searchBar.barTintColor = UIColor.lavoSlightlyDarkBlue
        searchBar.layer.borderColor = UIColor.lavoSlightlyDarkBlue.cgColor
        
        searchbarTextField?.textColor = UIColor.white
        searchbarTextField?.backgroundColor = UIColor.lavoSlightlyDarkBlue
        searchbarTextField?.font = font
        searchBar.setMagnifyingGlassColorTo(color: .white)
        
        searchBar.setTextColor(color: UIColor.white)
        searchBar.setPlaceholderTextColorTo(color: UIColor.white)
        
        searchBarPlaceHolder.addSubview(searchBar)
        
        let v: UIView = searchBar.subviews[0] as UIView
        let subViewsArray = v.subviews
        
        for subView: UIView in subViewsArray {
            if subView.isKind(of: UITextField.self) {
                subView.tintColor = UIColor.white
            }
        }

  //   END
        
        // Replaced with:
        
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        selectLocationVC.mapView = mapView
        selectLocationVC.handleMapSearchDelegate = self
        
        
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
            
            if let options = defaults.object(forKey: "genderOptions") as? Int {
                switch options {
                    case 1:
                        cell.optionsSegment.selectedSegmentIndex = 0
                    break
                    case 2:
                        cell.optionsSegment.selectedSegmentIndex = 1
                    break
                    case 3:
                        cell.optionsSegment.selectedSegmentIndex = 1
                    break
                default:
                    cell.optionsSegment.selectedSegmentIndex = 0
                }
                
                
            } else {
                // Error
                print("mapVC: Cannot find selected segment infex for dry cleaning!")
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
            
            if let cell = Bundle.main.loadNibNamed("SecondPaymentCell", owner: self, options: nil)?.first as? SecondPaymentCell {
           //     print("found second payment cell")
                cell.delegate = self
                
                return cell
            }else if let cell = Bundle.main.loadNibNamed("SecondPaymentCell", owner: self, options: nil)?.first {
        //        print("found a cell")
                let cell = SecondPaymentCell()
                cell.delegate = self
                return cell
            } else {
                print("could not find second payment cell")
                let cell = SecondPaymentCell()
                cell.delegate = self
                return cell
            }
            
            
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
    
    // toggle whole UI
    func toggleUI(searchTableShouldBePresented tablePresented: Bool) {
        print("toggling UI . . .")
        if tablePresented { // showing view, hide this UI
            menu?.isHidden = true
            searchBarPlaceHolder.backgroundColor = UIColor.lavoDarkBlue
            resultSearchController.searchBar.backgroundColor = UIColor.lavoDarkBlue
            getWashing.isHidden = true
            
            let cancelButtonAttributes: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.black]
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
            
        }else{   // hiding view, show this UI
            menu?.isHidden = false
            searchBarPlaceHolder.backgroundColor = UIColor.veryVeryLightGray
            resultSearchController.searchBar.backgroundColor = UIColor.veryVeryLightGray
            getWashing.isHidden = false
            
            let cancelButtonAttributes: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
            
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
            
        }
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
    
    func createOrderInDatabase() {
        
    }
    
    // ------------------------ Order -------------------------- //
    func OrderPressed(cell: SecondPaymentCell) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.tableView.isHidden = true
            self.feedbackView.isHidden = false
            
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
    
    
    func LetsGetWashingActionCode(){
        
        if let address = UserDefaults.standard.object(forKey: "address") as? String {
            //
        } else {
            SCLAlertView().showError("Oops", subTitle: "Please select a location!")
            return
        }
        toggleUI(searchTableShouldBePresented: false)
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
        
        let def = UserDefaults.standard
     //   def.removeAll() --> NOT YET

        feedbackView.isHidden = true
        reportIssueView.isHidden = true
        
        laundryCheckBoxClicked = false
        drycleaningCheckboxClicked = false
        
        
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
        print("mapVC: pressed current location!")
        resultSearchController.searchBar.text = addy
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

    func themedSearchBar(searchBar bar: UISearchBar, mainColor: UIColor, secondaryColor: UIColor) -> UISearchBar {
        var searchBar = bar
        searchBar.barTintColor = secondaryColor //s
        searchBar.layer.cornerRadius = 10
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.black.cgColor // idk
        var selfTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        searchBar.tintColor = mainColor //m
        searchBar.barTintColor = mainColor //m
        searchBar.layer.borderColor = mainColor.cgColor //m
        
        selfTextField?.textColor = secondaryColor //s
        selfTextField?.backgroundColor = mainColor //m
        let font = UIFont(name: "AppleColorEmoji", size: 15)
        selfTextField?.font = font
        searchBar.setMagnifyingGlassColorTo(color: secondaryColor) //s
        searchBar.setTextColor(color: secondaryColor) //s
        searchBar.setPlaceholderTextColorTo(color: secondaryColor) //s
        
        let v: UIView = searchBar.subviews[0] as UIView
        let subViewsArray = v.subviews
        
        for subView: UIView in subViewsArray {
            if subView.isKind(of: UITextField.self) {
                subView.tintColor = secondaryColor //s
            }
        }
        
        return searchBar
        
    }
    
    
}
//extension UIViewController {
//    func changeBackgroundColor(forSearchBar searchBar: UISearchBar, toColor color: UIColor) {
//        let holder = searchBar.placeholder!
//        searchBar.placeholder = holder
//        for subView in searchBar.subviews {
//            for subViewInSubView in subView.subviews {
//                if subViewInSubView.isKind(of: UITextField) {
//                    subViewInSubView.backgroundColor = color
//                }
//            }
//        }
//    }
//}

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

extension mapViewController: STPAddCardViewControllerDelegate {
    func showAddCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // STPAddCardViewController must be shown inside a UINavigationController.
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func saveCard(token: STPToken) {
        
        API.postNewCard(customerId: stripeCustomerId, token: token).then { res -> Void in
            self.dismiss(animated: true)
            }
            .catch { err in print(err.localizedDescription) }
    }
    
    // MARK: STPAddCardViewControllerDelegate
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        print("TOKEN\(token)")
        saveCard(token: token)
        completion(nil)
        
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

public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
}

extension UISearchBar
{
    func setPlaceholderTextColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
    
    
    func setMagnifyingGlassColorTo(color: UIColor)
    {
        // Search Icon
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }

//    func setTheme(mainColor: UIColor, secondaryColor: UIColor) {
//        self.barTintColor = secondaryColor //s
//        self.layer.cornerRadius = 10
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.black.cgColor // idk
//        var selfTextField = self.value(forKey: "searchField") as? UITextField
//        self.layer.masksToBounds = true
//        self.clipsToBounds = true
//        self.tintColor = mainColor //m
//        self.barTintColor = mainColor //m
//        self.layer.borderColor = mainColor.cgColor //m
//        
////        selfTextField?.textColor = secondaryColor //s
////        selfTextField?.backgroundColor = mainColor //m
////        let font = UIFont(name: "AppleColorEmoji", size: 15)
////        selfTextField?.font = font
////        self.setMagnifyingGlassColorTo(color: secondaryColor) //s
////        self.setTextColor(color: secondaryColor) //s
////        self.setPlaceholderTextColorTo(color: secondaryColor) //s
////        
////        let v: UIView = self.subviews[0] as UIView
////        let subViewsArray = v.subviews
////        
////        for subView: UIView in subViewsArray {
////            if subView.isKind(of: UITextField.self) {
////                subView.tintColor = secondaryColor //s
////            }
////        }

        
    
    
}


