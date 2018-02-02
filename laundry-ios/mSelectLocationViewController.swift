//
//  mSelectLocationViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 12/9/17.
//  Copyright © 2017 Lavo Logistics. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class mSelectLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    // Variables
    
    @IBOutlet weak var savedLocationTableView: UITableView!
    
    @IBOutlet weak var recentLocationsTableView: UITableView!
    
    var locationsSaved = [(name: String, location: String)]()
    var locationsRecent = [String]()

    
    var addressString : String  = ""
    
    var currentAddressString : String = ""
    
    var startingLocation : String!
        
    var layoverView : UIView!
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    let manager = CLLocationManager()
    var searchBar : UISearchBar!
    
    var closeSearch : UIButton!
    
    var delegate : hide_Show_Button?
    var savedLocations = [(name: String, location: HomeAddress)]()
    
    var searchBarPlaceHolder : UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initializeTableViews()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        mapView?.showsUserLocation = true
        
        layoverView.backgroundColor = UIColor.lightGray
        
        // Search Bar
        let searchBarY = CGFloat(partOfScreenHeight_f(percentage: 7))
        let searchBarW = CGFloat(partOfScreenWidth_f(percentage: 70))
        searchBarPlaceHolder = UIView(frame: CGRect(x: self.view.frame.width/6, y: searchBarY ,width: searchBarW, height: 36))

    }
    
    
    func fillSources() {
        let db = UserDB()
        if let id = db.getUser()?.uid {
            db.getLocations(forUserWithId: id, finished: { (saved, recent) in
                self.locationsSaved = saved
                self.locationsRecent = recent
            })
        }
    }
    

    
    func useCurrentLocation(){
        // Hide View
        self.layoverView.isHidden = true
        
        addressString = currentAddressString
        
        UserDefaults.standard.set(addressString, forKey: "address")
        
        // Find placemark & Zoom in
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let placemark = placemarks?.first as? MKPlacemark {
                self.handleMapSearchDelegate?.dropPinZoomIn(placemark)
            }
        }
        
  //      delegate1?.currLocPressed(addy: addressString)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location = locations[0]
        ////
        //        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        ////
        ////
        //
        //        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //
        //        mapView?.setRegion(region, animated: false)
        
        self.mapView?.showsUserLocation = true
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
            if error != nil
            {
                print ("THERE WAS AN ERROR")
            }
            else
            {
                if let place = placemark?[0]
                {
                    if place.subThoroughfare != nil
                    {
                        self.currentAddressString = "\(place.subThoroughfare!) \n \(place.thoroughfare!) \n \(place.country!)"
                        
                        //UserDefaults.standard.set(self.currentAddressString, forKey: "address")
                        
                        //print("HAHAAHAHAHHAHAHHA")
                        //print(self.addressString)
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
    
    // BEGIN Table View Methods
    
    func initializeTableViews() {
        
        // Set Type
     //   savedLocationTableView.type = .savedLocations
    //    recentLocationsTableView.type = .recentLocations
        
        // Set Delegates & Data Sources
        recentLocationsTableView.delegate = self
        savedLocationTableView.delegate = self
        recentLocationsTableView.dataSource = self
        savedLocationTableView.dataSource = self
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentLocationsTableView {
            if let cell = recentCell(rowNum: indexPath.row) { return cell } else { return blankCell(type: .recentLocations) }
        } else {
            if let cell = savedCell(rowNum: indexPath.row) { return cell } else { return blankCell(type: .savedLocations) }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recentLocationsTableView { return locationsRecent.count }
        else { return locationsSaved.count }
    }
    
    // END Table View Methods
   
    
    
    @IBAction func cancelView(_ sender: Any) {
        self.dismissMe(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


// BEGIN Add tableview type functionality

enum TableViewType {
    case recentLocations, savedLocations, search;
}

protocol Type {
    var type: TableViewType { get set };
    func set(type: TableViewType);
}

//extension UITableView: Type {
//
//    var type: TableViewType {
//        get {
//       //     print("Attempting to access a tableview's type. . . \n Type: self.\(type)\n If this is nil, may need error handling?")
//            return type
//        }
//        set {
//          print("set type to: \(self.type)")
//        }
//    }
//    
//    func set(type: TableViewType) {
//        self.type = type
//    }
//}

// END Add tableview type functionality

extension mSelectLocationViewController : UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate{
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        mapView?.addSubview(layoverView)
        layoverView.isHidden = false
        
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
        //    self.tableView.reloadData()
        }
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        
        print("didPresentSearchController")
        searchController.searchBar.frame = CGRect(x: 50, y: 20, width: self.view.frame.width-50, height: 36)
        
        
        // searchController.searchBar.frame = CGRect(x: 50, y: 20, width: self.view.frame.width-50, height: 40)
        
        //searchController.searchBar.frame = CGRect(x: 0, y: 50, width: self.view.frame.width-50-self.closeSearch.frame.width, height: 36)
        //self.layoverView.addSubview(searchController.searchBar)
        //searchController.searchBar.frame = CGRect(x: 0, y: 0, width: 175, height: 36)
        
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        
        searchBar.resignFirstResponder()
        
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        let x : String = searchBar.text!
        
        UserDefaults.standard.set(x, forKey: "address")
    }
    
    
    func presentSearchController(_ searchController: UISearchController) {
        
    }
      
    
}





