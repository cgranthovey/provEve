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
    
    func showSpinnerView(_ view: UIView){
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        darkView = UIView(frame: rect)
        darkView.backgroundColor = UIColor.black
        darkView.alpha = 0
        view.addSubview(darkView)
        
        spinner.center = darkView.center
        spinner.startAnimating()
        spinner.alpha = 0
        darkView.addSubview(spinner)

        UIView.animate(withDuration: 0.25, animations: {
            self.darkView.alpha = 0.5
            self.spinner.alpha = 1
            }, completion: { (true) in
        }) 
    }
    
    func cancelImediately(){
        self.darkView.alpha = 0.0
        self.spinner.alpha = 0.0
        self.darkView.removeFromSuperview()
        self.spinner.removeFromSuperview()
    }
    
    func cancelSpinnerAndDarkView(_ completionHandler: CompletionHandler?){
        UIView.animate(withDuration: 0.25, animations: {
            self.darkView.alpha = 0.0
            self.spinner.alpha = 0.0
            }, completion: { (true) in
                self.darkView.removeFromSuperview()
                self.spinner.removeFromSuperview()
                if completionHandler != nil{
                    completionHandler!()
                }
        }) 
    }
    
    func successCancelSpin(_ completionHandler: @escaping CompletionHandler){
        UIView.animate(withDuration: 0.25, animations: {
            self.spinner.alpha = 0.0
        }, completion: { (true) in
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            completionHandler()
        }) 
    }
    
    func cancelSpinner(){
        UIView.animate(withDuration: 0.25, animations: { 
            self.spinner.alpha = 0.0
            }, completion: { (true) in
        }) 
    }
}
