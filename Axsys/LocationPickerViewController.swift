//
//  LocationPickerViewController.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

public class LocationPickerViewController: UIViewController, UITextViewDelegate {
	struct CurrentLocationListener {
		let once: Bool
		let action: (CLLocation) -> ()
	}
	
    var MessageSendView: UIView!
	public var completion: (Location2? -> ())?
	
	// region distance to be used for creation region when user selects place from search results
	public var resultRegionDistance: CLLocationDistance = 600
	
	/// default: true
	public var showCurrentLocationButton = true
	
	/// default: true
	public var showCurrentLocationInitially = true
	
	/// see `region` property of `MKLocalSearchRequest`
	/// default: false
	public var useCurrentLocationAsHint = false
	
	/// default: "Search or enter an address"
	public var searchBarPlaceholder = "Search or enter an address"
	
	/// default: "Search History"
	public var searchHistoryLabel = "Search History"
    
    
	lazy public var currentLocationButtonBackground: UIColor = {
		if let navigationBar = self.navigationController?.navigationBar,
			barTintColor = navigationBar.barTintColor {
				return barTintColor
		} else { return .whiteColor() }
	}()
    
    /// default: .Minimal
    public var searchBarStyle: UISearchBarStyle = .Minimal

	/// default: .Default
	public var statusBarStyle: UIStatusBarStyle = .Default
	
	public var mapType: MKMapType = .Hybrid {
		didSet {
			if isViewLoaded() {
				mapView.mapType = mapType
			}
		}
	}
	
	public var location: Location2? {
		didSet {
			if isViewLoaded() {
				searchBar.text = location.flatMap({ $0.title }) ?? ""
				updateAnnotation()
			}
		}
	}
	
	static let SearchTermKey = "SearchTermKey"
	
	let historyManager = SearchHistoryManager2()
	let locationManager = CLLocationManager()
	let geocoder = CLGeocoder()
	var localSearch: MKLocalSearch?
	var searchTimer: NSTimer?
	
	var currentLocationListeners: [CurrentLocationListener] = []
    var calloutView: CustomCallout? = nil
    var myTextView: UITextView!
	var mapView: MKMapView!
	var locationButton: UIButton?
	
	lazy var results: LocationSearchResultsViewController = {
		let results = LocationSearchResultsViewController()
		results.onSelectLocation = { [weak self] in self?.selectedLocation($0) }
		results.searchHistoryLabel = self.searchHistoryLabel
		return results
	}()
	
	lazy var searchController: UISearchController = {
		let search = UISearchController(searchResultsController: self.results)
		search.searchResultsUpdater = self
		search.hidesNavigationBarDuringPresentation = false
		return search
	}()
	
	lazy var searchBar: UISearchBar = {
		let searchBar = self.searchController.searchBar
		searchBar.searchBarStyle = self.searchBarStyle
		searchBar.placeholder = self.searchBarPlaceholder
        searchBar.tintColor = .whiteColor()
		return searchBar
	}()
	
	deinit {
		searchTimer?.invalidate()
		localSearch?.cancel()
		geocoder.cancelGeocode()
        // http://stackoverflow.com/questions/32675001/uisearchcontroller-warning-attempting-to-load-the-view-of-a-view-controller/
        let _ = searchController.view
	}
	
	public override func loadView() {
		mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
		mapView.mapType = mapType
        view = mapView
		
		if showCurrentLocationButton {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
			button.backgroundColor = currentLocationButtonBackground
			button.layer.masksToBounds = true
			button.layer.cornerRadius = 16
			let bundle = NSBundle(forClass: LocationPickerViewController.self)
			button.setImage(UIImage(named: "geolocation", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
			button.addTarget(self, action: #selector(LocationPickerViewController.currentLocationPressed),
			                 forControlEvents: .TouchUpInside)
			view.addSubview(button)
			locationButton = button
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		mapView.delegate = self
		searchBar.delegate = self
		
		// gesture recognizer for adding by tap
		mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: #selector(LocationPickerViewController.addLocation(_:))))
		
		// search
		navigationItem.titleView = searchBar
		definesPresentationContext = true
		
		// user location
		mapView.userTrackingMode = .None
		mapView.showsUserLocation = showCurrentLocationInitially || showCurrentLocationButton
		
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        
		if useCurrentLocationAsHint {
			getCurrentLocation()
		}
	}
    
    public func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Enter Message for Group" {
            textView.text = ""
        }
    }
    func keyboardWillHide(sender: NSNotification) {
        if searchBar.isFirstResponder() { } else {
            //self.MessageSendView.frame = CGRect(x: 5, y: self.view.frame.midY - 150, width: self.view.frame.width - 10, height: 300)
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if searchBar.isFirstResponder() { } else {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            //self.MessageSendView.frame = CGRect(x: 5, y: self.view.frame.midY - 220, width: self.view.frame.width - 10, height: 300)
        })
        }
    }
    
