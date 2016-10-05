//
//  SettingsVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/4/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsVC: GeneralVC {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logOutBtn(sender: AnyObject){
        
        do {
            try FIRAuth.auth()?.signOut()
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.navigationController?.popToViewController((LoginVC.self as? UIViewController)!, animated: true)
        } catch {
            var alert = UIAlertController(title: "Error", message: "There was an error logging out, please try again soon", preferredStyle: .Alert)
            var alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(alertAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtn(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
}