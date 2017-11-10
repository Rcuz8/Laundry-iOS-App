//
//  ViewController.swift
//  Laundry
//
//  Created by Oliver Collins on 5/17/17.
//  Copyright © 2017 OliverCollins. All rights reserved.
//
//IMPORTANT: CHANGE VALUE THE USER IS BEING CHARGED.

import Alamofire
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //@IBOutlet weak var mapView: GMSMapView!
 // 
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var selectedPlace: GMSPlace?
    
    //Default location when location permission is not granted
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        mapView.clear()
        
        if selectedPlace != nil {
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        GMSServices.provideAPIKey("AIzaSyCILudzORPc7aJpHClNMY3wgxHG3-lrhuI")
        GMSPlacesClient.provideAPIKey("AIzaSyCILudzORPc7aJpHClNMY3wgxHG3-lrhuI")
        
        /*
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
         */
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        
        self.locationManager.delegate = self
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        //let deviceLatitude = self.locationManager.location.cordinate.latitude
        
        
        placesClient = GMSPlacesClient.shared()
        
        //Create a new map
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        
        /*
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        view.addSubview(mapView)
        mapView.isHidden = true
         */
        
        
        
        //let camera = GMSCameraPosition.camera(withLatitude: -34.357217, longitude: 18.487373, zoom: 10)
        
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        let mapView = GMSMapView.map(withFrame: rect, camera: camera)
        
        view = mapView
        
        let currentLocation = CLLocationCoordinate2DMake(-34.357217, 18.487373)
        

        // Marker Stuff
        
        let marker = GMSMarker(position: currentLocation)
        marker.title = "This is a marker!"
        marker.map = mapView
        
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
                    print("Current Place address \(place.formattedAddress)")
                    print("Current Place attributions \(String(describing: place.attributions))")
                    print("Current PlaceID \(place.placeID)")
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17)
        mapView?.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
}
