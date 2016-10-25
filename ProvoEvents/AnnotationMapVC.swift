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
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var backBtnOutlet: UIButton!
    @IBOutlet weak var centerUserOutlet: UIButton!
    @IBOutlet weak var settingsOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true
                
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        backBtnOutlet.imageView?.contentMode = .ScaleAspectFit
        centerUserOutlet.imageView?.contentMode = .ScaleAspectFit
        settingsOutlet.imageView?.contentMode = .ScaleAspectFit
        mapTypeBtnOutlet.imageView?.contentMode = .ScaleAspectFit
        
        
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(AnnotationMapVC.showSettings))
        edgeSwipe.edges = .Left
        self.view.addGestureRecognizer(edgeSwipe)
        edgeSwipe.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnnotationMapVC.newParameters(_:)), name: "mapParameterChange", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnnotationMapVC.newParameters(_:)), name: "mapParameterAll", object: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func showSettings(recoginizer: UIScreenEdgePanGestureRecognizer){
        print("Seen")
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
        if let dict = notif.userInfo as? Dictionary<String, NSDate>{
            if let date = dict["date"]{
                choosenDate = date
                geoFireQuery()
            }
        } else{
            choosenDate = nil
            geoFireQuery()
            print("show all")
            // all events
        }
    }

    
    @IBAction func popVC(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func centerUser(){
        if hasUserLocBeenFound{
            adjustMapCenter(currentLoc.coordinate)
        }
    }
    
    
    let settingsLauncher = MapSettingsLauncher()
    
    @IBAction func settings(){
        settingsLauncher.showSettings()
    }
    
    @IBOutlet weak var mapTypeBtnOutlet: UIButton!
    
    
    
    @IBAction func mapTypeBtnPressed(){
        if mapView.mapType == .Standard{
            mapTypeBtnOutlet.changeImageAnimated(UIImage(named: "mapStandard"))
            mapView.mapType = .Hybrid
        } else{
            
            mapTypeBtnOutlet.changeImageAnimated(UIImage(named: "mapWorld"))
            //mapTypeBtn.setImage(UIImage(named: "mapStandard"), forState: .Normal)
            mapView.mapType = .Standard
        }
    }
    
    func adjustMapCenter(coord: CLLocationCoordinate2D){
        
        let curSpan = mapView.region.span
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

        if curSpan.latitudeDelta < span.latitudeDelta{
            let region = MKCoordinateRegion(center: coord, span: curSpan)
            mapView.setRegion(region, animated: true)
        } else{
            let region = MKCoordinateRegion(center: coord, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func annotationBtnTapped(button: UIButton){
        print("in annotation btn tapped")
        
        let buttonTag = button.tag
        print("button tag \(buttonTag)")
        print("dictTagForKey \(dictEnterTagForEventKey)")
        if let key = dictEnterTagForEventKey[buttonTag]{
            let event = dictEnterKeyForEvent[key]
            performSegueWithIdentifier("EventDetailsVC", sender: event)
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("in prepare for segue")
        if segue.identifier == "EventDetailsVC"{
            if let destVC = segue.destinationViewController as? EventDetailsVC{
                if let event = sender as? Event{
                    destVC.event = event
                }
            }
        }
    }
    
    
    func geoFireQuery(){
        print("yo")
        let geoFireRef: FIRDatabaseReference!
        let geoFire: GeoFire!
        
        geoFireRef = DataService.instance.geoFireRef
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        var span = MKCoordinateSpan()
        var centerCoord = CLLocationCoordinate2D()
        
        if shouldMapCenter{
            print("my span")
            span = MKCoordinateSpanMake(0.05, 0.05)
            centerCoord = currentLoc.coordinate
        } else{
            span = mapView.region.span
            print("SPANY: \(span)")
            centerCoord = mapView.centerCoordinate
        }
        
        print("my span \(span)  coord \(centerCoord)")
        
        let region = MKCoordinateRegionMake(centerCoord, span)
        
        
        if isRegionValid(region){
        
            let regionQuery = geoFire.queryWithRegion(region)
            
            var queryHandle = regionQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                
                print("key: \(key) and the location: \(location)")
                
                if self.dictEnterKeyForEvent[key] == nil{
                    self.loadEventInfo(key, location: location)
                } else {//if we already have key then we don't need to make another annotation
                   // self.makeAnotation(key, location: location)
                }
            })
        }
    }
    
    
    
    func isRegionValid(region: MKCoordinateRegion) -> Bool{
        
        let centerLatDegrees = region.center.latitude
        let topLatDegrees = centerLatDegrees + region.span.latitudeDelta / 2
        let bottomLatDegrees = centerLatDegrees - region.span.latitudeDelta / 2
        
        let centerLongDegrees = region.center.longitude
        
        let centerTop = CLLocationCoordinate2D(latitude: topLatDegrees, longitude: centerLongDegrees)
        let centerBottom = CLLocationCoordinate2D(latitude: bottomLatDegrees, longitude: centerLongDegrees)
        
        if CLLocationCoordinate2DIsValid(centerTop) && CLLocationCoordinate2DIsValid(centerBottom){
            return true
        } else{
            return false
        }
    }
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    var dictEnterKeyForEvent = Dictionary<String, Event>()
    var dictEnterTagForEventKey = Dictionary<Int, String>()
    
    func loadEventInfo(key: String, location: CLLocation){
        print("yooooooooooooooooo")
        DataService.instance.eventRef.child(key).observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot)
            if let tempDict = snapshot.value as? Dictionary<String, AnyObject>{
                let event = Event(key: key, dict: tempDict, isLiked: false)
                
                if event.beforeToday(){
                    DataService.instance.geoFireRef.child(key).setValue(nil)
                    return
                }
                if let dateUserChoose = self.choosenDate{
                    if event.onThisDay(dateUserChoose){
                        self.dictEnterKeyForEvent[key] = event
                        self.makeAnotation(key, location: location)
                        return
                    } else{
                        return
                    }
                }

                print("my count \(self.dictEnterKeyForEvent.count)")
                self.dictEnterKeyForEvent[key] = event
                self.makeAnotation(key, location: location)
                

            }
        })
    }
    
    var annotationArray = [MKAnnotation]()
    
    func makeAnotation(key: String, location: CLLocation){
        print("how many events holder? \(dictEnterKeyForEvent.count)")
        
        if let event = dictEnterKeyForEvent[key]{
            
            
            
            
            let eventAnnotation = customMKPointAnnotation()
                eventAnnotation.event = event
                eventAnnotation.coordinate = location.coordinate
                eventAnnotation.title = event.title
                eventAnnotation.subtitle = event.location
            let anno = eventAnnotation as? MKAnnotation
            annotationArray.append(anno!)
            self.mapView.addAnnotation(eventAnnotation)
        }
    }
}



