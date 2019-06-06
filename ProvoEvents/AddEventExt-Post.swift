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
    
    @objc func areYouSureLauncher(){
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
        let timePosted: Int = Int(Date().timeIntervalSince1970)
        let toFirebaseDict: Dictionary<String, AnyObject> = ["title": titleTextField.text! as AnyObject, "location": locationTextField.text! as AnyObject, "pinInfo": pinLocDict as AnyObject,"date": dateString! as AnyObject, "timeStampOfEvent": timeStampOfEvent as AnyObject,"email": emailTextField.text! as AnyObject, "timePosted": timePosted as AnyObject, "description": descriptionTextView.text! as AnyObject, "user": (FIRAuth.auth()?.currentUser?.uid)! as AnyObject, "eventTypeImgName": selectedCellImgName as AnyObject]
        
        let key = DataService.instance.eventRef.childByAutoId().key
        holdKeyInCaseError = key
        
        let childValues: Dictionary<String, AnyObject> = ["/Events/\(key)": toFirebaseDict as AnyObject, "/User/\((FIRAuth.auth()?.currentUser?.uid)!)/posts/\(key)": "True" as AnyObject]
        DataService.instance.mainRef.updateChildValues(childValues) { (err, FIRDatabaseRef) in
            if err != nil{
                print(err?.localizedDescription as Any)
                self.alert("Error", message: "Error uploading data, try again soon")
            } else{
                
                print("problem: \(self.eventImg.image)")
                if self.imgChoosen{
                    if let img = self.eventImg.image {
                        if let data: Data = UIImageJPEGRepresentation(img, 0.8){
                            let imgName = "\(UUID().uuidString)jpg"
                            let storageRef = DataService.instance.imgStorageRefData.child(imgName)
                            storageRef.put(data, metadata: nil, completion: { (meta, err) in
                                if err != nil{
                                    self.alertProblemUploadingImg()
                                    return
                                } else{
                                    self.postGeoFire(self.coordinateOfEvent, eventRef: key)
                                    let downloadURL = meta?.downloadURL()?.absoluteString
                                    DataService.instance.eventRef.child(key).child("image").setValue(downloadURL)
                                    self.perform(#selector(AddEventVC.makeSuccessView), with: self, afterDelay: 1.5)
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
    
    func noImg(_ key: String){
        self.postGeoFire(self.coordinateOfEvent, eventRef: key)
        self.perform(#selector(AddEventVC.makeSuccessView), with: self, afterDelay: 0.75)
    }

    func makeLoadingView(){
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.loadingView.center = self.view.center
        self.loadingView.backgroundColor = UIColor.black
        self.loadingView.alpha = 0
        view.addSubview(self.loadingView)
        
        exit = UIButton(frame: CGRect(x: 20, y: 20, width: 32, height: 32))
        exit.setImage(UIImage(named: "deleteWhite"), for: UIControlState())
        exit.imageView?.contentMode = .scaleAspectFit
        exit.addTarget(self, action: #selector(AddEventVC.cancelUpload), for: .touchUpInside)
        exit.alpha = 0
        self.view.addSubview(exit)
        self.view.bringSubview(toFront: exit)
        
//        self.spinIndicator = UIActivityIndicatorView()
//        self.spinIndicator.center = self.loadingView.center
//        self.spinIndicator.color = UIColor.whiteColor()
//        self.spinIndicator.startAnimating()
//        self.spinIndicator.alpha = 0
//        self.loadingView.addSubview(self.spinIndicator)
        
        actView.startAnimating()
        actView.center = self.view.center
        actView.alpha = 0
        self.view.addSubview(actView)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView.alpha = 0.8
        }, completion: { (true) in
            UIView.animate(withDuration: 0.5, animations: {
                self.exit.alpha = 1
                self.actView.alpha = 1
    //            self.spinIndicator.alpha = 1
                }, completion: nil)
        }) 
    }
    
    @objc func cancelUpload(){
        FIRDatabase.database().purgeOutstandingWrites()
        loadingViewFade()
    }
    
    func alertProblemUploadingImg(){
        spinIndicFade()
        let alert = UIAlertController(title: "Error Uploading Image", message: "Would you like to post now without the image, or try later with the image", preferredStyle: .alert)
        let actionNow = UIAlertAction(title: "Now", style: .default) {(action: UIAlertAction) in
            
            let imgSuccess2 = UIImageView(image: UIImage(named: "whiteCheck"))
            imgSuccess2.showCheckmarkAnimatedTempImg(self.view, delay: 0.2, remove: false)
            self.perform(#selector(AddEventVC.popOut), with: nil, afterDelay: 2)
        }
        let actionLater = UIAlertAction(title: "Later", style: .default) {(action: UIAlertAction) in
            self.loadingViewFade()
            if let key = self.holdKeyInCaseError{
                DataService.instance.eventRef.child(key).removeValue()      //removes firebase data at location, however other users would be able to view post for a second until user deletes it
            }
        }
        alert.addAction(actionNow)
        alert.addAction(actionLater)
        self.present(alert, animated: true, completion: nil)
    }
    
    func postGeoFire(_ location: CLLocationCoordinate2D?, eventRef: String?){
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
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingView.alpha = 0
                self.exit.alpha = 0
                self.actView.alpha = 0
            }, completion: { (true) in
                self.actView.removeFromSuperview()
                self.loadingView.removeFromSuperview()
                self.exit.removeFromSuperview()
            }) 
        }
    }
    
    func spinIndicFade(){
        if spinIndicator != nil{
            UIView.animate(withDuration: 0.5, animations: {
                self.spinIndicator.alpha = 0
                }, completion: nil)
        }
    }
}
