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
    
    func showNoConnectionView(view: UIView){
print("antArmy3")
        let frame = CGRectMake(0, 0, 275, 155)
        noConnectionView = NoInternetView(frame: frame)
        noConnectionView.center = view.center
        print("MYVIEW \(view)")
        print("MYVIEWCENTER \(view.center)")
        noConnectionView.layer.cornerRadius = 5.0
        noConnectionView.layer.masksToBounds = true
        noConnectionView.alpha = 0
        
        noConnectionView.delegate = self
        darkView = UIView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        darkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        darkView.alpha = 0
        print("antArmy4")
        view.addSubview(darkView)
        view.addSubview(noConnectionView)
        view.bringSubviewToFront(noConnectionView)
        
        UIView.animateWithDuration(0.3, delay: 0.35, options: .CurveEaseIn, animations: {
            self.darkView.alpha = 0.6
            self.noConnectionView.alpha = 1.0
            print("antArmy5")
        }) { (true) in
        }
    }
    
    func dismissNoConnectionView(){
        print("dismissCalled")
        UIView.animateWithDuration(0.25, animations: { 
            self.noConnectionView.alpha = 0
            self.darkView.alpha = 0
            }) { (true) in
                self.noConnectionView.removeFromSuperview()
                self.darkView.removeFromSuperview()
        }
    }
}
