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
    
    @IBOutlet weak var mailImg: UIImageView!
    @IBOutlet weak var mailBox: UIImageView!
    var passwordResetLoading: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordResetLoading = LoadingView()
        email.delegate = self
        var tap = UITapGestureRecognizer(target: self, action: #selector(PasswordReset.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
    }

    @IBAction func popBack(sender: AnyObject){
        animateMail()
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func resetPasswordBtn(sender: AnyObject){
        removeFirstResponder()
        
        if email.text == nil || email.text == ""{
            alerts("Email Required", message: "Enter an email send a password reset")
        } else{
            passwordResetLoading.showSpinnerView(self.view)
            AuthService.instance.passwordReset(email.text!, onComplete: { (errMsg, data) in
                if errMsg != nil{
                    self.alerts("Error", message: errMsg)
                } else{
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.passwordResetLoading.successCancelSpin({
                            let myImg = UIImageView(image: UIImage(named: "checkmark"))
                            myImg.showCheckmarkAnimatedTempImg(self.view)
                            self.performSelector(#selector(PasswordReset.pop), withObject: self, afterDelay: 1.0)
                        })
                    })
                }
            })
        }
    }
    
    func animateMail(){
        
        var mailOriginX = self.mailImg.frame.origin.x
        var mailOriginY = self.mailImg.frame.origin.y
        
        var screenHeigh = self.view.frame.height
        var animationHeight = self.mailImg.frame.height
        let newMailOriginY = screenHeigh - animationHeight - 60
        
        var mailBoxOriginX = self.mailBox.frame.origin.x
        var mailBoxOriginY = self.mailBox.frame.origin.y
        
        UIView.animateWithDuration(1.0, delay: 0, options: .CurveEaseInOut, animations: {
            
            self.mailImg.frame.origin = CGPoint(x: 20, y: newMailOriginY)
            self.mailImg.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }) { (true) in
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                    self.mailImg.transform = CGAffineTransformMakeScale(0.5, 0.5)
                    self.mailImg.frame.origin = CGPoint(x: mailBoxOriginX + 30, y: mailBoxOriginY + 30)
                    }, completion: { (true) in
                        
                })
        }
    }
    
    func pop(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func removeFirstResponder(){
        email.resignFirstResponder()
    }
    
    func alerts(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
            print("woot")
        }
        
        alert.addAction(alertAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.passwordResetLoading.cancelSpinnerAndDarkView()
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