    override public func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }

	public override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return statusBarStyle
	}
	
	var presentedInitialLocation = false
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if let button = locationButton {
			button.frame.origin = CGPoint(
				x: view.frame.width - button.frame.width - 16,
				y: view.frame.height - button.frame.height - 20
			)
		}
		
		// setting initial location here since viewWillAppear is too early, and viewDidAppear is too late
		if !presentedInitialLocation {
			setInitialLocation()
			presentedInitialLocation = true
		}
	}
	
	func setInitialLocation() {
		if let location = location {
			// present initial location if any
			self.location = location
			showCoordinates(location.coordinate, animated: false)
		} else if showCurrentLocationInitially {
			showCurrentLocation(false)
		}
	}
	
	func getCurrentLocation() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	func currentLocationPressed() {
		showCurrentLocation()
	}
	
	func showCurrentLocation(animated: Bool = true) {
		let listener = CurrentLocationListener(once: true) { [weak self] location in
			self?.showCoordinates(location.coordinate, animated: animated)
		}
		currentLocationListeners.append(listener)
		getCurrentLocation()
	}
	
	func updateAnnotation() {
		mapView.removeAnnotations(mapView.annotations)
		if let location = location {
			mapView.addAnnotation(location)
			mapView.selectAnnotation(location, animated: true)
		}
	}
	
	func showCoordinates(coordinate: CLLocationCoordinate2D, animated: Bool = true) {
		let region = MKCoordinateRegionMakeWithDistance(coordinate, resultRegionDistance, resultRegionDistance)
		mapView.setRegion(region, animated: animated)
	}
}

extension LocationPickerViewController: CLLocationManagerDelegate {
	public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else { return }
		for listener in currentLocationListeners {
			listener.action(location)
		}
		currentLocationListeners = currentLocationListeners.filter { !$0.once }
		manager.stopUpdatingLocation()
	}
}

// MARK: Searching

extension LocationPickerViewController: UISearchResultsUpdating {
	public func updateSearchResultsForSearchController(searchController: UISearchController) {
		guard let term = searchController.searchBar.text else { return }
		
		searchTimer?.invalidate()
		
		let whitespaces = NSCharacterSet.whitespaceCharacterSet()
		let searchTerm = term.stringByTrimmingCharactersInSet(whitespaces)
		
		if searchTerm.isEmpty {
			results.locations = historyManager.history()
			results.isShowingHistory = true
			results.tableView.reloadData()
		} else {
			// clear old results
			showItemsForSearchResult(nil)
			
			searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.2,
				target: self, selector: #selector(LocationPickerViewController.searchFromTimer(_:)),
				userInfo: [LocationPickerViewController.SearchTermKey: searchTerm],
				repeats: false)
		}
	}
	
	func searchFromTimer(timer: NSTimer) {
		guard let userInfo = timer.userInfo as? [String: AnyObject],
			term = userInfo[LocationPickerViewController.SearchTermKey] as? String
			else { return }
		
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = term
		
		if let location = locationManager.location where useCurrentLocationAsHint {
			request.region = MKCoordinateRegion(center: location.coordinate,
				span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
		}
		
		localSearch?.cancel()
		localSearch = MKLocalSearch(request: request)
		localSearch!.startWithCompletionHandler { response, error in
			self.showItemsForSearchResult(response)
		}
	}
	
	func showItemsForSearchResult(searchResult: MKLocalSearchResponse?) {
		results.locations = searchResult?.mapItems.map { Location2(name: $0.name, placemark: $0.placemark) } ?? []
		results.isShowingHistory = false
		results.tableView.reloadData()
	}
	
	func selectedLocation(location: Location2) {
		// dismiss search results
		dismissViewControllerAnimated(true) {
			// set location, this also adds annotation
			self.location = location
			self.showCoordinates(location.coordinate)
			
			self.historyManager.addToHistory(location)
		}
	}
}

// MARK: Selecting location with gesture

extension LocationPickerViewController {
	func addLocation(gestureRecognizer: UIGestureRecognizer) {
		if gestureRecognizer.state == .Began {
			let point = gestureRecognizer.locationInView(mapView)
			let coordinates = mapView.convertPoint(point, toCoordinateFromView: mapView)
			let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
			
			// clean location, cleans out old annotation too
			self.location = nil
			
			// add point annotation to map
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinates
			mapView.addAnnotation(annotation)
			
			geocoder.cancelGeocode()
			geocoder.reverseGeocodeLocation(location) { response, error in
				if let error = error {
					// show error and remove annotation
					let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in }))
					self.presentViewController(alert, animated: true) {
						self.mapView.removeAnnotation(annotation)
					}
				} else if let placemark = response?.first {
					// get POI name from placemark if any
					let name = placemark.areasOfInterest?.first
					
					// pass user selected location too
					self.location = Location2(name: name, location: location, placemark: placemark)
				}
			}
		}
	}
}

