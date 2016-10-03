//
//  AddEventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/19/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit

protocol HandleGetEventLoc {
    func getEventLoc(address:String?, name: String?, longitude: Double?, latitude: Double?, placemark: MKPlacemark?)
}

class AddEventVC: GeneralVC, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, GetDateTime, HandleGetEventLoc {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleTextField: LoginTextField!
    @IBOutlet weak var locationTextField: LoginTextField!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var descriptionTextView: TextView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var dateButtonTappedOutlet: UIButton!
    @IBOutlet weak var setPinBtnOutlet: UIButton!
    
    var imgPickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventImg.image = UIImage(named: "photoAlbum2")
        setUpTaps()
        setUpDelegates()
        
        imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        
        scrollView.contentSize.height = 700
        
    }
    
    var pinLocDict: Dictionary<String, AnyObject>! = [:]
    var holdPlacemark: MKPlacemark!
    var holdAddress: String!
    
    func getEventLoc(address: String?, name: String?, longitude: Double?, latitude: Double?, placemark: MKPlacemark?) {
        
        if let address = address, let name = name{
            print("tiger " + address)
            print("monster " + name)
            if address.containsString(name){
                print("contained")
                setPinBtnOutlet.setTitle(address, forState: .Normal)
            } else{
                print("not contained")
                setPinBtnOutlet.setTitle("\(name) - \(address)", forState: .Normal)
            }
        } else if let coordLat = latitude, let coordLong = longitude{
            setPinBtnOutlet.setTitle("\(coordLat), \(coordLong)", forState: .Normal)
        } else{
            setPinBtnOutlet.setTitle("SET PIN", forState: .Normal)
        }

        
        
    
        holdAddress = address
        holdPlacemark = placemark
        pinLocDict["address"] = address
        pinLocDict["name"] = name
        pinLocDict["longitude"] = longitude
        pinLocDict["latitude"] = latitude
        
        
        
        print("the address of the event is \(address), name: \(name), longitude: \(longitude), latitude: \(latitude)")
    }
    
    @IBAction func dateButtonTapped(sender: UIButton){
        titleTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        performSegueWithIdentifier("DateTimeVC", sender: nil)
    }
    
    @IBAction func addPinButtonTapped(sender: UIButton){
        
        
        
        performSegueWithIdentifier("MapVC", sender: nil)
    }
    
    @IBAction func submit(sender: AnyObject){
        print("alert")
        print("title: \(titleTextField.text)")
        
        if titleTextField.text == nil || titleTextField.text == ""{
            alert("Error", message: "Title Missing")
            return
        }
        
        if locationTextField.text == nil || locationTextField.text == ""{
            alert("Error", message: "Location Missing")
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
        
        var timePosted: Int = Int(NSDate().timeIntervalSince1970)
        
        let toFirebaseDict: Dictionary<String, AnyObject> = ["title": titleTextField.text!, "location": locationTextField.text!, "pinInfo": pinLocDict,"date": dateString!, "timeStampOfEvent": timeStampOfEvent,"email": emailTextField.text!, "timePosted": timePosted, "description": descriptionTextView.text!, "user": (FIRAuth.auth()?.currentUser?.uid)!]
        
        let key = DataService.instance.eventRef.childByAutoId().key
        holdKeyInCaseError = key
        
        let childValues: Dictionary<String, AnyObject> = ["/Events/\(key)": toFirebaseDict, "/User/\((FIRAuth.auth()?.currentUser?.uid)!)/posts/\(key)": "True"]
        DataService.instance.mainRef.updateChildValues(childValues) { (err, FIRDatabaseRef) in
            if err != nil{
                print(err?.localizedDescription)
                self.alert("Error", message: "Error uploading data, try again soon")
            } else{
                if let img = self.eventImg.image where img != UIImage(named: "photoAlbum2"){
                    if let data: NSData = UIImageJPEGRepresentation(img, 0.8){
                        let imgName = "\(NSUUID().UUIDString)jpg"
                        let storageRef = DataService.instance.imgStorageRefData.child(imgName)
                        storageRef.putData(data, metadata: nil, completion: { (meta, err) in
                            if err != nil{
                                self.alertProblemUploadingImg()
                            } else{
                                print("I'm on top")
                                let downloadURL = meta?.downloadURL()?.absoluteString
                                DataService.instance.eventRef.child(key).child("image").setValue(downloadURL)
                            }
                        })
                    }
                }
                print("i'm on bottom")
            }
        }
    }
    
    var holdKeyInCaseError: String!
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func alertProblemUploadingImg(){
        let alert = UIAlertController(title: "Error Uploading Image", message: "Would you like to post now without the image, or try later with the image", preferredStyle: .Alert)
        let actionNow = UIAlertAction(title: "Now", style: .Default) {(action: UIAlertAction) in
            print("info uploaded without image")
        }
        let actionLater = UIAlertAction(title: "Later", style: .Default) {(action: UIAlertAction) in
            if let key = self.holdKeyInCaseError{
                DataService.instance.eventRef.child(key).removeValue()      //removes firebase data at location, however other users would be able to view post for a second until user deletes it
            }
        }
        alert.addAction(actionNow)
        alert.addAction(actionLater)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var currentDate: NSDate?
    var dateString: String!
    var timeStampOfEvent: Int!
    
    func getTheDateTime(date: NSDate){
        
        timeStampOfEvent = Int(date.timeIntervalSince1970)
        currentDate = date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateString = dateFormatter.stringFromDate(date)
        print("date String: \(dateString)")
        
        dateButtonTappedOutlet.setTitle(dateString, forState: .Normal)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DateTimeVC"{
            if let destinationVC = segue.destinationViewController as? DateTimeVC{
                destinationVC.delegate = self
                if let curDate = currentDate{
                    destinationVC.currentDate = curDate
                }
            }
        }
        if segue.identifier == "MapVC"{
            if let destinationVC = segue.destinationViewController as? MapVC{
                destinationVC.handleGetEventLocDelegate = self
                if let pm = holdPlacemark, let ad = holdAddress{
                    print("holdTo \(ad)")
                    destinationVC.mkPlacemarkPassed = pm
                    destinationVC.addressPassed = ad
                }
            }
        }
        
    }
    
    func setUpDelegates(){
        descriptionTextView.delegate = self
        titleTextField.delegate = self
        locationTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func setUpTaps(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let tapImg = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.imageTapped))
        eventImg.userInteractionEnabled = true
        eventImg.addGestureRecognizer(tapImg)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func imageTapped(){

        self.presentViewController(imgPickerController, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        

        
        imgPickerController.dismissViewControllerAnimated(true, completion: nil)
        eventImg.image = image
        eventImg.roundCornersForAspectFit(5)
        let bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imgPickerController.dismissViewControllerAnimated(true, completion: nil)
        let bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView == descriptionTextView{
            scrollView.setContentOffset(CGPointMake(0, 330), animated: true)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == descriptionTextView{
            
            let bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func popVC(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
