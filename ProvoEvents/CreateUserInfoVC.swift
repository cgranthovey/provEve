//
//  CreateUserInfoVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/16/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateUserInfoVC: GeneralVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var firstName: LoginTextField!
    @IBOutlet weak var userName: LoginTextField!
    @IBOutlet weak var myUserImg: UIImageView!
    
    @IBOutlet weak var photoLibBtnOutlet: LoginButton!
    @IBOutlet weak var cameraBtnOutlet: LoginButton!
    @IBOutlet weak var screenViewForCameraOutlets: UIView!
    
    var tapImg: UITapGestureRecognizer!
    
    var imgPicker: UIImagePickerController!
    var cameraTaker: UIImagePickerController!
    
    var userInfoDict: Dictionary<String, AnyObject>!
    var password: String!
    var email: String!
    
    var tap: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unwrapPassAndEmailDict()
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        firstName.delegate = self
        userName.delegate = self
        
        hideCameraBtns()
        cameraTaker = UIImagePickerController()
        cameraTaker.delegate = self
        cameraTaker.sourceType = .Camera
        
        tap = UITapGestureRecognizer(target: self, action: #selector(CreateUserInfoVC.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
        
        myUserImg.userInteractionEnabled = true
        tapImg = UITapGestureRecognizer(target: self, action: #selector(CreateUserInfoVC.showImgOptions))
        self.myUserImg.addGestureRecognizer(tapImg)
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeFirstResponder()
    }

    
    func unwrapPassAndEmailDict(){
        password = userInfoDict["password"] as? String
        email = userInfoDict["email"] as? String
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func removeFirstResponder(){
        firstName.resignFirstResponder()
        userName.resignFirstResponder()
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
    
    @IBAction func finished(sender: AnyObject){
        if let user = userName.text, first = firstName.text where (user.characters.count > 5){
            
            guard first.characters.count > 0 else {
                alerts("First Name", message: "The first name must be at least one character")
                return 
            }
            
            AuthService.instance.createUser(password, email: email, onComplete: { (errMsg, data) in
                guard errMsg == nil else{
                    self.alerts("Error Authenticating", message: errMsg)
                    return
                }
                AuthService.instance.login(self.password, email: self.email, onComplete: { (errMsg, data) in
                    guard errMsg == nil else{
                        self.alerts("Error Authenticating", message: errMsg)
                        return
                    }
                    print("logged in woot woot!")
                    let fireBaseDict: Dictionary<String, String> = ["firstName": first, "userName": user]
                    print("yoyo")
                    DataService.instance.currentUser.child("profile").setValue(fireBaseDict)
                    self.uploadProfileImg()
                    print("yoyoma")
                    
                    self.performSegueWithIdentifier("snapScrollVC", sender: nil)
                })
            })
            
            
        } else{
            alerts("Username", message: "Username must be at least 6 characters")
        }
    }
    
    @IBAction func photoLibBtn(sender: AnyObject){
        self.presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraBtn(sender: AnyObject){
        self.presentViewController(cameraTaker, animated: true, completion: nil)
    }
    
    func uploadProfileImg(){
        if myUserImg.image != UIImage(named: "profile"){
            if let picData: NSData = UIImageJPEGRepresentation(myUserImg.image!, 0.3){
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
//        self.view.removeGestureRecognizer(tap)
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
//        self.view.addGestureRecognizer(tap)///////////////////////////////////////////////////////////////////
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
            myUserImg.image = image
            hideCameraBtns()
            makeProfilePicRound()
        } else{
            imgPicker.dismissViewControllerAnimated(true, completion: nil)
            myUserImg.image = image
            hideCameraBtns()
            makeProfilePicRound()
        }
    }
    
    func makeProfilePicRound(){
        if myUserImg.image != UIImage(named: "profile"){
            myUserImg.contentMode = UIViewContentMode.ScaleAspectFill
            myUserImg.layer.cornerRadius = (myUserImg.frame.height) / 2
            myUserImg.clipsToBounds = true
        }
    }
    
    func alerts(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func popBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }

}






