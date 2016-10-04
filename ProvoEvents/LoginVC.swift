//
//  ViewController.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/14/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth
class LoginVC: UIViewController {

    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var emailField: LoginTextField!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backImg: UIImageView!
    var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("diaper")
        guard FIRAuth.auth()?.currentUser != nil else{
            print("there is no current user")
            return
        }
        
        
        passwordField.clearsOnBeginEditing = false
        emailField.clearsOnBeginEditing = false
        
        self.backView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.blur))
        self.backView.addGestureRecognizer(tap)
        
        imgView = UIImageView()
        imgView.frame = backImg.frame
        imgView.image = UIImage(named: "mtgood")
        view.addSubview(imgView)
        view.sendSubviewToBack(imgView)
        imgView.alpha = 0
    }
    
    @IBAction func loginBtn(sender: AnyObject){
        if let email = emailField.text, let password = passwordField.text where (email.characters.count > 0 && password.characters.count > 0){
            guard password.characters.count >= 6 else{
                alerts("Password", message: "Password must be at least 6 characters")
                return
            }

            AuthService.instance.login(password, email: email, onComplete: { (errMsg, data) in
                guard errMsg == nil else{
                    self.alerts("Error Authenticating", message: errMsg)
                    return
                }
                NSNotificationCenter.defaultCenter().postNotificationName("loggedInLoadData", object: nil, userInfo: nil)
                self.navigationController?.popViewControllerAnimated(true)
                print("logged in!")
            })
            

            
        } else{
            alerts("Username and Password Required", message: "You must enter a username and password.")
        }
    }
    
    func help(){
        print("help")
    }
    
    func blur(){

        UIView.animateWithDuration(0.9, animations: {
            if self.imgView.alpha == 0{
                self.imgView.alpha = 1
                self.backImg.alpha = 0
            } else{
                self.imgView.alpha = 0
                self.backImg.alpha = 1
            }
            }, completion: nil)
        
    }

    func alerts(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

