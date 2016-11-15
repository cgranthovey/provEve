//
//  ViewController.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/14/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class LoginVC: GeneralVC, UITextFieldDelegate, NSURLConnectionDelegate {

    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var emailField: LoginTextField!
    
    var imgView: UIImageView!
    var preView: UIView!
    var backView: UIView!
    var connectionBool: Bool!
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPreview()
        passwordField.delegate = self
        emailField.delegate = self
        checkForConnection()
        passwordField.clearsOnBeginEditing = false
        emailField.clearsOnBeginEditing = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
    }
    
    func setUpPreview(){
        let myWaitingFrame = CGRectMake(0, 0, 40, 40)
        activityIndicatorView = NVActivityIndicatorView(frame: myWaitingFrame, type: .BallScale, color: UIColor.whiteColor(), padding: 0)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.alpha = 0
        
        preView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        preView.backgroundColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243.0/255.0, alpha: 1.0)
        self.view.addSubview(preView)
        self.preView.addSubview(activityIndicatorView)
    }
    
    func checkForConnection(){
        ConnectedToInternet.instance1.areWeConnected(self.view, showNoInternetView: false) { (connected) in
            if let connect = connected{
                if  connect{
                    self.connectionBool = true
                } else {
                    self.connectionBool = false
                }
                self.checkForUID()
            }
        }
    }
    
    func checkForUID(){
        if self.connectionBool == true && FIRAuth.auth()?.currentUser != nil{
            UIView.animateWithDuration(0.9) {
                self.activityIndicatorView.startAnimation()
                self.activityIndicatorView.alpha = 1
            }
            checkForUserName()
            return
        } else{
            UIView.animateWithDuration(0.3, animations: { 
                self.activityIndicatorView.alpha = 0
                }, completion: { (true) in
                    UIView.animateWithDuration(0.5, animations: {
                        self.preView.alpha = 0
                        }, completion: { (true) in
                            self.preView.removeFromSuperview()
                            if self.connectionBool == false{
                                let x = NoConnectionView()
                                x.showNoConnectionView(self.view)
                            }
                    })
            })
        }
    }
    
    func checkForUserName(){
        DataService.instance.currentUser.child("profile").child("userName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if (snapshot.value as? String) != nil{
                UIView.animateWithDuration(0.3, animations: {
                    self.activityIndicatorView.alpha = 0
                    }, completion: { (true) in
                        self.performSegueWithIdentifier("snapScrollVC", sender: nil)
                })
            } else{
                UIView.animateWithDuration(0.3, animations: {
                    self.activityIndicatorView.alpha = 0
                    }, completion: { (true) in
                        self.performSegueWithIdentifier("createUserInfoVC", sender: nil)
                })
            }
            self.loadingView.cancelSpinnerAndDarkView(nil)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createUserInfoVC"{
            if let vc = segue.destinationViewController as? CreateUserInfoVC{
                vc.preventPopVC = true
                vc.isConnected = connectionBool
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.preView.removeFromSuperview()
        passwordField.text = ""
        emailField.text = ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeFirstResponder()
    }
    
    func removeFirstResponder(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    let loadingView = LoadingView()
    
    @IBAction func loginBtn(sender: AnyObject){
        //self.resignFirstResponder()
        self.view.endEditing(true)

        if let email = emailField.text, let password = passwordField.text where (email.characters.count > 0 && password.characters.count > 0){
            guard password.characters.count >= 6 else{
                alerts("Password", message: "Password must be at least 6 characters")
                return
            }
            loadingView.showSpinnerView(self.view)
            AuthService.instance.login(password, email: email, onComplete: { (errMsg, data) in
                guard errMsg == nil else{
                    self.alerts("Error Authenticating", message: errMsg)
                    return
                }
                self.checkForUserName()
            })
        } else{
            alerts("Username and Password Required", message: "You must enter a username and password.")
        }
    }

    func alerts(title: String, message: String){
        loadingView.cancelSpinnerAndDarkView(nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
