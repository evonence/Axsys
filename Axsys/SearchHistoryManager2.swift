//
//  SearchHistoryManager.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 9/6/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import MapKit

struct SearchHistoryManager2 {
	private let HistoryKey = "RecentLocationsKey"
	
	private var defaults: NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}
	
	func history() -> [Location2] {
		let history = defaults.objectForKey(HistoryKey) as? [NSDictionary] ?? []
		return history.flatMap(Location2.fromDefaultsDic)
	}
	
	func addToHistory(location: Location2) {
		guard let dic = location.toDefaultsDic() else { return }
		
		var history  = defaults.objectForKey(HistoryKey) as? [NSDictionary] ?? []
		let historyNames = history.flatMap { $0[LocationDicKeys.name] as? String }
        let alreadyInHistory = location.name.flatMap(historyNames.contains) ?? false
		if !alreadyInHistory {
			history.insert(dic, atIndex: 0)
			defaults.setObject(history, forKey: HistoryKey)
		}
	}
}



extension Location2 {
	func toDefaultsDic() -> NSDictionary? {
		guard let addressDic = placemark.addressDictionary,
			placemarkCoordinatesDic = placemark.location?.coordinate.toDefaultsDic()
			else { return nil }
		
		var dic: [String: AnyObject] = [
			LocationDicKeys.locationCoordinates: location.coordinate.toDefaultsDic(),
			LocationDicKeys.placemarkAddressDic: addressDic,
			LocationDicKeys.placemarkCoordinates: placemarkCoordinatesDic
		]
		if let name = name { dic[LocationDicKeys.name] = name }
		return dic
	}
	
	class func fromDefaultsDic(dic: NSDictionary) -> Location2? {
		guard let placemarkCoordinatesDic = dic[LocationDicKeys.placemarkCoordinates] as? NSDictionary,
			placemarkCoordinates = CLLocationCoordinate2D.fromDefaultsDic(placemarkCoordinatesDic),
			placemarkAddressDic = dic[LocationDicKeys.placemarkAddressDic] as? [String: AnyObject]
			else { return nil }
		
		let coordinatesDic = dic[LocationDicKeys.locationCoordinates] as? NSDictionary
		let coordinate = coordinatesDic.flatMap(CLLocationCoordinate2D.fromDefaultsDic)
		let location = coordinate.flatMap { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
		
		return Location2(name: dic[LocationDicKeys.name] as? String,
			location: location,
			placemark: MKPlacemark(coordinate: placemarkCoordinates, addressDictionary: placemarkAddressDic))
	}
}