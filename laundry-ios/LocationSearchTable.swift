//
//  LocationSearchTable.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 7/23/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import SCLAlertView
protocol hide_Show_Button {
    func hide()
    func show()
}

protocol straightToGetWashing {
    func currLocPressed(addy: String!)
}

struct Screen {
    let Height = UIScreen.main.bounds.height
    let Width = UIScreen.main.bounds.width
    
    func part(percentHeight: Int) -> CGFloat {
        return (CGFloat(CGFloat(percentHeight)*0.01) * Height)
    }
    func part(percentWidth: Int) -> CGFloat {
        return (CGFloat(CGFloat(percentWidth)*0.01) * Width)
    }
}
protocol MenuDisplay {
 //   func menuIsHidden(isHidden: Bool)
    func toggleUI(searchTableShouldBePresented tablePresented: Bool)
}

class LocationSearchTable: UITableViewController, closeSearch, CLLocationManagerDelegate   {
    
    
    var savedLocationTableView: UITableView!
    
    var recentLocationsTableView: UITableView!
    
    var locationsSaved = [(name: String, location: String)]()
    var locationsRecent = [String]()
    
    var addressString : String  = ""
    
    var currentAddressString : String?
    
    var startingLocation : String!
   // var tableV : UITableView!
    var rowNames : [String] = []
    
    var recentItems : [String] = []
    
    var layoverView : UIView!
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    let manager = CLLocationManager()
     var searchBar : UISearchBar!
    
    var closeSearch : UIButton!
    
    var delegate : hide_Show_Button?
    var delegate1 : straightToGetWashing?
    var savedLocations = [(name: String, location: HomeAddress)]()
    
    var searchBarPlaceHolder : UIView!
    var menuDisplay: MenuDisplay?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView?.showsUserLocation = true
        
        // Initialize
            initializeManager()
            integrateBackgroundUI();
            initializeTableViews()
       // self.tableView.set(type: .search)
        
