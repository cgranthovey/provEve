//
//  AddEventExt-Post.swift
//  Ibento
//
//  Created by Chris Hovey on 11/7/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

//extension includes all parts dealing with posting from AddEventVC
extension AddEventVC: yesSelectedProtocol{
    
    func areYouSureLauncher(){
        if titleTextField.text == nil || titleTextField.text == ""{
            alert("Error", message: "Title Missing")
            return
        }
        if locationTextField.text == nil || locationTextField.text == ""{
            alert("Error", message: "Location Missing")
            return
        }
        if pinLocDict.isEmpty{
            alert("Error", message: "Pin Missing")
            return
        }
        
        if selectedCellInt == nil{
            alert("Error", message: "Choose event type icon")
            return
        }
        
        if dateString == nil{
            alert("Error", message: "Date Missing")
            return
        }
        
        if descriptionTextView.text == nil || descriptionTextView.text == ""{
            alert("Error", message: "Description Missing")
            return
        }
        
        yesNoView.showDeleteView(self.view, lblText: "Post Event?")
    }
    
    func yesPressed() {
        toFireBase()
    }
    
    func toFireBase(){

        let selectedCellImgName = img[selectedCellInt]
        makeLoadingView()
        let timePosted: Int = Int(NSDate().timeIntervalSince1970)
        let toFirebaseDict: Dictionary<String, AnyObject> = ["title": titleTextField.text!, "location": locationTextField.text!, "pinInfo": pinLocDict,"date": dateString!, "timeStampOfEvent": timeStampOfEvent,"email": emailTextField.text!, "timePosted": timePosted, "description": descriptionTextView.text!, "user": (FIRAuth.auth()?.currentUser?.uid)!, "eventTypeImgName": selectedCellImgName]
        
        let key = DataService.instance.eventRef.childByAutoId().key
        holdKeyInCaseError = key
        
        let childValues: Dictionary<String, AnyObject> = ["/Events/\(key)": toFirebaseDict, "/User/\((FIRAuth.auth()?.currentUser?.uid)!)/posts/\(key)": "True"]
        DataService.instance.mainRef.updateChildValues(childValues) { (err, FIRDatabaseRef) in
            if err != nil{
                print(err?.localizedDescription)
                self.alert("Error", message: "Error uploading data, try again soon")
            } else{
                
                print("problem: \(self.eventImg.image)")
                if self.imgChoosen{
                    if let img = self.eventImg.image {
                        if let data: NSData = UIImageJPEGRepresentation(img, 0.8){
                            let imgName = "\(NSUUID().UUIDString)jpg"
                            let storageRef = DataService.instance.imgStorageRefData.child(imgName)
                            storageRef.putData(data, metadata: nil, completion: { (meta, err) in
                                if err != nil{
                                    self.alertProblemUploadingImg()
                                    return
                                } else{
                                    self.postGeoFire(self.coordinateOfEvent, eventRef: key)
                                    let downloadURL = meta?.downloadURL()?.absoluteString
                                    DataService.instance.eventRef.child(key).child("image").setValue(downloadURL)
                                    self.performSelector(#selector(AddEventVC.makeSuccessView), withObject: self, afterDelay: 1.5)
                                }
                            })
                        }
                    } else {
                        self.noImg(key)
                    }
                } else{
                    self.noImg(key)
                }
            }
        }
    }
    
    func noImg(key: String){
        self.postGeoFire(self.coordinateOfEvent, eventRef: key)
        self.performSelector(#selector(AddEventVC.makeSuccessView), withObject: self, afterDelay: 0.75)
    }

    func makeLoadingView(){
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.loadingView.center = self.view.center
        self.loadingView.backgroundColor = UIColor.blackColor()
        self.loadingView.alpha = 0
        view.addSubview(self.loadingView)
        
        exit = UIButton(frame: CGRect(x: 20, y: 20, width: 32, height: 32))
        exit.setImage(UIImage(named: "deleteWhite"), forState: .Normal)
        exit.imageView?.contentMode = .ScaleAspectFit
        exit.addTarget(self, action: #selector(AddEventVC.cancelUpload), forControlEvents: .TouchUpInside)
        exit.alpha = 0
        self.view.addSubview(exit)
        self.view.bringSubviewToFront(exit)
        
        self.spinIndicator = UIActivityIndicatorView()
        self.spinIndicator.center = self.loadingView.center
        self.spinIndicator.color = UIColor.whiteColor()
        self.spinIndicator.startAnimating()
        self.spinIndicator.alpha = 0
        self.loadingView.addSubview(self.spinIndicator)
        
        UIView.animateWithDuration(0.5, animations: {
            self.loadingView.alpha = 0.8
        }) { (true) in
            UIView.animateWithDuration(0.5, animations: {
                self.exit.alpha = 1
                self.spinIndicator.alpha = 1
                }, completion: nil)
        }
    }
    
    func cancelUpload(){
        FIRDatabase.database().purgeOutstandingWrites()
        loadingViewFade()
    }
    
    func alertProblemUploadingImg(){
        spinIndicFade()
        let alert = UIAlertController(title: "Error Uploading Image", message: "Would you like to post now without the image, or try later with the image", preferredStyle: .Alert)
        let actionNow = UIAlertAction(title: "Now", style: .Default) {(action: UIAlertAction) in
            
            let imgSuccess2 = UIImageView(image: UIImage(named: "whiteCheck"))
            imgSuccess2.showCheckmarkAnimatedTempImg(self.view, delay: 0.2, remove: false)
            self.performSelector(#selector(AddEventVC.popOut), withObject: nil, afterDelay: 2)
        }
        let actionLater = UIAlertAction(title: "Later", style: .Default) {(action: UIAlertAction) in
            self.loadingViewFade()
            if let key = self.holdKeyInCaseError{
                DataService.instance.eventRef.child(key).removeValue()      //removes firebase data at location, however other users would be able to view post for a second until user deletes it
            }
        }
        alert.addAction(actionNow)
        alert.addAction(actionLater)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func postGeoFire(location: CLLocationCoordinate2D?, eventRef: String?){
        var geoFire: GeoFire!
        var geoFireRef: FIRDatabaseReference!
        geoFireRef = DataService.instance.mainRef.child("GeoFire")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        if let loc = location, let key = eventRef{
            geoFire.setLocation(CLLocation(latitude: loc.latitude, longitude: loc.longitude), forKey: key) { (error) in
                if error != nil{
                    print(error.debugDescription)
                } else{
                    //upload successful!
                }
            }
        }
    }
    
    func loadingViewFade(){
        if loadingView != nil{
            UIView.animateWithDuration(0.3, animations: {
                self.loadingView.alpha = 0
                self.exit.alpha = 0
            }) { (true) in
                self.loadingView.removeFromSuperview()
                self.exit.removeFromSuperview()
            }
        }
    }
    
    func spinIndicFade(){
        if spinIndicator != nil{
            UIView.animateWithDuration(0.5, animations: {
                self.spinIndicator.alpha = 0
                }, completion: nil)
        }
    }
}