// MARK: MKMapViewDelegate


extension LocationPickerViewController: MKMapViewDelegate {
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let imageResized: UIImage = Images.resizeImage(UIImage(named:"ButterflyFinalIconPin")!, width: 40, height: 40)!
        let pinView: UIImageView = UIImageView(image: imageResized)
        calloutView = NSBundle.mainBundle().loadNibNamed("myView", owner: self, options: nil).first as? CustomCallout
        if annotation.title! == nil {
            calloutView!.CalloutLocation.text = annotation.subtitle!
        } else {
            calloutView!.CalloutLocation.text = annotation.title!
                //"\(annotation.title!), \(annotation.subtitle!)"
        }
        calloutView!.SendPush.addTarget(self, action: #selector(LocationPickerViewController.sendPushView(_:)), forControlEvents: .TouchUpInside)
        let v = DXAnnotationView(annotation: annotation, reuseIdentifier: "annotation", pinView: pinView, calloutView: calloutView, settings: DXAnnotationSettings.defaultSettings())
        return v
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func sendPushView(sender: UIButton) {
        MessageSendView = UIView(frame: CGRect(x: 5, y: self.view.frame.midY - 150, width: self.view.frame.width - 10, height: 300))
        MessageSendView.backgroundColor = calloutView?.backgroundColor
        MessageSendView.layer.cornerRadius = 8.0
        
        myTextView = UITextView(frame: CGRect(x: 5, y: 22, width: MessageSendView.frame.width - 10, height: 208))
        myTextView.delegate = self
        myTextView.text = "Enter Message for Group"
        myTextView.textColor = UIColor.blackColor()
        myTextView.font = UIFont(name: "Verdana", size: 17)
        myTextView.editable = true
        myTextView.selectable = true
        myTextView.dataDetectorTypes = UIDataDetectorTypes.Link
        myTextView.layer.cornerRadius = 8.0
        myTextView.autocorrectionType = UITextAutocorrectionType.Yes
        myTextView.spellCheckingType = UITextSpellCheckingType.Yes
        myTextView.autocapitalizationType = UITextAutocapitalizationType.Sentences
        let myGesture = UITapGestureRecognizer(target: self, action: #selector(LocationPickerViewController.dismissKeyboard))
        self.view.addGestureRecognizer(myGesture)
        self.view.addSubview(MessageSendView)
        MessageSendView.addSubview(myTextView)
        
        let button = UIButton(frame: CGRect(x: (MessageSendView.frame.width / 2) + 2, y: 241, width: ((MessageSendView.frame.width - 10) / 2) - 4, height: 49))
        button.setTitle("Save", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = calloutView?.backgroundColor!.darkenedColor(0.1)
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(LocationPickerViewController.saveSelected(_:)), forControlEvents: .TouchUpInside)
        MessageSendView.addSubview(button)
        
        let button2 = UIButton(frame: CGRect(x: 5, y: 241, width: ((MessageSendView.frame.width - 10) / 2) - 4, height: 49))
        button2.setTitle("Cancel", forState: .Normal)
        button2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button2.backgroundColor = calloutView?.backgroundColor?.darkenedColor(0.1)
        button2.layer.cornerRadius = 8.0
        button2.addTarget(self, action: #selector(LocationPickerViewController.cancelSelected(_:)), forControlEvents: .TouchUpInside)
        MessageSendView.addSubview(button2)
    }
    
    func cancelSelected(sender: UIButton) {
        MessageSendView.removeFromSuperview()
    }
    
    func saveSelected(sender: UIButton) {
        MessageSendView.removeFromSuperview()
    }
    
    public func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        completion?(location)
        if let navigation = navigationController where navigation.viewControllers.count > 1 {
            navigation.popViewControllerAnimated(true)
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    public func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        let pins = mapView.annotations.filter { $0 is MKPinAnnotationView }
        assert(pins.count <= 1, "Only 1 pin annotation should be on map at a time")
    }
}

// MARK: UISearchBarDelegate

extension LocationPickerViewController: UISearchBarDelegate {
	public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
		// dirty hack to show history when there is no text in search bar
		// to be replaced later (hopefully)
		if let text = searchBar.text where text.isEmpty {
			searchBar.text = " "
		}
	}
	
	public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		// remove location if user presses clear or removes text
		if searchText.isEmpty {
			location = nil
			searchBar.text = " "
		}
	}
}