extension AnnotationMapVC: MKMapViewDelegate{
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("mom")
        if annotation is MKUserLocation{
            print("always")
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
        button.setBackgroundImage(UIImage(named: "addEvent"), forState: .Normal)
        button.addTarget(self, action: #selector(AnnotationMapVC.annotationBtnTapped(_:)), forControlEvents: .TouchUpInside)
        button.tag = currentBtnTag
        self.dictEnterTagForEventKey[currentBtnTag] = myEvent!.key
        currentBtnTag = currentBtnTag + 1
        pinView?.leftCalloutAccessoryView = button
        return pinView
        
        
//        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        //this commented code is to implement a custom pin image
//        
////        let reuseId = "pin"
////        var annotationView: MKAnnotationView?
////        if let dequeueAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId){
////            annotationView = dequeueAnnotationView
////            annotationView?.annotation = annotation
////            print("this")
////            
////        } else{
////            print("is")
////            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
////            av.leftCalloutAccessoryView = UIButton(type: .DetailDisclosure)
////            annotationView = av
////        }
////        
////        if let annotationView = annotationView  {
////            // Configure your annotation view here
////            print("chris")
////            let myEvent = (annotationView.annotation as? customMKPointAnnotation)?.event
////            
////            annotationView.canShowCallout = true
////            print("before")
////            
////            let pinImg: UIImage!
////            
////            if myEvent?.eventTypeImgName == "" || myEvent?.eventTypeImgName == nil{
////                pinImg = UIImage(named: "addEvent")
////            } else{
////                print("reached")
////                pinImg = UIImage(named: (myEvent?.eventTypeImgName)!)
////            }
////            
////            let size = CGSize(width: 50, height: 50)
////            UIGraphicsBeginImageContext(size)
////            pinImg!.drawInRect(CGRectMake(0, 0, size.width, size.height))
////            
////            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
////            UIGraphicsEndImageContext()
////            
////            annotationView.contentMode = .ScaleAspectFit
////            annotationView.image = resizedImage
////            
////            
////            
////            print("done")
////            let smallSquare = CGSize(width: 30, height: 30)
////            let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
////            button.setBackgroundImage(UIImage(named: "addEvent"), forState: .Normal)
////            button.addTarget(self, action: #selector(AnnotationMapVC.annotationBtnTapped(_:)), forControlEvents: .TouchUpInside)
////            button.tag = currentBtnTag
////            self.dictEnterTagForEventKey[currentBtnTag] = myEvent!.key
////            currentBtnTag = currentBtnTag + 1
////            
////            annotationView.leftCalloutAccessoryView = button
////
////            annotationView.tintColor = UIColor.yellowColor()
////        }
////        print("returning")
////        return annotationView
//        
//        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region changed")
        geoFireQuery()
    }

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        print("add anno")
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("selecto anno")
        
    }
}



extension AnnotationMapVC: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("byebye")

        if status == .AuthorizedWhenInUse {
            print("bye")

            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLoc = location
            hasUserLocBeenFound = true
            print("in loc manager")
            if shouldMapCenter{
                print("inside should map center")
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

class customMKPointAnnotation: MKPointAnnotation{
    
    var event: Event!
    
}














