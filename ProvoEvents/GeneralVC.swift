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
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func swipePopBack(){
        _ = self.navigationController?.popViewController(animated: true)
    }

    func generalAlert(_ title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
