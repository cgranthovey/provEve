//
//  MapVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/27/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

protocol HandleMapSearch{
    func dropPinZoomIn(placemark: MKPlacemark, addressString: String)
}


class MapVC: UIViewController {

    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil //will use to cache any incoming placemarks.
    var addressString = ""
    
    var addressPassed: String!
    var mkPlacemarkPassed: MKPlacemark!
    var shouldMapCenter = false
    var hasUserLocBeenFound = false
    
    var searchBar = UISearchBar()
    
    var currentLoc = CLLocation()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var handleGetEventLocDelegate: HandleGetEventLoc? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        self.navigationController?.navigationBarHidden = false
        navigationItem.hidesBackButton = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true   //by default modal overlay will take up entire screen, covering search bar, this limits the over to just the view controller's frame instead of also the nav controller
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        
        searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places to set pin"
        
        navigationItem.titleView = resultSearchController?.searchBar

        ////////////////////////////////////////////////////////////////////////
        //if info is passed to vc
        if addressPassed != nil && mkPlacemarkPassed != nil{
            print("tiger")
            print("addressPassed \(addressPassed) placemark \(mkPlacemarkPassed.countryCode)")
            dropPinZoomIn(mkPlacemarkPassed, addressString: addressPassed)
            searchBar.text = addressPassed
            shouldMapCenter = true
        }
        
        
    }
    
    @IBAction func removePinBtn(sender: AnyObject){
        mapView.removeAnnotations(mapView.annotations)
        searchBar.text = ""
    }
    
    @IBAction func cancelBtn(sender: AnyObject){
        handleGetEventLocDelegate?.getEventLoc(nil, name: nil, longitude: nil, latitude: nil, placemark: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func setPin(sender: AnyObject){
        if selectedPin != nil{
            handleGetEventLocDelegate?.getEventLoc(addressString, name: selectedPin?.name, longitude: selectedPin?.coordinate.longitude, latitude: selectedPin?.coordinate.latitude, placemark: selectedPin)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func userLocBtn(sender: AnyObject){
        if hasUserLocBeenFound{
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: currentLoc.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }


    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true

    }

}

extension MapVC : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "alarmClear"), forState: .Normal)
        button.addTarget(self, action: #selector(MapVC.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}

///////////////////////////////////////////////////////////////////////////
//delegate method

extension MapVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark, addressString: String){
        self.addressString = addressString
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        searchBar.text = addressString
        shouldMapCenter = true
    }
}


extension MapVC : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            hasUserLocBeenFound = true
            currentLoc = location
            if !shouldMapCenter{
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
                shouldMapCenter = true
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
}