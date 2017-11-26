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
protocol hide_Show_Button {
    func hide()
    func show()
}

protocol straightToGetWashing {
    func currLocPressed(addy: String!)
}


class LocationSearchTable: UITableViewController, closeSearch, CLLocationManagerDelegate   {
    
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
        
        //self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestWhenInUseAuthorization()
        
        UserDefaults.standard.set(" ", forKey: "currentLocationPressed")
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    
        mapView?.showsUserLocation = true
     
        
        //
        if let id = FIRAuth.auth()?.currentUser?.uid {
            let c = Client(id: id)
            c.dbFill {
                if let locations = c.savedLocations {
                self.savedLocations = locations
                }
            }
        }
    
        
        layoverView = UIView(frame: CGRect(x: 0, y: 45, width: self.view.frame.width, height: self.view.frame.height))
        
        layoverView = UIView(frame: CGRect(x: 0, y: 40, width: self.view.frame.width, height: 800))
        layoverView.backgroundColor = UIColor.lightGray
        
        recentItems.append("google way 06492")
        recentItems.append("google way 06492")
        recentItems.append("google way 06492")
        
        //X out button
        
    
        //search bar
        
        
        searchBarPlaceHolder = UIView(frame: CGRect(x: 50, y: 20, width: self.view.frame.width-50, height: 36))
        searchBarPlaceHolder.backgroundColor = UIColor.black
        searchBarPlaceHolder.layer.cornerRadius = 10
        
       
        
        
        //use current location button
        
        var currentLocation : UIButton!
        
        currentLocation = UIButton(type: UIButtonType.system)
        
        currentLocation.frame = CGRect(x: 0, y: 40, width: (self.mapView?.frame.width)!, height: 40)
        
        currentLocation.setTitle("Use Current Location", for: .normal)
        currentLocation.setTitleColor(UIColor.black, for: .normal)
        
        currentLocation.backgroundColor = UIColor.lightGray
        currentLocation.layer.borderWidth = 1.0
        currentLocation.layer.borderColor = UIColor.black.cgColor
        currentLocation.addTarget(self, action: #selector(useCurrentLocation), for: .touchUpInside)
        layoverView.addSubview(currentLocation)
        
        
        
        //label seperator
        var seperator : UILabel!
        seperator = UILabel(frame: CGRect(x: 0, y: currentLocation.frame.origin.y+currentLocation.frame.height, width: currentLocation.frame.width, height: 20))
        seperator.backgroundColor = UIColor.lightGray
        seperator.layer.borderWidth = 1.0
        seperator.layer.borderColor = UIColor.black.cgColor
        layoverView.addSubview(seperator)
        
        //work/home/custom locations
        var startLocationOptionsTableview : UITableView!
        startLocationOptionsTableview = UITableView(frame: CGRect(x: 0.0, y: seperator.frame.origin.y+seperator.frame.height, width: self.view.frame.width , height: 80))
        startLocationOptionsTableview.separatorInset = UIEdgeInsets(top: 2.0, left: 0, bottom: 2.0, right: 0)
        
        layoverView.addSubview(startLocationOptionsTableview)
        
        //second seperator
        var seperator1 : UILabel!
        seperator1 = UILabel(frame: CGRect(x: 0, y: startLocationOptionsTableview.frame.origin.y+startLocationOptionsTableview.frame.height, width: currentLocation.frame.width, height: 20))
        seperator1.backgroundColor = UIColor.lightGray
        seperator1.layer.borderWidth = 1.0
        seperator1.layer.borderColor = UIColor.black.cgColor
        layoverView.addSubview(seperator1)
        
        var recentLocations : UILabel!
        
        recentLocations = UILabel(frame: CGRect(x: 0, y: seperator1.frame.origin.y+seperator1.frame.height, width: self.view.frame.width, height: 40))
        
        recentLocations.layer.borderWidth = 1.0
        recentLocations.layer.borderColor = UIColor.black.cgColor
        recentLocations.text = "Recent Locations"
        recentLocations.textAlignment = NSTextAlignment.center
        recentLocations.backgroundColor = UIColor.lightGray
        
        layoverView.addSubview(recentLocations)
        //recent search history items tableview
        
        
        
        var heightTB : Int = Int(recentLocations.frame.origin.y+recentLocations.frame.height)
        
        var recentSearches : UITableView!
        recentSearches = UITableView(frame: CGRect(x: 0, y: heightTB, width: Int(self.view.frame.width), height: min(Int(self.view.frame.height)-(heightTB),Int(recentItems.count*44))))
        layoverView.addSubview(recentSearches)
        
        
        
        
        closeSearch = UIButton(type: UIButtonType.system)
        closeSearch.frame = CGRect(x: self.view.frame.width-30, y:currentLocation.frame.origin.y-30, width: 25, height: 25)
        closeSearch.setTitle("X", for: .normal)
        closeSearch.setTitleColor(UIColor.black, for: .normal)
        
        
        closeSearch.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeSearch.backgroundColor = UIColor.lavoLightGray
        

        self.layoverView.addSubview(closeSearch)
        
        print("aha")
     
        
        
    }
    
    func closeButtonPressed(){
        self.layoverView.isHidden = true
        self.resignFirstResponder()
        self.closeEverything()
    }

    func useCurrentLocation(){
        
 
        self.layoverView.isHidden = true
        addressString = currentAddressString
        print("ADDRESS!!:\(currentAddressString)")
        UserDefaults.standard.set(addressString, forKey: "address")
        
        
        delegate1?.currLocPressed(addy: addressString)
        
        
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 2
        
        
    }

    func closeSearchField(but: UIButton!) {
        
        
        
        but.isHidden = true
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
     //   if tableView == self.
        
        return matchingItems.count
        
        
    }
    
    func closeEverything(){
        
        //self.layoverView.isHidden = true
        
        
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
    //
}



extension LocationSearchTable : UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate{
    
    
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
            self.tableView.reloadData()
        }
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        
        print("didPresentSearchController")
        
        
   
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






