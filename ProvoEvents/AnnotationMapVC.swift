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


class AnnotationMapVC: UIViewController {

    let locationManager = CLLocationManager()
    var currentLoc = CLLocation()
    var shouldMapCenter = true
    

    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    func geoFireQuery(){
        print("yo")
        let geoFireRef: FIRDatabaseReference!
        let geoFire: GeoFire!
        
        geoFireRef = DataService.instance.mainRef.child("GeoFire")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(currentLoc.coordinate, span)
        let regionQuery = geoFire.queryWithRegion(region)
        
        var queryHandle = regionQuery.observeEventType(.KeyEntered) { (key: String!, location: CLLocation!) in
            print("key: \(key) and the location: \(location)")
        }
    }
    
    
    
    @IBAction func centerUser(){
        adjustMapCenter(currentLoc.coordinate)
    }
    
    
    func adjustMapCenter(coord: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coord, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func annotationBtnTapped(){
        print("annotationBtnTapped")
    }
    

}

extension AnnotationMapVC: MKMapViewDelegate{
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.tintColor = UIColor.redColor()
            pinView?.canShowCallout = true
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "addEvent"), forState: .Normal)
        button.addTarget(self, action: #selector(AnnotationMapVC.annotationBtnTapped), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView

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
            geoFireQuery()
            print("in loc manager")
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