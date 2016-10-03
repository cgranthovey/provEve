//
//  UIButtonExtension.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/30/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {
    
    func changeImageAnimated(image: UIImage?) {
        guard let imageView = self.imageView, currentImage = imageView.image, newImage = image else {
            return
        }
//        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
//        crossFade.duration = 0.3
//        crossFade.fromValue = currentImage.CGImage
//        crossFade.toValue = newImage.CGImage
//        crossFade.removedOnCompletion = false
//        crossFade.fillMode = kCAFillModeForwards
//        imageView.layer.addAnimation(crossFade, forKey: "animateContents")
//        
        userInteractionEnabled = false
        UIView.animateWithDuration(0.5, animations: {
            self.alpha = 0
            }) { (true) in
                self.setImage(newImage, forState: .Normal)
                UIView.animateWithDuration(0.5, animations: {
                    self.alpha = 1
                }) { (true) in
                    self.userInteractionEnabled = true
                }
        }
    }
}
