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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard FIRAuth.auth()?.currentUser != nil else{
            print("there is no current user")
            return
        }
    }
    
    @IBAction func loginBtn(sender: AnyObject){
        
    }

}

