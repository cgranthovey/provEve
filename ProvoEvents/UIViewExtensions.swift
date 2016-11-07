//
//  UIViewExtensions.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/26/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}){
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: { 
            self.alpha = 1
            }, completion: completion)
    }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}){
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: { 
            self.alpha = 0
            }, completion: completion)
    }
}