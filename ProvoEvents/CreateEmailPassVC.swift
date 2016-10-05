//
//  createEmailPassVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/16/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class CreateEmailPassVC: GeneralVC, UITextFieldDelegate {

    @IBOutlet weak var emailField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var verifyPasswordField: LoginTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateEmailPassVC.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
        
        emailField.delegate = self
        passwordField.delegate = self
        verifyPasswordField.delegate = self
        
    }

    override func viewWillDisappear(animated: Bool) {
        removeFirstResponder()
    }

    
    @IBAction func next(){
        if let email = emailField.text, let password = passwordField.text, let passwordV = verifyPasswordField.text where (password.characters.count > 0 && email.characters.count > 0 && passwordV.characters.count > 0){
            
            guard password.characters.count >= 6 else {
                alerts("Minimum Length", message: "Password must be at least 6 characters")
                return
            }
            guard password == passwordV else{
                alerts("Password", message: "Passwords do not match")
                return
            }
            let userInfoDict = ["email": email, "password": password]
            performSegueWithIdentifier("CreateUserInfoVC", sender: userInfoDict)
            
        } else {
            alerts("Username and Password Required", message: "You must enter a username and password.")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func removeFirstResponder(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        verifyPasswordField.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateUserInfoVC"{
            if let newVC = segue.destinationViewController as? CreateUserInfoVC{
                if let send = sender as? Dictionary<String, AnyObject>{
                    newVC.userInfoDict = send
                }
            }
        }
    }
    
    func alerts(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func popBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
