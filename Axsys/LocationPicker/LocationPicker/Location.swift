//
//  Location.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import Foundation

import CoreLocation
import AddressBookUI
import MapKit

extension Location: MKAnnotation {
    @objc public var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    public var title: String? {
        return name ?? address
    }
}

// class because protocol
public class Location: NSObject {
    
    
    
	public var name: String?
	
	// difference from placemark location is that if location was reverse geocoded,
	// then location point to user selected location
	public var location: CLLocation
	public var placemark: CLPlacemark
    
    
	
	public var address: String {
        guard let str1: String = placemark.subThoroughfare! else {
            return ""
        }
        guard let str2: String = placemark.thoroughfare! else {
            return ""
        }
        guard let str3: String = placemark.locality! else {
            return ""
        }
        guard let str4: String = placemark.administrativeArea! else {
            return ""
        }
        guard let str5: String = placemark.postalCode! else {
            return ""
        }
		// try to build full address first
        let address = "\(str1) \(str2) \(str3), \(str4) \(str5)"
		return address
	}
    
    public init(name: String?, location: CLLocation? = nil, placemark: CLPlacemark) {
        self.name = name
        self.location = location ?? placemark.location!
        self.placemark = placemark
    }
    
}

/*
 public var iglocation: IGLocation?
 
 public init(iglocation: IGLocation) {
 self.iglocation = iglocation
 
 }
 
 public func setPlace() {
 let coordinates = CLLocationCoordinate2D(latitude: iglocation!.latitude, longitude: iglocation!.latitude)
 SwiftLocation.shared.reverseCoordinates(Service.Apple, coordinates: coordinates, onSuccess: { (place) -> Void in
 // our placemark is here
 let newplaceMark: CLPlacemark = place!
 self.name = newplaceMark.name!
 self.location = newplaceMark.location!
 self.placemark = place!
 }) { (error) -> Void in
 // something went wrong
 }
 }
 */

