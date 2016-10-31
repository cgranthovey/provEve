//
//  LoadingView.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/19/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class LoadingView: NSObject {
    
    var darkView = UIView()
    var spinner = UIActivityIndicatorView()
    
    typealias CompletionHandler = () -> Void
    
    
    
    func showSpinnerView(view: UIView){
        
        let rect = CGRectMake(0, 0, view.frame.width, view.frame.height)
        darkView = UIView(frame: rect)
        darkView.backgroundColor = UIColor.blackColor()
        darkView.alpha = 0
        view.addSubview(darkView)
        
        spinner.center = darkView.center
        spinner.startAnimating()
        spinner.alpha = 0
        darkView.addSubview(spinner)

        
        UIView.animateWithDuration(0.25, animations: {
            self.darkView.alpha = 0.5
            self.spinner.alpha = 1
            }) { (true) in
                
        }
        
    }
    
    func cancelImediately(){
        
        self.darkView.alpha = 0.0
        self.spinner.alpha = 0.0
        self.darkView.removeFromSuperview()
        self.spinner.removeFromSuperview()
    }
    
    func cancelSpinnerAndDarkView(){
        UIView.animateWithDuration(0.25, animations: { 
            self.darkView.alpha = 0.0
            self.spinner.alpha = 0.0
            }) { (true) in
                self.darkView.removeFromSuperview()
                self.spinner.removeFromSuperview()
        }
    }
    
    func successCancelSpin(completionHandler: CompletionHandler){
        UIView.animateWithDuration(0.25, animations: {
            print("wine1")
            self.spinner.alpha = 0.0
        }) { (true) in
            print("wine2")
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
//            let imgView = UIImageView(image: Constants.instance.successImg)
//            imgView.showCheckmarkAnimatedTempImg(self.darkView)
            completionHandler()
        }
    }
    
    func cancelSpinner(){
        UIView.animateWithDuration(0.25, animations: { 
            self.spinner.alpha = 0.0
            }) { (true) in
                
        }
    }
    
    
}
