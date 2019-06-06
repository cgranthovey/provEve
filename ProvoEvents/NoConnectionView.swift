//
//  NoConnectionView.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 11/2/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

protocol noConnectionGotIt {
    func dismissNoConnectionView()
}

class NoConnectionView: NSObject, noConnectionGotIt {
    
    var darkView = UIView()
    var noConnectionView = NoInternetView()
    
    override init() {
        super.init()
    }
    
    func showNoConnectionView(_ view: UIView){
        let frame = CGRect(x: 0, y: 0, width: 275, height: 155)
        noConnectionView = NoInternetView(frame: frame)
        noConnectionView.center = view.center
        noConnectionView.layer.cornerRadius = 5.0
        noConnectionView.layer.masksToBounds = true
        noConnectionView.alpha = 0
        noConnectionView.delegate = self
        
        darkView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        darkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        darkView.alpha = 0
        
        view.addSubview(darkView)
        view.addSubview(noConnectionView)
        view.bringSubviewToFront(noConnectionView)
        
        UIView.animate(withDuration: 0.3, delay: 0.35, options: .curveEaseIn, animations: {
            self.darkView.alpha = 0.6
            self.noConnectionView.alpha = 1.0
        }) { (true) in
        }
    }
    
    func dismissNoConnectionView(){
        UIView.animate(withDuration: 0.25, animations: {
            self.noConnectionView.alpha = 0
            self.darkView.alpha = 0
            }, completion: { (true) in
                self.noConnectionView.removeFromSuperview()
                self.darkView.removeFromSuperview()
        }) 
    }
}
