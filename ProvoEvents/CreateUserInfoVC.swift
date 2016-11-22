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
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func checkForInternet(){
        if isConnected == false{
            let x = NoConnectionView()
            x.showNoConnectionView(self.view)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        cameraTaker.sourceType = .photoLibrary  //change to camera later
    }
    
    func hideCameraBtns(){
        photoLibBtnOutlet.isHidden = true
        cameraBtnOutlet.isHidden = true
        screenViewForCameraOutlets.isHidden = true
        photoLibBtnOutlet.alpha = 0
        cameraBtnOutlet.alpha = 0
        screenViewForCameraOutlets.alpha = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func imageCompletedPop() {
        showImgOptions()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " "{
            return false
        }
        return true
    }
    
    @IBAction func finished(_ sender: AnyObject){
        if let user = userName.text, (user.characters.count > 2){
            loadingView.showSpinnerView(self.view)
            let fireBaseDict: Dictionary<String, String>!

            if let first = firstName.text{
                fireBaseDict = ["firstName": first, "userName": user]
            } else{
                fireBaseDict = ["userName": user]
            }
            
            print("user \(user)")
            
            
            DataService.instance.usernamesRef.queryOrdered(byChild: "UserID").queryEqual(toValue: user).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snap = snapshot.value as? Dictionary<String, AnyObject>{
                    self.alerts("Username", message: "This username has already been choosen")
                } else{
                    
                    let dict: Dictionary<String, AnyObject> = ["/User/\((FIRAuth.auth()?.currentUser?.uid)!)/profile": fireBaseDict as AnyObject, "/Usernames/\(DataService.instance.usernamesRef.childByAutoId().key)/UserID" : "\(user)" as AnyObject]
                    DataService.instance.mainRef.updateChildValues(dict, withCompletionBlock: { (error, FIRDatabaseReference) in
                        if error != nil{
                            self.alerts("Error", message: "There was an error uploading your info")
                        } else{
                            self.uploadProfileImg()
                            
                            // setting username in nsdefualts
                            let prefs = UserDefaults.standard
                            let uid = FIRAuth.auth()?.currentUser?.uid
                            prefs.setValue(user, forKey: "\(uid)Username")
                            
                            self.loadingView.successCancelSpin({
                                self.performSegue(withIdentifier: "snapScrollVC", sender: nil)
                            })
                        }
                    })
                }
            })
        } else{
            alerts("Username", message: "Username must be at least 3 characters")
        }
    }
    
    @IBAction func photoLibBtn(_ sender: AnyObject){
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraBtn(_ sender: AnyObject){
        self.present(cameraTaker, animated: true, completion: nil)
    }
    
    func uploadProfileImg(){
        if userImg.image != UIImage(named: "profile"){
            if let picData: Data = UIImageJPEGRepresentation(userImg.image!, 0.3){
                let imgName = "\(UUID().uuidString).jpg"
                let ref = DataService.instance.imgStorageRefData.child(imgName)
                let task = ref.put(picData, metadata: nil, completion: { (metaData, err) in
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
        screenViewForCameraOutlets.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.screenViewForCameraOutlets.alpha = 0.65
            }, completion: { (true) in
                self.photoLibBtnOutlet.isHidden = false
                self.cameraBtnOutlet.isHidden = false
                UIView.animate(withDuration: 0.4, animations: {
                    self.photoLibBtnOutlet.alpha = 1.0
                    self.cameraBtnOutlet.alpha = 1.0
                    }, completion: { (true) in
                        let tapAnywhereButButton = UITapGestureRecognizer()
                        tapAnywhereButButton.addTarget(self, action: #selector(CreateUserInfoVC.removeCameraPhotoLibOptions))
                        self.screenViewForCameraOutlets.addGestureRecognizer(tapAnywhereButButton)
                })
        }) 
    }
    
    func removeCameraPhotoLibOptions(){
        UIView.animate(withDuration: 0.6, animations: {
            self.screenViewForCameraOutlets.alpha = 0
            self.photoLibBtnOutlet.alpha = 0
            self.cameraBtnOutlet.alpha = 0
            }, completion: { (true) in
                self.screenViewForCameraOutlets.isHidden = true
                self.photoLibBtnOutlet.isHidden = true
                self.cameraBtnOutlet.isHidden = true
        }) 
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if picker.sourceType == UIImagePickerControllerSourceType.camera{
            cameraTaker.dismiss(animated: true, completion: nil)
            userImg.image = image
            hideCameraBtns()
            makeProfilePicRound()
        } else{
            imgPicker.dismiss(animated: true, completion: nil)
            userImg.image = image
            hideCameraBtns()
            makeProfilePicRound()
        }
    }
    
    func makeProfilePicRound(){
        if userImg.image != UIImage(named: "profile"){
            userImg.contentMode = UIViewContentMode.scaleAspectFill
            userImg.layer.cornerRadius = (userImg.frame.height) / 2
            userImg.clipsToBounds = true
        }
    }
    
    func alerts(_ title: String, message: String){
        loadingView.cancelSpinnerAndDarkView(nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