     //   menuDisplay?.menuIsHidden(isHidden: true)
        
    }
    
    func initializeManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    let searchWidth = Screen().part(percentHeight: 70)
    
    func integrateBackgroundUI() {
        
        // UI Variables
        
            // Layover View
        
                let width = Screen().part(percentWidth: 100)
                let height = Screen().part(percentHeight: 100)
                let xMargin: CGFloat = 0 /*Screen().part(percentWidth: 5)*///  --> Zeros to cover full screen
                let yMargin: CGFloat = 0 /*Screen().part(percentHeight: 5)*/
        
            // Search Bar
        
                let searchBarY = Screen().part(percentHeight: 7)
                let searchBarW = Screen().part(percentHeight: 70)
        
            // Other
        
                let seperatorHeight = Screen().part(percentWidth: 1)
                let currentLocHeight = Screen().part(percentHeight: 5)
                let closeSearchHeight = Screen().part(percentHeight: 3)
                let tblViewHeight = Screen().part(percentHeight: 25)
                let labelHeight = Screen().part(percentHeight: 5)
                let cgW = CGFloat(width)
        
            // Y values
        
                let currentLocY = Screen().part(percentHeight: 13)
                let closeSearchY = Screen().part(percentHeight: 1)
                let savedLocLblY = currentLocY+currentLocHeight+seperatorHeight
                let savedLocsTableViewY = savedLocLblY+labelHeight+seperatorHeight
                let recentLocaLabelY = savedLocsTableViewY+tblViewHeight+seperatorHeight
                let recentLocaTableViewY = recentLocaLabelY+labelHeight+seperatorHeight
        // END UI Variables
        
        // UI Methods
        
            // Init Layoverview
            
            func initLayoverAndSearchBar() {
                layoverView = UIView(frame: CGRect(x: xMargin, y: yMargin, width: width, height: height))
                layoverView.backgroundColor = UIColor.veryLightGray
                
                let searchBarStool = CGRect(x: self.view.frame.width/6.3, y: 0 ,width: searchBarW, height: 42)
                searchBarPlaceHolder = UIView(frame: searchBarStool)
            }

            //use current location button
            
            func addCurrentLocationButton() {
                var currentLocation : UIButton!
                
                currentLocation = UIButton(type: UIButtonType.system)
                currentLocation.frame = CGRect(x: 0, y: currentLocY, width: width, height: currentLocHeight)
                currentLocation.setTitle("Use Current Location", for: .normal)
                currentLocation.setTitleColor(UIColor.black, for: .normal)
                currentLocation.backgroundColor = UIColor.veryVeryLightGray
                currentLocation.layer.borderWidth = 1.0
                currentLocation.layer.borderColor = UIColor.black.cgColor
                currentLocation.addTarget(self, action: #selector(useCurrentLocation), for: .touchUpInside)
                currentLocation.setImage(UIImage(named: "ic_washer"), for: .normal)
                layoverView.addSubview(currentLocation)
                addSeparator(belowButton: currentLocation)
            }
            
            // Generic Separator method
            func addSeparator(belowButton button: UIButton) {
                var seperator : UIView!
                seperator = UIView(frame: CGRect(x: 0, y: button.frame.origin.y+button.frame.height, width:cgW, height: seperatorHeight))
                seperator.backgroundColor = UIColor.lightGray
                seperator.layer.borderWidth = 1.0
                seperator.layer.borderColor = UIColor.black.cgColor
                layoverView.addSubview(seperator)
            }
            func addSeparator(belowTableView tblView: UITableView) {
                var seperator : UIView!
                seperator = UIView(frame: CGRect(x: 0, y: tblView.frame.origin.y+tblView.frame.height, width:cgW, height: seperatorHeight))
                seperator.backgroundColor = UIColor.lightGray
                seperator.layer.borderWidth = 1.0
                seperator.layer.borderColor = UIColor.black.cgColor
                layoverView.addSubview(seperator)
            }
        
            // Add SavedLocations label
            func addSavedLocationsLabel() {
                var savedLocations : UILabel!
                savedLocations = UILabel(frame: CGRect(x: 0, y: savedLocLblY, width: cgW, height: labelHeight))
                
                savedLocations.layer.borderWidth = 1.0
                savedLocations.layer.borderColor = UIColor.black.cgColor
                savedLocations.text = "Saved Locations"
                savedLocations.textAlignment = NSTextAlignment.center
                savedLocations.backgroundColor = UIColor.veryVeryLightGray
                
                layoverView.addSubview(savedLocations)
            }
            func addSavedLocationTable() {
                savedLocationTableView = UITableView(frame: CGRect(x: 0.0, y: savedLocsTableViewY, width: cgW , height: tblViewHeight))
                savedLocationTableView.separatorInset = UIEdgeInsets(top: 2.0, left: 0, bottom: 2.0, right: 0)
            //    savedLocationTableView.set(type: .recentLocations)
                layoverView.addSubview(savedLocationTableView)
                
                //second seperator
                addSeparator(belowTableView: savedLocationTableView)
            }
     
            // Add RecentLocations label
            func addRecentLocationsLabel() {
                var recentLocations : UILabel!
                recentLocations = UILabel(frame: CGRect(x: 0, y: recentLocaLabelY, width: cgW, height: labelHeight))
                
                recentLocations.layer.borderWidth = 1.0
                recentLocations.layer.borderColor = UIColor.black.cgColor
                recentLocations.text = "Recent Locations"
                recentLocations.textAlignment = NSTextAlignment.center
                recentLocations.backgroundColor = UIColor.veryVeryLightGray
                
                layoverView.addSubview(recentLocations)
            }

            func addRecentLocationsTable() {
                recentLocationsTableView = UITableView(frame: CGRect(x: 0.0, y: recentLocaTableViewY, width: cgW , height: tblViewHeight))
                recentLocationsTableView.separatorInset = UIEdgeInsets(top: 2.0, left: 0, bottom: 2.0, right: 0)
           //     recentLocationsTableView.set(type: .recentLocations)
                layoverView.addSubview(recentLocationsTableView)
            }
            
            // CloseSearch button --> Closes this view
            
            func addCloseSearchButton() {
                closeSearch = UIButton(type: UIButtonType.system)
                closeSearch.frame = CGRect(x: Screen().part(percentWidth: 3).integer, y:closeSearchY.integer, width: Screen().part(percentWidth: 20).integer, height: closeSearchHeight.integer)
                closeSearch.setTitle("Cancel", for: .normal)
                closeSearch.titleLabel?.font = UIFont().bangla(size: 16)
                closeSearch.setTitleColor(UIColor.black, for: .normal)
                closeSearch.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
                closeSearch.backgroundColor = UIColor.clear
                self.layoverView.addSubview(closeSearch)
            }
        
        // End UI Methods
        
        
        // EXECUTE
        
        initLayoverAndSearchBar()
        addCurrentLocationButton()
        addSavedLocationsLabel()
        addSavedLocationTable()
        addRecentLocationsLabel()
        addRecentLocationsTable()
        addCloseSearchButton()
        
    }
    
    func initializeTableViews() {
        print("Setting all tableviews . . .")
        // Set Type
     //   savedLocationTableView.set(type: .savedLocations)
     //   recentLocationsTableView.set(type: .recentLocations)
     //   tableView.set(type: .search)
        
        
        // Set Delegates & Data Sources
        recentLocationsTableView.delegate = self
        savedLocationTableView.delegate = self
        recentLocationsTableView.dataSource = self
        savedLocationTableView.dataSource = self
        
        recentLocationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "recentLocations")
        savedLocationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "savedLocations")
        
        let db = UserDB()
        if let user = db.getUser() {
            db.getLocations(forUserWithId: user.uid, finished: { (saved, recent) in
                
                self.locationsSaved = saved
                self.locationsRecent = recent
            })
        }
        
    }
    
    func recentCell(rowNum: Int) -> UITableViewCell? {
        if let cell = recentLocationsTableView.dequeueReusableCell(withIdentifier: "recentLocations") as? UITableViewCell {
            
            if locationsRecent.count > rowNum {
                let loc = locationsRecent[rowNum]
                cell.textLabel?.font = UIFont().bangla(size: 18)
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.text = loc
            }
            
            return cell
            
        } else { return nil }
    }
    
    func savedCell(rowNum: Int) -> UITableViewCell? {
        
        if let cell = savedLocationTableView.dequeueReusableCell(withIdentifier: "savedLocations") as? UITableViewCell {
            
            if locationsSaved.count > rowNum {
                let locName = locationsSaved[rowNum].name
                cell.textLabel?.font = UIFont().bangla(size: 18)
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.text = locName
                
                // Customize
                let name = locName.lowercased()
                if name == "work" || name == "job" || name == "office" {
                    cell.accessoryView = UIImageView(image:UIImage(named:"ic_work")!)
                } else if name == "home" {
                    cell.accessoryView = UIImageView(image:UIImage(named:"ic_home")!)
                } else if name == "school" {
                    cell.accessoryView = UIImageView(image:UIImage(named:"ic_school")!)
                }
                // End Customize
                
            }
            
            return cell
            
        } else { return nil }
    }
    
    func blankCell(type: TableViewType) -> UITableViewCell{
        if type == .recentLocations {
            return recentLocationsTableView.dequeueReusableCell(withIdentifier: "recentLocations")! as! UITableViewCell
        } else {
            return savedLocationTableView.dequeueReusableCell(withIdentifier: "savedLocations")! as! UITableViewCell
        }
    }
    
    func closeButtonPressed(){
        self.layoverView.isHidden = true
        self.resignFirstResponder()
        menuDisplay?.toggleUI(searchTableShouldBePresented: false)
    }

    func useCurrentLocation(){
        // Hide View
        self.layoverView.isHidden = true
        if let addressString = UserDefaults.standard.string(forKey: "currentLocation") as? String {
            UserDefaults.standard.set(addressString, forKey: "address")
            
            // Find placemark & Zoom in
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
                if let placemark = placemarks?.first as? MKPlacemark {
                    self.handleMapSearchDelegate?.dropPinZoomIn(placemark)
                }
            }
            
            delegate1?.currLocPressed(addy: addressString)
            menuDisplay?.toggleUI(searchTableShouldBePresented: false)
        } else {
            SCLAlertView().showError("Oops", subTitle: "Could not retrieve your location! Please check that you have location services enabled!")
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
          let location = locations[0]

        self.mapView?.showsUserLocation = true
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
            if error != nil
            {
               // print ("THERE WAS AN ERROR")
            }
            else
            {
                if let place = placemark?[0]
                {
                    if place.subThoroughfare != nil
                    {
                        let str = "\(place.subThoroughfare!) \n \(place.thoroughfare!) \n \(place.country!)"
                        self.currentAddressString = "\(place.subThoroughfare!) \n \(place.thoroughfare!) \n \(place.country!)"
                        
                        UserDefaults.standard.set(str, forKey: "currentLocation")
                        
                    }
                }
            }
        }
        
        
    }
    
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 2
        
        
    }

    func closeSearchField(but: UIButton!) {
        but.isHidden = true
    }
    
    // TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Getting tableview type . . .")
     //   let type = tableView.type
        if tableView == recentLocationsTableView { return locationsRecent.count }
        else if tableView == savedLocationTableView { return locationsSaved.count }
        else { return matchingItems.count }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Getting tableview type . . .")
        if tableView == recentLocationsTableView {
            if let cell = recentCell(rowNum: indexPath.row) { return cell } else { return blankCell(type: .recentLocations) }
        } else if tableView == savedLocationTableView { // Saved Location Cell
            if let cell = savedCell(rowNum: indexPath.row) { return cell } else { return blankCell(type: .savedLocations) }
        } else {
            
            // Search Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            let selectedItem = matchingItems[indexPath.row].placemark
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = parseAddress(selectedItem)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == savedLocationTableView {
            let address = locationsSaved[indexPath.row].location
            UserDefaults.standard.set(address, forKey: "address")
        } else if tableView == recentLocationsTableView {
            let address = locationsRecent[indexPath.row]
            UserDefaults.standard.set(address, forKey: "address")
        } else {
            print("Getting tableview type . . .")
            let selectedItem = matchingItems[indexPath.row].placemark
            handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
            layoverView.isHidden = true
            if let place = selectedItem.title {
                addressString = place
                if let search = searchBar {
                    print("found searchbar within location search table")
                    search.text = place
                } else {
                    print("cannot find search bar")
                }
                if let presentingView = self.presentingViewController as? mapViewController {
                    print("found presenting view")
                    presentingView.resultSearchController.searchBar.text = place
                } else {
                    print("cannot find presenting view as mapViewController")
                }
                UserDefaults.standard.set(place, forKey: "address")
            }
            
            
        }
        menuDisplay?.toggleUI(searchTableShouldBePresented: false)
        dismiss(animated: true, completion: nil)
        
    }
    
    // End TableView Methods
    // Deprecated tableView() methods:
    /*
     
     Deprecated:
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return matchingItems.count
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
     let selectedItem = matchingItems[indexPath.row].placemark
     cell.textLabel?.text = selectedItem.name
     cell.detailTextLabel?.text = parseAddress(selectedItem)
     return cell
     }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     let selectedItem = matchingItems[indexPath.row].placemark
     handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
     layoverView.isHidden = true
     if let place = selectedItem.title {
     addressString = place
     if let search = searchBar {
     print("found searchbar within location search table")
     search.text = place
     } else {
     print("cannot find search bar")
     }
     if let presentingView = self.presentingViewController as? mapViewController {
     print("found presenting view")
     presentingView.resultSearchController.searchBar.text = place
     } else {
     print("cannot find presenting view as mapViewController")
     }
     UserDefaults.standard.set(place, forKey: "address")
     }
     dismiss(animated: true, completion: nil)
     
     }
     
     
     
     
     
     */
    // End Deprecated tableView() methods
    
    //
}



