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

class SelectLocationViewController2: UIViewController, closeSearch, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource   {
    
    @IBOutlet weak var savedLocationTableView: UITableView!
    
    @IBOutlet weak var recentLocationsTableView: UITableView!
    
    var locationsSaved = [(name: String, location: String)]()
    var locationsRecent = [String]()
    
    var addressString : String  = ""
    
    var currentAddressString : String = ""
    
    var startingLocation : String!
    var tableV : UITableView!
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UserDefaults.standard.set(" ", forKey: "currentLocationPressed")
        
        layoverView = UIView(frame: CGRect(x: 0, y: 45, width: self.view.frame.width, height: self.view.frame.height))
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView?.showsUserLocation = true
        
        //search bar
        
        // Search Bar
        let searchBarY = CGFloat(partOfScreenHeight_f(percentage: 7))
        let searchBarW = CGFloat(partOfScreenWidth_f(percentage: 70))
        searchBarPlaceHolder = UIView(frame: CGRect(x: 0, y: searchBarY ,width: searchBarW, height: 36))
        
        
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
    
    func closeButtonPressed(){
 //       self.layoverView.isHidden = true
        self.dismissMe(animated: true, completion: nil)
        self.resignFirstResponder()
        self.closeEverything()
    }
    
    func useCurrentLocation(){
        // Hide View
        //self.layoverView.isHidden = true
        
        addressString = currentAddressString
        
        UserDefaults.standard.set(addressString, forKey: "address")
        
        // Find placemark & Zoom in
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let placemark = placemarks?.first as? MKPlacemark {
                self.handleMapSearchDelegate?.dropPinZoomIn(placemark)
            }
        }
        
        delegate1?.currLocPressed(addy: addressString)
        self.dismissMe(animated: true, completion: nil)
        
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
    
    func closeSearchField(but: UIButton!) {
        
        
        
        but.isHidden = true
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 2
        
        
    }
    
    
    func closeEverything(){
        
        //self.layoverView.isHidden = true
        
        
    }
    
    func initializeTableViews() {
        
        // Set Type
      //  savedLocationTableView.type = .savedLocations
      //  recentLocationsTableView.type = .recentLocations
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //    let type = tableView.type
        if tableView == recentLocationsTableView { return locationsRecent.count }
        else if tableView == savedLocationTableView { return locationsSaved.count }
        else { return matchingItems.count }
        
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
      //  layoverView.isHidden = true
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
    //
}


extension SelectLocationViewController2 : UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate{
    
    
    override func viewDidAppear(_ animated: Bool) {
        
      //  mapView?.addSubview(layoverView)
   //     layoverView.isHidden = false
        
        //self.edgesForExtendedLayout = UIRectEdge.all
        
        
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Update Search Results
        searchController.searchBar.delegate = self
        searchController.delegate = self
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response
                else {
                    return
            }
            self.matchingItems = response.mapItems
        }
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {}
    
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






