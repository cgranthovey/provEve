//
//  AnnotationMapVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/6/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AnnotationMapVC: UIViewController, UIGestureRecognizerDelegate {

    let locationManager = CLLocationManager()
    var currentLoc = CLLocation()
    var shouldMapCenter = true
    var currentBtnTag = 0
    var hasUserLocBeenFound = false
    var likesArray = [String]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backBtnOutlet: UIButton!
    @IBOutlet weak var centerUserOutlet: UIButton!
    @IBOutlet weak var settingsOutlet: UIButton!
    @IBOutlet weak var mapTypeBtnOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        setUpLocationAndEdgeSwipe()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnnotationMapVC.newParameters(_:)), name: "mapParameterChange", object: nil)
    }
    
    func setUpLocationAndEdgeSwipe(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(AnnotationMapVC.showSettings))
        edgeSwipe.edges = .Left
        self.view.addGestureRecognizer(edgeSwipe)
        edgeSwipe.delegate = self
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool { // can't edgeswipe on map without this function
        return true
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //settingsLauncher
    
    let settingsLauncher = MapSettingsLauncher()
    @IBAction func settings(){
        settingsLauncher.showSettings()
    }
    func showSettings(recoginizer: UIScreenEdgePanGestureRecognizer){
        if recoginizer.state == .Began{
            mapView.scrollEnabled = false
            settingsLauncher.showSettings()
            
        } else if recoginizer.state == .Ended{
            mapView.scrollEnabled = true
        }
    }

    var choosenDate: NSDate?
    func newParameters(notif: NSNotification){
        mapView.removeAnnotations(annotationArray)
        dictEnterKeyForEvent = [:]
        dictEnterTagForEventKey = [:]
        holdKeysArray = []
        if let dict = notif.userInfo as? Dictionary<String, NSDate>{
            if let date = dict["date"]{
                choosenDate = date
                geoFireQuery()
            }
        } else{
            choosenDate = nil
            geoFireQuery()
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //bottom buttons
    
    @IBAction func centerUser(){
        if hasUserLocBeenFound{
            adjustMapCenter(currentLoc.coordinate)
        }
    }
    
    func adjustMapCenter(coord: CLLocationCoordinate2D){
        
        let curSpan = mapView.region.span
        let span = MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
        
        if curSpan.latitudeDelta < span.latitudeDelta{
            let region = MKCoordinateRegion(center: coord, span: curSpan)
            mapView.setRegion(region, animated: true)
        } else{
            let region = MKCoordinateRegion(center: coord, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func backBtn(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func mapTypeBtnPressed(){
        if mapView.mapType == .Standard{
            mapTypeBtnOutlet.changeImageAnimated(UIImage(named: "worldGrid"))
            mapView.mapType = .Hybrid
        } else{
            
            mapTypeBtnOutlet.changeImageAnimated(UIImage(named: "worldFull"))
            mapView.mapType = .Standard
        }
    }
    
    func annotationBtnTapped(button: UIButton){
        let buttonTag = button.tag
        if let key = dictEnterTagForEventKey[buttonTag]{
            let event = dictEnterKeyForEvent[key]
            performSegueWithIdentifier("EventDetailsVC", sender: event)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventDetailsVC"{
            if let destVC = segue.destinationViewController as? EventDetailsVC{
                if let event = sender as? Event{
                    destVC.event = event
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //geoFireQuery
    
    func geoFireQuery(){
        let geoFireRef: FIRDatabaseReference!
        let geoFire: GeoFire!
        geoFireRef = DataService.instance.geoFireRef
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        var span = MKCoordinateSpan()
        var centerCoord = CLLocationCoordinate2D()
        
        if shouldMapCenter{
            span = MKCoordinateSpanMake(0.16, 0.16)
            centerCoord = currentLoc.coordinate
        } else{
            span = mapView.region.span
            centerCoord = mapView.centerCoordinate
        }
        
        let region = MKCoordinateRegionMake(centerCoord, span)
        
        if span.latitudeDelta < 3.5 {
            if region.isRegionValid(){
                let regionQuery = geoFire.queryWithRegion(region)
                regionQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                    if self.holdKeysArray.indexOf(key) == nil{
                        self.holdKeysArray.append(key)
                        self.loadEventInfo(key, location: location)
                    }
                })
            }
        }
    }
    
    var holdKeysArray = [String]()
    var dictEnterKeyForEvent = Dictionary<String, Event>()
    var dictEnterTagForEventKey = Dictionary<Int, String>()
    
    func loadEventInfo(key: String, location: CLLocation){
        DataService.instance.eventRef.child(key).observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot)
            if let tempDict = snapshot.value as? Dictionary<String, AnyObject>{
                let event: Event!
                if self.likesArray.indexOf(key) != nil{
                    event = Event(key: key, dict: tempDict, isLiked: true)
                } else{
                    event = Event(key: key, dict: tempDict, isLiked: false)
                }
                if event.beforeToday(){
                    DataService.instance.geoFireRef.child(key).setValue(nil)
                    return
                }
                if let dateUserChoose = self.choosenDate{   //if user choose specific date
                    if event.onThisDay(dateUserChoose){
                        self.dictEnterKeyForEvent[key] = event
                        self.makeAnotation(key, location: location)
                        return
                    } else{
                        return
                    }
                }
                self.dictEnterKeyForEvent[key] = event
                self.makeAnotation(key, location: location)
            }
        })
    }
    
    var annotationArray = [MKAnnotation]()
    func makeAnotation(key: String, location: CLLocation){
        if let event = dictEnterKeyForEvent[key]{
            let eventAnnotation = customMKPointAnnotation()
            eventAnnotation.event = event
            eventAnnotation.coordinate = location.coordinate
            eventAnnotation.title = event.title
            eventAnnotation.subtitle = event.location
            let anno = eventAnnotation as MKAnnotation
            annotationArray.append(anno)
            self.mapView.addAnnotation(eventAnnotation)
        }
    }
    
    var tapGest = UITapGestureRecognizer()
    let currentAnnoSelected = MKAnnotationView()
    func annoTapped(tapGest: UITapGestureRecognizer){
        if let annoView = tapGest.view as? MKAnnotationView{
            if let key = dictEnterTagForEventKey[annoView.tag]{
                let event = dictEnterKeyForEvent[key]
                performSegueWithIdentifier("EventDetailsVC", sender: event)
            }
        }
    }
}



extension AnnotationMapVC: MKMapViewDelegate{

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let myEvent = (annotation as? customMKPointAnnotation)?.event
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true

        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setImage(UIImage(named: (myEvent?.eventTypeImgName)!), forState: .Normal)
        button.addTarget(self, action: #selector(AnnotationMapVC.annotationBtnTapped(_:)), forControlEvents: .TouchUpInside)
        button.imageView?.contentMode = .ScaleAspectFit
        button.tag = currentBtnTag
        pinView?.tag = currentBtnTag
        
        self.dictEnterTagForEventKey[currentBtnTag] = myEvent!.key
        currentBtnTag = currentBtnTag + 1
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        view.removeGestureRecognizer(tapGest)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        tapGest = UITapGestureRecognizer(target: self, action: #selector(AnnotationMapVC.annoTapped(_:)))
        view.addGestureRecognizer(tapGest)  //if we add gesture recognizer in the ViewForAnnotation function above instead of showing the call out when we tap the pin, the event details screen shows right away
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        geoFireQuery()
    }
}





extension AnnotationMapVC: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLoc = location
            hasUserLocBeenFound = true
            if shouldMapCenter{
                let span = MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
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

class customMKPointAnnotation: MKPointAnnotation{
    var event: Event!
}
