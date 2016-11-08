//
//  GeneralVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/17/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class GeneralVC: UIViewController {

    var swipeRight: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GeneralVC.swipePopBack))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func swipePopBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }

    func generalAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