extension LocationSearchTable : UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate{
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        mapView?.addSubview(layoverView)
        layoverView.isHidden = false
        menuDisplay?.toggleUI(searchTableShouldBePresented: true)
       //self.edgesForExtendedLayout = UIRectEdge.all
        
        
        
        
    }
  
    func updateSearchResults(for searchController: UISearchController) {
        
        
        print("UpdateSearchResults")
        
        searchController.searchBar.delegate = self
        searchController.delegate = self
      
        //searchController.searchBar.placeholder = "Hello"
        
        
     
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }

      //  searchController.searchBar.frame = CGRect(x: 50, y: 20, width: 140, height: 36)
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response
                else {
                    return
            }
            //searchController.searchBar.frame = CGRect(x: 50, y: 20, width: 140, height: 36)
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        menuDisplay?.toggleUI(searchTableShouldBePresented: true)
        print("didPresentSearchController")
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: searchWidth, height: 42)
        var searchBar = searchController.searchBar
        searchBar.sizeToFit()
        let font = UIFont(name: "AppleColorEmoji", size: 15)
        searchController.searchBar.backgroundColor = UIColor.veryVeryLightGray
        searchBarPlaceHolder.backgroundColor = UIColor.veryVeryLightGray
     //   searchController.searchBar.setTheme(mainColor: UIColor.veryVeryLightGray, secondaryColor: UIColor.black)
    //    searchBarPlaceHolder.frame = CGRect
        
        
        // BEGIN
        
        searchBar.barTintColor = UIColor.veryLightGray
        searchBar.layer.cornerRadius = 10
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.purple.cgColor
        var searchbarTextField = searchBar.value(forKey: "searchField") as? UITextField
        
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        
        
        
        
        searchBar.tintColor = UIColor.veryLightGray
        searchBar.barTintColor = UIColor.veryLightGray
        searchBar.layer.borderColor = UIColor.veryLightGray.cgColor
        
        searchbarTextField?.textColor = UIColor.black
        searchbarTextField?.backgroundColor = UIColor.veryLightGray
        searchbarTextField?.font = font
        searchBar.setMagnifyingGlassColorTo(color: .black)

        searchBar.setTextColor(color: UIColor.black)
        searchBar.setPlaceholderTextColorTo(color: UIColor.black)
        
        for subview in searchBar.subviews {
            if subview is UIButton { //checking if it is a button
                let button = subview as! UIButton
                button.tintColor = UIColor.black
                button.setTitleColor(UIColor.black, for: .normal)
                print("this subview is a button! it's text is: \(button.titleLabel?.text)")
            }
        }
        
        //   END

        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
       searchBar.text = ""
        searchBar.resignFirstResponder()
     //   menuDisplay?.toggleUI(searchTableShouldBePresented: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        let x : String = searchBar.text!
        
        UserDefaults.standard.set(x, forKey: "address")
    }
    
    
    func presentSearchController(_ searchController: UISearchController) {}
    
        
        
    
    
}



extension CGFloat {
    
    var integer: Int {
        get {
            return Int(self)
        }
    }
    
}

extension Float {
    
    var cg: CGFloat {
        get {
            return CGFloat(self)
        }
    }
    
}

extension UIViewController {
    func after(_ seconds: Double, executeCode code: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            code()
        }
    }
}

