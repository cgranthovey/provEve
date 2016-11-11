//
//  CreateUserInfoVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/16/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUserInfoVC: GeneralVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, imagePopDelegate {

    @IBOutlet weak var firstName: LoginTextField!
    @IBOutlet weak var userName: LoginTextField!
    @IBOutlet weak var photoLibBtnOutlet: LoginButton!
    @IBOutlet weak var cameraBtnOutlet: LoginButton!
    @IBOutlet weak var screenViewForCameraOutlets: UIView!
    @IBOutlet weak var userImgBtn: buttonSubAnimate!
    @IBOutlet weak var userImg: UIImageView!
    
    var isConnected = true
    var tapImg: UITapGestureRecognizer!
    var imgPicker: UIImagePickerController!
    var cameraTaker: UIImagePickerController!
    var password: String!
    var email: String!
    var tap: UITapGestureRecognizer!
    var preventPopVC: Bool = false
    let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        checkForInternet()
        setUpImagePickers()
        userImgBtn.setUpEventImgBtn(userImg)        //when I tried putting the image inside the btn there was an animation delay.  However with a seperate imgview there was no delay
        userImgBtn.delegate = self
        firstName.delegate = self
        userName.delegate = self
        hideCameraBtns()
        tap = UITapGestureRecognizer(target: self, action: #selector(CreateUserInfoVC.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
    }
    
    override func swipePopBack() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func checkForInternet(){
        if isConnected == false{
            let x = NoConnectionView()
            x.showNoConnectionView(self.view)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeFirstResponder()
    }
    
    func removeFirstResponder(){
        firstName.resignFirstResponder()
        userName.resignFirstResponder()
    }
    
    func setUpImagePickers(){
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self

        cameraTaker = UIImagePickerController()
        cameraTaker.delegate = self
        cameraTaker.sourceType = .PhotoLibrary  //change to camera later
    }
    
    func hideCameraBtns(){
        photoLibBtnOutlet.hidden = true
        cameraBtnOutlet.hidden = true
        screenViewForCameraOutlets.hidden = true
        photoLibBtnOutlet.alpha = 0
        cameraBtnOutlet.alpha = 0
        screenViewForCameraOutlets.alpha = 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func imageCompletedPop() {
        showImgOptions()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == " "{
            return false
        }
        return true
    }
    
    @IBAction func finished(sender: AnyObject){
        if let user = userName.text where (user.characters.count > 2){
            loadingView.showSpinnerView(self.view)
            let fireBaseDict: Dictionary<String, String>!

            if let first = firstName.text{
                fireBaseDict = ["firstName": first, "userName": user]
            } else{
                fireBaseDict = ["userName": user]
            }
            
            print("user \(user)")
            
            
            DataService.instance.usernamesRef.queryOrderedByChild("UserID").queryEqualToValue(user).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let snap = snapshot.value as? Dictionary<String, AnyObject>{
                    self.alerts("Username", message: "This username has already been choosen")
                } else{
                    
                    let dict: Dictionary<String, AnyObject> = ["/User/\((FIRAuth.auth()?.currentUser?.uid)!)/profile": fireBaseDict, "/Usernames/\(DataService.instance.usernamesRef.childByAutoId().key)/UserID" : "\(user)"]
                    DataService.instance.mainRef.updateChildValues(dict, withCompletionBlock: { (error, FIRDatabaseReference) in
                        if error != nil{
                            self.alerts("Error", message: "There was an error uploading your info")
                        } else{
                            self.uploadProfileImg()
                            
                            // setting username in nsdefualts
                            let prefs = NSUserDefaults.standardUserDefaults()
                            let uid = FIRAuth.auth()?.currentUser?.uid
                            prefs.setValue(user, forKey: "\(uid)Username")
                            
                            self.loadingView.successCancelSpin({
                                self.performSegueWithIdentifier("snapScrollVC", sender: nil)
                            })
                        }
                    })
                }
            })
        } else{
            alerts("Username", message: "Username must be at least 3 characters")
        }
    }
    
    @IBAction func photoLibBtn(sender: AnyObject){
        self.presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraBtn(sender: AnyObject){
        self.presentViewController(cameraTaker, animated: true, completion: nil)
    }
    
    func uploadProfileImg(){
        if userImg.image != UIImage(named: "profile"){
            if let picData: NSData = UIImageJPEGRepresentation(userImg.image!, 0.3){
                let imgName = "\(NSUUID().UUIDString).jpg"
                let ref = DataService.instance.imgStorageRefData.child(imgName)
                let task = ref.putData(picData, metadata: nil, completion: { (metaData, err) in
                    if err != nil {
                        print("an error occured in the uploadProfileImg!")
                    } else{
                        let downloadURLsting = metaData?.downloadURL()?.absoluteString
                        DataService.instance.currentUserProfile.child("profileImg").setValue(downloadURLsting)
                        print("Download url: \(downloadURLsting)")
                    }
                })
            }
        }
    }
    
    func showImgOptions(){
        removeFirstResponder()
        screenViewForCameraOutlets.hidden = false
        UIView.animateWithDuration(0.4, animations: {
            self.screenViewForCameraOutlets.alpha = 0.65
            }) { (true) in
                self.photoLibBtnOutlet.hidden = false
                self.cameraBtnOutlet.hidden = false
                UIView.animateWithDuration(0.4, animations: {
                    self.photoLibBtnOutlet.alpha = 1.0
                    self.cameraBtnOutlet.alpha = 1.0
                    }, completion: { (true) in
                        let tapAnywhereButButton = UITapGestureRecognizer()
                        tapAnywhereButButton.addTarget(self, action: #selector(CreateUserInfoVC.removeCameraPhotoLibOptions))
                        self.screenViewForCameraOutlets.addGestureRecognizer(tapAnywhereButButton)
                })
        }
    }
    
    func removeCameraPhotoLibOptions(){
        UIView.animateWithDuration(0.6, animations: {
            self.screenViewForCameraOutlets.alpha = 0
            self.photoLibBtnOutlet.alpha = 0
            self.cameraBtnOutlet.alpha = 0
            }) { (true) in
                self.screenViewForCameraOutlets.hidden = true
                self.photoLibBtnOutlet.hidden = true
                self.cameraBtnOutlet.hidden = true
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if picker.sourceType == UIImagePickerControllerSourceType.Camera{
            cameraTaker.dismissViewControllerAnimated(true, completion: nil)
            userImg.image = image
            hideCameraBtns()
            makeProfilePicRound()
        } else{
            imgPicker.dismissViewControllerAnimated(true, completion: nil)
            userImg.image = image
            hideCameraBtns()
            makeProfilePicRound()
        }
    }
    
    func makeProfilePicRound(){
        if userImg.image != UIImage(named: "profile"){
            userImg.contentMode = UIViewContentMode.ScaleAspectFill
            userImg.layer.cornerRadius = (userImg.frame.height) / 2
            userImg.clipsToBounds = true
        }
    }
    
    func alerts(title: String, message: String){
        loadingView.cancelSpinnerAndDarkView(nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}
