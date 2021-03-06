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
    
    let loadingView = LoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateEmailPassVC.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
        
        emailField.delegate = self
        passwordField.delegate = self
        verifyPasswordField.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeFirstResponder()
    }

    @IBAction func next(){
        removeFirstResponder()
        if let email = emailField.text, let password = passwordField.text, let passwordV = verifyPasswordField.text, (password.count > 0 && email.count > 0 && passwordV.count > 0){
            
            guard password.count >= 6 else {
                alerts("Minimum Length", message: "Password must be at least 6 characters")
                return
            }
            guard password == passwordV else{
                alerts("Password", message: "Passwords do not match")
                return
            }
            
            loadingView.showSpinnerView(self.view)
            AuthService.instance.createUser(password, email: email, onComplete: { (errMsg, data) in
                guard errMsg == nil else{
                    self.alerts("Error Authenticating", message: errMsg!)
                    return
                }
                AuthService.instance.login(password, email: email, onComplete: { (errMsg, data) in
                    guard errMsg == nil else{
                        self.alerts("Error Authenticating", message: errMsg!)
                        return
                    }
                    DataService.instance.currentUser.setValue("TRUE", withCompletionBlock: { (error, FIRDatabaseReference) in
                        if error != nil{
                            self.alerts("Error", message: "There was an error uploading your info")
                        } else{
                            self.loadingView.successCancelSpin({
                                self.performSegue(withIdentifier: "CreateUserInfoVC", sender: nil)
                            })
                        }
                    })
                })
            })
        } else {
            alerts("Username and Password Required", message: "You must enter a username and password.")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func removeFirstResponder(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        verifyPasswordField.resignFirstResponder()
    }
    
    func alerts(_ title: String, message: String){
        self.loadingView.cancelSpinnerAndDarkView(nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func popBack(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
