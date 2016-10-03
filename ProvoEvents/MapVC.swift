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
    func dropPinZoomIn(placemark: MKPlacemark, addressString: String, fromTap: Bool)
}



class MapVC: UIViewController {

    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil //will use to cache any incoming placemarks.
    var addressString = ""
    
    var addressPassed: String!
    var mkPlacemarkPassed: MKPlacemark!
    var shouldMapCenter = true
    var hasUserLocBeenFound = false
    
    var searchBar = UISearchBar()
    
    var currentLoc = CLLocation()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeBtn: UIButton!
    
    
    var handleGetEventLocDelegate: HandleGetEventLoc? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        self.navigationController?.navigationBarHidden = false
        navigationItem.hidesBackButton = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  //kCLLocationAccuracyBest
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
        
        
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(MapVC.tapForPin(_:)))
        longTap.minimumPressDuration = 0.7
        mapView.addGestureRecognizer(longTap)
        
        mapTypeBtn.setImage(UIImage(named:"mapWorld"), forState: .Normal)
        mapTypeBtn.contentMode = .ScaleAspectFit
        
        searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search or press to drop pin"
        
        navigationItem.titleView = resultSearchController?.searchBar

        ////////////////////////////////////////////////////////////////////////
        //if info is passed to vc
        if addressPassed != nil && mkPlacemarkPassed != nil{
            print("addressPassed \(addressPassed) placemark \(mkPlacemarkPassed.countryCode)")
            dropPinZoomIn(mkPlacemarkPassed, addressString: addressPassed, fromTap: false)
            shouldMapCenter = false
        }
        
        
    }
    
    @IBAction func mapTypeBtnPress(sender: AnyObject){
        if mapView.mapType == .Standard{
            mapTypeBtn.changeImageAnimated(UIImage(named: "mapStandard"))
            mapView.mapType = .Hybrid
        } else{
            
            mapTypeBtn.changeImageAnimated(UIImage(named: "mapWorld"))
            //mapTypeBtn.setImage(UIImage(named: "mapStandard"), forState: .Normal)
            mapView.mapType = .Standard
        }
    }
    
    func tapForPin(tap: UIGestureRecognizer){
        print("begin")
        if tap.state == UIGestureRecognizerState.Began{
            print("end")
            mapView.removeAnnotations(mapView.annotations)
            let touchPoint = tap.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                
            
            if setWithCoord{        //use only lat and long to determine pin
                placeSpecificCoord(newCoordinates)
            } else{     //run lat and long through geocoder to get an assumed location
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: { (placemarks, error) -> Void in
                    if error != nil {
                        self.placeSpecificCoord(newCoordinates)
                        print("Reverse geocoder failed w/ error \(error!.localizedDescription)")
                        return
                    }
                    if placemarks?.count > 0{
                        
                        print ("count \(placemarks!.count)")
                        print(placemarks![0])
                        if placemarks?.count > 1{
                            print("2. \(placemarks![1])")
                        }
                        
                        let pmCL = placemarks![0]
                        let pm = MKPlacemark(placemark: pmCL)
                        let addressLine = pm.getAddressInfo()
                        self.dropPinZoomIn(pm, addressString: addressLine, fromTap: true)
                    }
                })
            }
        }
    }
    
    func placeSpecificCoord(newCoordinates: CLLocationCoordinate2D){
        let coord = CLLocationCoordinate2D(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        let myPlacemark = MKPlacemark(coordinate: coord, addressDictionary: nil)
        self.dropPinZoomIn(myPlacemark, addressString: "\(myPlacemark.coordinate.latitude) \(myPlacemark.coordinate.longitude)", fromTap: true)
    }
    
    @IBAction func removePinBtn(sender: AnyObject){
        mapView.removeAnnotations(mapView.annotations)
        searchBar.text = ""
        selectedPin = nil
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
            adjustMapCenter(currentLoc.coordinate)
        }
    }
    
    @IBAction func pinLocBtn(sender: AnyObject){
        if let coord = selectedPin?.coordinate{
            adjustMapCenter(coord)
        } else{
            print("no pin set yet")
        }
    }
    
    var setWithCoord: Bool = false
    
    @IBAction func setWithCoordBtn(sender: AnyObject){
        if setWithCoord == false{
            setWithCoord = true
            sender.setTitle("Set with coordinates - true", forState: .Normal)
        } else{
            setWithCoord = false
            sender.setTitle("Set with coordinates - false", forState: .Normal)
        }
    }
    
    func adjustMapCenter(centerCoord: CLLocationCoordinate2D){
        
        let curSpan = mapView.region.span
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        if curSpan.latitudeDelta < span.latitudeDelta{
            let region = MKCoordinateRegion(center: centerCoord, span: curSpan)
            mapView.setRegion(region, animated: true)
        } else{
            let region = MKCoordinateRegion(center: centerCoord, span: span)
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
    func dropPinZoomIn(placemark:MKPlacemark, addressString: String, fromTap: Bool){
        self.addressString = addressString
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        if let name = placemark.name{
            annotation.title = name
        } else{
            annotation.title = "Unknown Place"
        }
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        
        if fromTap != true{
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(placemark.coordinate, span)
            mapView.setRegion(region, animated: true)
        }
        searchBar.text = addressString
        shouldMapCenter = false
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
            if shouldMapCenter{
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
                shouldMapCenter = false
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
}