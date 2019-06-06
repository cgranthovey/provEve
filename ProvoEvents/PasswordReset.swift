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
        let tap = UITapGestureRecognizer(target: self, action: #selector(PasswordReset.removeFirstResponder))
        self.view.addGestureRecognizer(tap)
    }

    @IBAction func popBack(_ sender: AnyObject){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPasswordBtn(_ sender: AnyObject){
        removeFirstResponder()
        
        if email.text == nil || email.text == ""{
            alerts("Email Required", message: "Enter an email to send a password reset")
        } else{
            passwordResetLoading.showSpinnerView(self.view)
            AuthService.instance.passwordReset(email.text!, onComplete: { (errMsg, data) in
                if errMsg != nil{
                    self.alerts("Error", message: errMsg!)
                } else{
                    DispatchQueue.main.async(execute: {
                        self.passwordResetLoading.cancelSpinnerAndDarkView(nil)
                        self.perform(#selector(PasswordReset.animateMail), with: nil, afterDelay: 0.5)
                    })
                }
            })
        }
    }
    
    var mailOriginalOrigin: CGPoint!
    @objc func animateMail(){
        
        let screenHeigh = self.view.frame.height
        let animationHeight = self.mailImg.frame.height
        let newMailOriginY = screenHeigh - animationHeight - 60
        mailOriginalOrigin = mailImg.frame.origin
        let mailBoxOriginX = self.mailBox.frame.origin.x
        let mailBoxOriginY = self.mailBox.frame.origin.y
        
        UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.mailImg.frame.origin = CGPoint(x: 20, y: newMailOriginY)
            self.mailImg.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { (true) in
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                    self.mailImg.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    self.mailImg.frame.origin = CGPoint(x: mailBoxOriginX + 30, y: mailBoxOriginY + 30)
                    }, completion: { (true) in
                        self.mailImg.isHidden = true
                        let myImg = UIImageView(image: UIImage(named: "checkmark"))
                        myImg.showCheckmarkAnimatedTempImg(self.view, delay: 0.3, remove: true)
                })
        }
    }
    
    func pop(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func removeFirstResponder(){
        email.resignFirstResponder()
    }
    
    func alerts(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
        }
        
        alert.addAction(alertAction)
        OperationQueue.main.addOperation {
            self.passwordResetLoading.cancelSpinnerAndDarkView(nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
