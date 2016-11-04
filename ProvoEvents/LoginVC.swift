//
//  ViewController.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/14/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//


import UIKit
import FirebaseAuth
class LoginVC: GeneralVC, UITextFieldDelegate {

    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var emailField: LoginTextField!
    
    var imgView: UIImageView!
    var preView: UIView!
    
    var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        do{
//         try FIRAuth.auth()?.signOut()
//            print("sign out")
//        } catch {
//            print("could not sign out")
//        }

        

        
        print("yo")
        preView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        preView.backgroundColor = UIColor(red: 3/255.0, green: 169/255.0, blue: 244.0/255.0, alpha: 1.0)
        self.view.addSubview(preView)
        
        

            print("connected to internet")
            
            
            passwordField.delegate = self
            emailField.delegate = self
            
            checkForUID()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.removeFirstResponder))
            self.view.addGestureRecognizer(tap)
            
            passwordField.clearsOnBeginEditing = false
            emailField.clearsOnBeginEditing = false
            
            
            
            //  backView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            //   self.view.addSubview(backView)
            let topColor = UIColor(red: 255/255, green: 87/255, blue: 34/255, alpha: 1.0)
            let bottomColor = UIColor(red: 230/255, green: 74/255, blue: 25/255, alpha: 1.0)
            let gl = CAGradientLayer()
            gl.colors = [topColor, bottomColor]
            gl.locations = [0, 1]
            self.view.layer.addSublayer(gl)
    }
    
    
    
    

    
    func checkForUID(){
        print("tigger1")
        if FIRAuth.auth()?.currentUser != nil{
            print("2")
            print(FIRAuth.auth()?.currentUser?.uid)
            //           UIView.setAnimationsEnabled(false)
            checkForUserName()
            return
        } else{
            print("3")
            UIView.animateWithDuration(0.5, animations: {
                self.preView.alpha = 0
                }, completion: { (true) in
                    self.preView.removeFromSuperview()
                    self.checkForInternet()
                    
            })
        }
        
        

        
    }
    
    
    
    func checkForUserName(){
        
//        DataService.instance.currentUser.observeSingleEventOfType(.Value, withBlock: { (snashot) in
//            <#code#>
//            }) { (error) in
//                if
//        }
//        
        DataService.instance.currentUser.observeSingleEventOfType(.Value, withBlock: { (snapshot, error) in
            print("5")
            if let snap = snapshot.value as? String{
                print("dog")
                self.performSegueWithIdentifier("createUserInfoVC", sender: nil)
            } else{
                print("kitten")
                print(snapshot)
                self.performSegueWithIdentifier("snapScrollVC", sender: nil)
            }
        })
    }
    
    func checkForInternet(){
        if !Reachability.isConnectedToNetwork(){
            let notConnectedView = NoConnectionView()
            notConnectedView.showNoConnectionView(self.view)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createUserInfoVC"{
            if let vc = segue.destinationViewController as? CreateUserInfoVC{
                vc.preventPopVC = true
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
                self.performSegueWithIdentifier("snapScrollVC", sender: nil)
                self.loadingView.cancelSpinnerAndDarkView(nil)
                print("logged in!")
            })
            

            
        } else{
            alerts("Username and Password Required", message: "You must enter a username and password.")
        }
    }
    
    func help(){
        print("help")
    }

    func alerts(title: String, message: String){
        loadingView.cancelSpinnerAndDarkView(nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

