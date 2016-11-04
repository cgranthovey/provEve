//
//  SettingsVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/4/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth

class SettingsVC: GeneralVC, UITextFieldDelegate, yesSelectedProtocol {

    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    
    var holdOriginalName: String!
    let yesNo = yesNoLauncher()

    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTF.delegate = self
        
        yesNo.delegate = self
        
        setUpUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsVC.tapRemoveKeyboard))
        self.view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsVC.animateTopStackView), name: UIKeyboardWillShowNotification, object: nil)
        

        self.topStack.alpha = 0
        topStack.hidden = true
        // Do any additional setup after loading the view.
        
        
        
    }
    
    func tapRemoveKeyboard(){
        print("yep")
        firstNameTF.resignFirstResponder()
    }

    func setUpUI(){
        if let currUser = Constants.instance.currentUser{
            userNameTF.text = currUser.userName
            firstNameTF.text = currUser.firstName
            holdOriginalName = currUser.firstName
        }
    }

    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBAction func cancel(sender: AnyObject){
        firstNameTF.text = holdOriginalName
        
        dismissTopStack()
    }
    
    @IBAction func applyBtn(sender: AnyObject){
        textColorChange()

        dismissTopStack()
        let firstName: String!
        if firstNameTF.text == nil{
            firstName = ""
        } else{
            firstName = firstNameTF.text
        }
        holdOriginalName = firstName
        
        DataService.instance.currentUserProfile.child(Constants.instance.FirConsFirstName).setValue(firstName)
        Constants.instance.initCurrentUser()
    }
    func dismissTopStack(){
        self.view.endEditing(true)

        UIView.animateWithDuration(0.25, animations: {
            self.topStack.alpha = 0
        }) { (true) in
            self.topStack.hidden = true
            self.logoutTopConstraint.constant = self.logoutTopConstraint.constant - 40
            
            UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: {
                self.view.layoutIfNeeded()
                
                }, completion: { (true) in
                    self.animationShouldBeCalled = true
            })
        }
    }
    
    func textColorChange(){
        UIView.transitionWithView(firstNameTF, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.firstNameTF.textColor = UIColor.greenColor()

            }) { (true) in
                
                UIView.transitionWithView(self.firstNameTF, duration: 0.45, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    
                    }, completion: { (true) in
                        UIView.transitionWithView(self.firstNameTF, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                            self.firstNameTF.textColor = UIColor.blackColor()
                            }, completion: nil)
                })
        }
    }
    
    @IBAction func logOutBtn(sender: AnyObject){
        yesNo.showDeleteView(self.view, lblText: "Log out?")
    }
    
    func yesPressed() {
        print("here")
        do {
            print("next")
            try FIRAuth.auth()?.signOut()
            self.navigationController?.popToRootViewControllerAnimated(true)
        } catch {
            print("uhh oh")
            let alert = UIAlertController(title: "Error", message: "There was an error logging out, please try again soon", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(alertAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtn(sender: AnyObject){
        print("back")
        self.navigationController?.popViewControllerAnimated(true)
    }


    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func creditsVC(sender: AnyObject){
        performSegueWithIdentifier("CreditsVC", sender: nil)
    }

    @IBOutlet var logoutTopConstraint: NSLayoutConstraint!
    
    var animationShouldBeCalled = true
    
    func animateTopStackView(){
        print("here")
        if animationShouldBeCalled{
            animationShouldBeCalled = false
            self.logoutTopConstraint.constant = self.logoutTopConstraint.constant + 40
            self.topStack.hidden = false
            
            UIView.animateWithDuration(3.15, delay: 0.2, options: .CurveEaseInOut, animations: {
                self.topStack.alpha = 1
                
                }, completion: nil)
            
            
            UIView.animateWithDuration(3.15, delay: 0.0, options: .CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
                }) { (true) in
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}