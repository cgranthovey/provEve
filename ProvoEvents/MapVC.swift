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
    var wasAddressPassed = false
    var mkPlacemarkPassed: MKPlacemark!
    var shouldMapCenter = true
    var hasUserLocBeenFound = false
    var searchBar = UISearchBar()
    var currentLoc = CLLocation()
    var handleGetEventLocDelegate: HandleGetEventLoc? = nil
    var generalSpan: MKCoordinateSpan {
        get{
            return MKCoordinateSpanMake(0.15, 0.15)
        }
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeBtn: UIButton!
    @IBOutlet weak var centerUserBtn: UIButton!
    @IBOutlet weak var centerPinBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var approveView: UIView!
    @IBOutlet weak var questionBtn: UIButton!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var thumbsUpImage: UIImageView!
    @IBOutlet weak var approveColorView: UIView!
    @IBOutlet weak var approveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setUpLocationManager()
        setUpSearchTable()
        setUpApproveView()
        
        questionView.alpha = 0
        questionView.hidden = true
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(MapVC.tapForPin(_:)))
        longTap.minimumPressDuration = 0.7
        mapView.addGestureRecognizer(longTap)
        
        self.navigationController?.navigationBarHidden = false
        navigationItem.hidesBackButton = true
        navigationItem.titleView = resultSearchController?.searchBar

        //if info is passed to vc
        if addressPassed != nil && mkPlacemarkPassed != nil{
            dropPinZoomIn(mkPlacemarkPassed, addressString: addressPassed, fromTap: false)
            shouldMapCenter = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    func setUpLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  //kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func setUpSearchTable(){
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
        searchBar.placeholder = "Search or press to drop pin"
    }

    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Approve btn show/tapped
    
    func setUpApproveView(){
        approveView.alpha = 0
        approveView.hidden = true
        approveBtn.addTarget(self, action: #selector(MapVC.approveTouchUpInside), forControlEvents: .TouchUpInside)
        approveBtn.addTarget(self, action: #selector(MapVC.approveTouchUpOutside), forControlEvents: .TouchUpOutside)
        approveBtn.addTarget(self, action: #selector(MapVC.approveTouchDown), forControlEvents: .TouchDown)
    }
    
    func approveTouchDown(){
        self.thumbsUpImage.alpha = 1
        approveColorView.backgroundColor = UIColor(red: 211/255, green: 47/255, blue: 47/255, alpha: 1.0)

    }
    func approveTouchUpOutside(){
        self.thumbsUpImage.alpha = 0.6
        approveColorView.backgroundColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0)
    }
    func approveTouchUpInside(){
        approvePin()
    }
    
    func approvePin(){
        if selectedPin != nil{
            handleGetEventLocDelegate?.getEventLoc(addressString, name: selectedPin?.name, longitude: selectedPin?.coordinate.longitude, latitude: selectedPin?.coordinate.latitude, placemark: selectedPin)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showApproveView(){
        approveView.hidden = false
        UIView.animateWithDuration(0.3) {
            self.approveView.alpha = 1
        }
    }
    
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Question/Got It Btn
    
    var darkView: UIView!
    @IBAction func questionPress(sender: AnyObject){
        
        let rect = CGRectMake(0, -100, self.view.frame.width, self.view.frame.height + 100)
        self.darkView = UIView(frame: rect)
        darkView.backgroundColor = UIColor.blackColor()
        darkView.alpha = 0
        self.view.addSubview(darkView)
        self.view.bringSubviewToFront(questionView)
        questionView.hidden = false
        UIView.animateWithDuration(0.3, animations: { 
            self.darkView.alpha = 0.5
            self.questionView.alpha = 1
            }, completion: nil)
    }
    
    @IBAction func gotItBtn(sender: UIButton){
        UIView.animateWithDuration(0.3, animations: { 
            self.darkView.alpha = 0
            self.questionView.alpha = 0
            }) { (true) in
                self.darkView.removeFromSuperview()
                sender.backgroundColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0)
                self.questionView.hidden = true
        }
    }
    
    @IBAction func gotItBtnTouchDown(sender: UIButton){
        
        sender.backgroundColor = UIColor(red: 211/255, green: 47/255, blue: 47/255, alpha: 1.0)
    }
    
    @IBAction func gotItBtnTouchUpOutside(sender: UIButton){
        sender.backgroundColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //TapForPin
    
    func tapForPin(tap: UIGestureRecognizer){
        if tap.state == UIGestureRecognizerState.Began{
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
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Bottom Btns
    
    @IBAction func cancelBtn(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func mapTypeBtnPress(sender: AnyObject){
        if mapView.mapType == .Standard{
            mapTypeBtn.changeImageAnimated(UIImage(named: "worldGrid"))
            mapView.mapType = .Hybrid
        } else{
            mapTypeBtn.changeImageAnimated(UIImage(named: "worldFull"))
            mapView.mapType = .Standard
        }
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
            //no pin set yet
        }
    }
    
    var setWithCoord: Bool = false
    @IBOutlet weak var coordinateBtn: UIButton!
    @IBAction func setWithCoordBtn(sender: AnyObject){
        if setWithCoord == false{
            setWithCoord = true
            coordinateBtn.alpha = 1.0
        } else{
            setWithCoord = false
            coordinateBtn.alpha = 0.4
        }
    }
    
    func adjustMapCenter(centerCoord: CLLocationCoordinate2D, span: MKCoordinateSpan = MKCoordinateSpanMake(0.15, 0.15)){
        let curSpan = mapView.region.span
        let span = MKCoordinateSpan(latitudeDelta: span.latitudeDelta, longitudeDelta: span.longitudeDelta)
        if curSpan.latitudeDelta < span.latitudeDelta{
            let region = MKCoordinateRegion(center: centerCoord, span: curSpan)
            mapView.setRegion(region, animated: true)
        } else{
            let region = MKCoordinateRegion(center: centerCoord, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MapVC Extensions

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
        
        //prevents approve from showing up if user clicks pin button if pin was once already chosen
        if wasAddressPassed{
            wasAddressPassed = false
        } else{
            performSelector(#selector(MapVC.showApproveView), withObject: nil, afterDelay: 0.25)
        }
        return pinView
    }
}

///////////////////////////////////////////////////////////////////////////
//delegate method

extension MapVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark, addressString: String, fromTap: Bool){
        self.addressString = addressString
        selectedPin = placemark

        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
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
            let region = MKCoordinateRegionMake(placemark.coordinate, generalSpan)
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
                let region = MKCoordinateRegion(center: location.coordinate, span: generalSpan)
                mapView.setRegion(region, animated: true)
                shouldMapCenter = false
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}