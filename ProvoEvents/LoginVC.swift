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

class LoginVC: GeneralVC, UITextFieldDelegate, NSURLConnectionDelegate {

    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var emailField: LoginTextField!
    
    var imgView: UIImageView!
    var preView: UIView!
    var backView: UIView!
    var connectionBool: Bool!
    
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
        preView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        preView.backgroundColor = UIColor(red: 3/255.0, green: 169/255.0, blue: 244.0/255.0, alpha: 1.0)
        self.view.addSubview(preView)
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
        if FIRAuth.auth()?.currentUser != nil{
            checkForUserName()
            return
        } else{
            UIView.animateWithDuration(0.5, animations: {
                self.preView.alpha = 0
                }, completion: { (true) in
                    self.preView.removeFromSuperview()
                    if self.connectionBool == false{
                        let x = NoConnectionView()
                        x.showNoConnectionView(self.view)
                    }
                })
        }
    }
    
    func checkForUserName(){
        DataService.instance.currentUser.child("profile").child("userName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            print("snapshot \(snapshot)")
            if (snapshot.value as? String) != nil{
                print("has username")
                self.performSegueWithIdentifier("snapScrollVC", sender: nil)
            } else{
                print("no username")
                self.performSegueWithIdentifier("createUserInfoVC", sender: nil)
            }
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
                self.resignFirstResponder()
                self.checkForUserName()
                self.loadingView.cancelSpinnerAndDarkView(nil)
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
