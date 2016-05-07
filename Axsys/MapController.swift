//
//  MapController.swift
//  SkyeLync
//
//  Created by Dillon Murphy on 4/6/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData
import DTMHeatmap


class DXAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(location coord:CLLocationCoordinate2D) {
        self.coordinate = coord
        super.init()
    }
}

var locations: [Location] = []

@objc class MapController: UIViewController, UISearchControllerDelegate, MultiSelectSegmentedControlDelegate{
    
    var buckheadPoly:MKPolygon?
    var downtownPoly:MKPolygon?
    var highlandsPoly:MKPolygon?
    var midtownPoly:MKPolygon?
    var emoryPoly:MKPolygon?
    var eastPoly:MKPolygon?
    
    @IBOutlet weak var placesSeg: MultiSelectSegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var MapSwitch: AMViralSwitch!
    
    @IBOutlet weak var HeatMapLabel: UILabel!
    
    var regionRadius: CLLocationDistance = 1000
    
    var annotation: CustomPointAnnotation!
    
    var calloutView: CustomCallout?
    
    var locationButton: UIButton?
    
    //var request: LocationRequest!
    
    var heatmap: DTMHeatmap?
    var diffHeatmap: DTMDiffHeatmap?
    
    override func viewWillLayoutSubviews() {
        mapView.layer.cornerRadius = 8.0
        MapSwitch.layer.cornerRadius = MapSwitch.frame.height / 2
    }
    
    override func viewWillAppear(animated: Bool) {
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(MapController.backToLogin(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
        mapSetup()
        /*
        request = LocationManager.shared.observeLocations(.Navigation, frequency: .Significant, onSuccess: {
            location in
        
        }) {
            error in
        
        }*/
        // Sometimes in the future
        //request.stop() // Stop receiving updates
        
        placesSeg.delegate = self
    }
    
    
    func backToLogin(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setupHeatmaps() {
        //self.performSegueWithIdentifier("toHeatMap", sender: nil)
        self.heatmap = DTMHeatmap()
        self.heatmap!.setData(ViewController().parseLatLonFile("mcdonalds"))
        self.mapView.addOverlay(self.heatmap!)
    }
    
    
    
    func multiSelect(multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, atIndex index: UInt) {
        switch(multiSelecSegmendedControl.state) {
            case UIControlState.Selected:
                switch(index) {
                case 0: self.mapView.removeOverlay(buckheadPoly!)
                case 1: self.mapView.removeOverlay(midtownPoly!)
                case 2: self.mapView.removeOverlay(highlandsPoly!)
                case 3: self.mapView.removeOverlay(emoryPoly!)
                case 4: self.mapView.removeOverlay(downtownPoly!)
                case 5: self.mapView.removeOverlay(eastPoly!)
                default: break
            }
            
            default:
                switch(index) {
                case 0: self.addBuckheadBoundary()
                case 1: self.addMidtownBoundary()
                case 2: self.addHighlandsBoundary()
                case 3: self.addEmoryBoundary()
                case 4: self.addDowntownBoundary()
                case 5: self.addEastBoundary()
                default: break
            }
        }
    }
    
    func getCurrentLocation() {
        LocationManager.shared.observeLocations(.Block, frequency: .OneShot, onSuccess: { location in
            let myLoc = location.coordinate
            let myLocation = CLLocation(latitude: myLoc.latitude, longitude: myLoc.longitude)
            self.centerMapOnLocation(myLocation)
        }) {error in}
    }
    
    func mapSetup() {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false)
        getCurrentLocation()
        
        MapSwitch.animationDuration = 0.1
        MapSwitch.animationElementsOn = [[AMElementView: self.view.layer,
            AMElementKeyPath: "backgroundColor",
            AMElementFromValue: self.view.backgroundColor!.CGColor,
            AMElementToValue: MapSwitch.backgroundColor!.CGColor]]
        
        MapSwitch.completionOn = {
            self.HeatMapLabel.text = "Heat Maps On"
            self.setupHeatmaps()
        }
        
        MapSwitch.animationElementsOff = [[AMElementView: self.view.layer,
            AMElementKeyPath: "backgroundColor",
            AMElementFromValue: MapSwitch.backgroundColor!.CGColor,
            AMElementToValue: self.view.backgroundColor!.CGColor]]
        
        MapSwitch.completionOff = {
            self.HeatMapLabel.text = "Heat Maps Off"
            self.mapView.removeOverlay(self.heatmap!)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapController {
    func addBuckheadBoundary() {
        if buckheadPoly != nil {
            self.mapView.removeOverlay(buckheadPoly!)
            buckheadPoly = nil
            let coor = CLLocationCoordinate2D(latitude: 33.843846,longitude: -84.39517)
            let coordinateRegion = MKCoordinateRegionMake(coor, MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))
            //MKCoordinateRegionMakeWithDistance(coor,dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
        } else {
            let coor = CLLocationCoordinate2D(latitude: 33.843846,longitude: -84.39517)
            let coordinateRegion = MKCoordinateRegionMake(coor, MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))
                //MKCoordinateRegionMakeWithDistance(coor,dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
            buckheadPoly  = MKPolygon(coordinates: &buckheadCoords, count: buckheadCoords.count)
            self.mapView.addOverlay(buckheadPoly!)
        }
    }
    
    func addMidtownBoundary() {
        if midtownPoly != nil {
            self.mapView.removeOverlay(midtownPoly!)
            let coor = CLLocationCoordinate2D(latitude: 33.783302,longitude: -84.38284)
            let coordinateRegion = MKCoordinateRegionMake(coor, MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
            //MKCoordinateRegionMakeWithDistance(coor,dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
            midtownPoly = nil
        } else {
            let coor = CLLocationCoordinate2D(latitude: 33.783302,longitude: -84.38284)
            let coordinateRegion = MKCoordinateRegionMake(coor, MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.12))
            //MKCoordinateRegionMakeWithDistance(coor,dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
            midtownPoly  = MKPolygon(coordinates: &midtownCoords, count: midtownCoords.count)
            self.mapView.addOverlay(midtownPoly!)
        }
    }
    
    func addDowntownBoundary() {
        if downtownPoly != nil {
            self.mapView.removeOverlay(downtownPoly!)
            let dist: CLLocationDistance = 5000
            let coor = CLLocationCoordinate2D(latitude: 33.760202, longitude: -84.383583)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
            downtownPoly = nil
        } else {
            let dist: CLLocationDistance = 5000
            let coor = CLLocationCoordinate2D(latitude: 33.760202, longitude: -84.383583)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
            downtownPoly  = MKPolygon(coordinates: &downtownCoords, count: downtownCoords.count)
            self.mapView.addOverlay(downtownPoly!)
        }
    }
    
    func addEastBoundary() {
        if eastPoly != nil {
            self.mapView.removeOverlay(eastPoly!)
            let dist: CLLocationDistance = 5000
            eastPoly = nil
            let coor = CLLocationCoordinate2D(latitude: 33.733376,longitude: -84.336275)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, dist * 2.0, dist * 2.0)
            self.mapView.setRegion(coordinateRegion, animated: false)
        } else {
            let dist: CLLocationDistance = 5000
            eastPoly  = MKPolygon(coordinates: &eastCoords, count: eastCoords.count)
            self.mapView.addOverlay(eastPoly!)
            let coor = CLLocationCoordinate2D(latitude: 33.733376,longitude: -84.336275)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, dist * 2.0, dist * 2.0)
            self.mapView.setRegion(coordinateRegion, animated: false)
        }
    }
    
    func addEmoryBoundary() {
        if emoryPoly != nil {
            self.mapView.removeOverlay(emoryPoly!)
            let dist: CLLocationDistance = 5000
            emoryPoly  = nil
              let coor = CLLocationCoordinate2D(latitude: 33.800153,longitude: -84.319038)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, dist * 2.0, dist * 2.0)
            self.mapView.setRegion(coordinateRegion, animated: false)
        } else {
            let dist: CLLocationDistance = 5000
            emoryPoly  = MKPolygon(coordinates: &emoryCoords, count: emoryCoords.count)
            self.mapView.addOverlay(emoryPoly!)
            let coor = CLLocationCoordinate2D(latitude: 33.800153,longitude: -84.319038)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, dist * 2.0, dist * 2.0)
            self.mapView.setRegion(coordinateRegion, animated: false)
        }
    }
    
    func addHighlandsBoundary() {
        if highlandsPoly != nil {
            self.mapView.removeOverlay(highlandsPoly!)
            highlandsPoly = nil
            let coor = CLLocationCoordinate2D(latitude: 33.784586,longitude: -84.359035)
            let coordinateRegion = MKCoordinateRegionMake(coor, MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))
            //MKCoordinateRegionMakeWithDistance(coor,dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
        } else {
            let coor = CLLocationCoordinate2D(latitude: 33.784586,longitude: -84.359035)
            let coordinateRegion = MKCoordinateRegionMake(coor, MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))
            //MKCoordinateRegionMakeWithDistance(coor,dist, dist)
            self.mapView.setRegion(coordinateRegion, animated: false)
            highlandsPoly  = MKPolygon(coordinates: &highlandCoords, count: highlandCoords.count)
            self.mapView.addOverlay(highlandsPoly!)
        }
    }
}


