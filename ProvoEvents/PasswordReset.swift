//
//  PasswordReset.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/6/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class PasswordReset: GeneralVC, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.delegate = self
        var tap = UITapGestureRecognizer(target: self, action: #selector(PasswordReset.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
    }

    @IBAction func popBack(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func resetPasswordBtn(sender: AnyObject){
        removeFirstResponder()
        
        if email.text == nil || email.text == ""{
            alerts("Email Required", message: "Enter an email send a password reset")
        } else{
            AuthService.instance.passwordReset(email.text!, onComplete: { (errMsg, data) in
                if errMsg != nil{
                    self.alerts("Error", message: errMsg)
                } else{
                    let myImg = UIImageView(image: UIImage(named: "checkmark"))
                    myImg.showCheckmarkAnimatedTempImg(self.view)
                }
            })
        }
    }
    
    func removeFirstResponder(){
        email.resignFirstResponder()
    }
    
    func alerts(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        
        alert.addAction(alertAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
