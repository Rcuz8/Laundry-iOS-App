//
//  HomeAddress.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 7/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import MapKit

class HomeAddress {
    
    var city: String = ""
    
    var state: String = ""
    
    var zip: String = ""
    
    var streetAddress: String = ""
    
    var apartmentNumber: String = ""
    
    var geoLoc: CLLocationCoordinate2D?
    
    
    
    init(aStreetAddress: String, aCity: String, aState: String, aZip: String, aptNumber: String?) {

            self.streetAddress = aStreetAddress; self.city = aCity; self.state = aState; self.zip = aZip;
            if let num = aptNumber {
                self.apartmentNumber = num
            } else { self.apartmentNumber = "" }
        
    }
    
    func getGeo(finished: @escaping (_ geolocationSaved: Bool) -> ()) {
            let addressString = "\(streetAddress), \(city), \(state) \(zip), USA"
            print("Address: *\(addressString)*")
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressString) { (placemarks, error) in
                if error != nil { finished(false); print("getgeo error: \(error.debugDescription)") } else {
                    print("getgeo: location found!")
                    print("Placemarks: \(placemarks)")
                    if let placemark = placemarks?[0] {
                        if let loc  = placemark.location {
                        self.geoLoc = loc.coordinate
                        finished(true)
                        } else { print("Cannot get placemark location"); finished(false); }
                    } else { print("Cannot get placemark within placemarks"); finished(false); }
                }
            }

    }
    
    func infoValid() -> Bool {
        if city != "", state != "", zip != "", streetAddress != "", geoLoc != nil {
           return true
        } else { return false }
    }
    
    func json() -> JSON? {
        if let c = good(s: city), let s = good(s: state), let z = good(s: zip), let str = good(s: streetAddress), let loc = geoLoc {
            let data: JSON = [
                "city": c,
                "state": s,
                "zipCode": z,
                "streetAddress": str,
                "apartmentNumber": apartmentNumber,
                "longitude": loc.longitude,
                "latitude": loc.latitude,
            ]
            
            return data
        } else { return nil }
        
    }
    
    func printablejson() -> JSON? {
            let data: JSON = [
                "city": self.city,
                "state": self.state,
                "zipCode": self.zip,
                "streetAddress": self.streetAddress,
                "apartmentNumber": self.apartmentNumber,
                "longitude": self.geoLoc?.longitude,
                "latitude": self.geoLoc?.latitude,
                ]
            
            return data
        
    }
    
    func simpleDescription() -> String {
        return "Address Description: { \n Street: \(streetAddress) \n City: \(city) \n State: \(state) \n Zip Code: \(zip) \n apartment: \(apartmentNumber) \n Location Details: \n   latitude: \(geoLoc?.latitude) \n   longitude: \(geoLoc?.longitude) \n } "
    }
    
    func userFriendlyDescription() -> String {
        if apartmentNumber != "" {
        return "\(streetAddress) \(city), \(state) \(zip) #\(apartmentNumber)\n "
        } else {
          return "\(streetAddress) \(city), \(state) \(zip)"
        }
    }
    
    func good(s: String) -> String? { if s != "" { return s } else { return nil } }
    
}