// MARK: MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polyview = MKPolygonRenderer(polygon: (overlay as? MKPolygon)!)
            polyview.lineWidth = 1.0
            let overlay = overlay as! MKPolygon
            if overlay == emoryPoly {
                polyview.strokeColor = UIColor.redColor()
                polyview.fillColor = UIColor(red: 100.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.2)
            } else if overlay == downtownPoly {
                polyview.strokeColor = UIColor.babyBlueColor()
                polyview.fillColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 0.2)
            } else if overlay == buckheadPoly {
                polyview.strokeColor = UIColor.goldColor()
                polyview.fillColor = UIColor(red: 255.0/255.0, green: 210.0/255.0, blue: 0.0/255.0, alpha: 0.2)
            } else if overlay == midtownPoly {
                polyview.strokeColor = UIColor.purpleColor()
                polyview.fillColor = UIColor(red: 100.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 0.2)
            } else if overlay == eastPoly {
                polyview.strokeColor = UIColor.emeraldColor()
                polyview.fillColor = UIColor(red: 1.0/255.0, green: 152.0/255.0, blue: 117.0/255.0, alpha: 0.2)
            } else if overlay == highlandsPoly {
                polyview.strokeColor = UIColor.crimsonColor()
                polyview.fillColor = UIColor(red: 200.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.2)
            }
            return polyview
        }
        return DTMHeatmapRenderer(overlay: overlay)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
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
        //calloutView!.SendPush.addTarget(self, action: #selector(LocationPickerViewController.sendPushView(_:)), forControlEvents: .TouchUpInside)
        let v = DXAnnotationView(annotation: annotation, reuseIdentifier: "annotation", pinView: pinView, calloutView: calloutView, settings: DXAnnotationSettings.defaultSettings())
        return v
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let navigation = navigationController where navigation.viewControllers.count > 1 {
            navigation.popViewControllerAnimated(true)
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        let pins = mapView.annotations.filter { $0 is MKPinAnnotationView }
        assert(pins.count <= 1, "Only 1 pin annotation should be on map at a time")
    }
}

