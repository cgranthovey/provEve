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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol HandleMapSearch{
    func dropPinZoomIn(_ placemark: MKPlacemark, addressString: String, fromTap: Bool)
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
        questionView.isHidden = true
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(MapVC.tapForPin(_:)))
        longTap.minimumPressDuration = 0.7
        mapView.addGestureRecognizer(longTap)
        
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        navigationItem.titleView = resultSearchController?.searchBar

        //if info is passed to vc
        if addressPassed != nil && mkPlacemarkPassed != nil{
            dropPinZoomIn(mkPlacemarkPassed, addressString: addressPassed, fromTap: false)
            shouldMapCenter = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setUpLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  //kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func setUpSearchTable(){
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
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
        approveView.isHidden = true
        approveBtn.addTarget(self, action: #selector(MapVC.approveTouchUpInside), for: .touchUpInside)
        approveBtn.addTarget(self, action: #selector(MapVC.approveTouchUpOutside), for: .touchUpOutside)
        approveBtn.addTarget(self, action: #selector(MapVC.approveTouchDown), for: .touchDown)
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
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showApproveView(){
        approveView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.approveView.alpha = 1
        }) 
    }
    
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Question/Got It Btn
    
    var darkView: UIView!
    @IBAction func questionPress(_ sender: AnyObject){
        let rect = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height + 100)
        self.darkView = UIView(frame: rect)
        darkView.backgroundColor = UIColor.black
        darkView.alpha = 0
        self.view.addSubview(darkView)
        self.view.bringSubview(toFront: questionView)
        questionView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { 
            self.darkView.alpha = 0.5
            self.questionView.alpha = 1
            }, completion: nil)
    }
    
    @IBAction func gotItBtn(_ sender: UIButton){
        UIView.animate(withDuration: 0.3, animations: { 
            self.darkView.alpha = 0
            self.questionView.alpha = 0
            }, completion: { (true) in
                self.darkView.removeFromSuperview()
                sender.backgroundColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0)
                self.questionView.isHidden = true
        }) 
    }
    
    @IBAction func gotItBtnTouchDown(_ sender: UIButton){
        
        sender.backgroundColor = UIColor(red: 211/255, green: 47/255, blue: 47/255, alpha: 1.0)
    }
    
    @IBAction func gotItBtnTouchUpOutside(_ sender: UIButton){
        sender.backgroundColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //TapForPin
    
    func tapForPin(_ tap: UIGestureRecognizer){
        if tap.state == UIGestureRecognizerState.began{
            mapView.removeAnnotations(mapView.annotations)
            let touchPoint = tap.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                
            
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
    
    func placeSpecificCoord(_ newCoordinates: CLLocationCoordinate2D){
        let coord = CLLocationCoordinate2D(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        let myPlacemark = MKPlacemark(coordinate: coord, addressDictionary: nil)
        self.dropPinZoomIn(myPlacemark, addressString: "\(myPlacemark.coordinate.latitude) \(myPlacemark.coordinate.longitude)", fromTap: true)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Bottom Btns
    
    @IBAction func cancelBtn(_ sender: AnyObject){
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func mapTypeBtnPress(_ sender: AnyObject){
        if mapView.mapType == .standard{
            mapTypeBtn.changeImageAnimated(UIImage(named: "worldGrid"))
            mapView.mapType = .hybrid
        } else{
            mapTypeBtn.changeImageAnimated(UIImage(named: "worldFull"))
            mapView.mapType = .standard
        }
    }
    
    @IBAction func userLocBtn(_ sender: AnyObject){
        if hasUserLocBeenFound{
            adjustMapCenter(currentLoc.coordinate)
        }
    }
    
    @IBAction func pinLocBtn(_ sender: AnyObject){
        if let coord = selectedPin?.coordinate{
            adjustMapCenter(coord)
        } else{
            //no pin set yet
        }
    }
    
    var setWithCoord: Bool = false
    @IBOutlet weak var coordinateBtn: UIButton!
    @IBAction func setWithCoordBtn(_ sender: AnyObject){
        if setWithCoord == false{
            setWithCoord = true
            coordinateBtn.alpha = 1.0
        } else{
            setWithCoord = false
            coordinateBtn.alpha = 0.4
        }
    }
    
    func adjustMapCenter(_ centerCoord: CLLocationCoordinate2D, span: MKCoordinateSpan = MKCoordinateSpanMake(0.15, 0.15)){
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        
        //prevents approve from showing up if user clicks pin button if pin was once already chosen
        if wasAddressPassed{
            wasAddressPassed = false
        } else{
            perform(#selector(MapVC.showApproveView), with: nil, afterDelay: 0.25)
        }
        return pinView
    }
}

///////////////////////////////////////////////////////////////////////////
//delegate method

extension MapVC: HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark, addressString: String, fromTap: Bool){
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
