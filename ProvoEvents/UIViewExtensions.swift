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
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}){
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: { 
            self.alpha = 1
            }, completion: completion)
    }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}){
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: { 
            self.alpha = 0
            }, completion: completion)
    }
}
