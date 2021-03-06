//
//  UIImageViewExtension.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/20/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    func roundCornersForAspectFit(_ radius: CGFloat){
        if let image = self.image {
            
            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height
            
            var drawingRect : CGRect = self.bounds
            
            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            }else{
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    func showCheckmarkAnimatedTempImg(_ supView: UIView, delay: TimeInterval = 0.1, remove: Bool = true){
        self.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        self.contentMode = .scaleAspectFit
        self.center = supView.center
        self.center.y = self.center.y + 50
        supView.addSubview(self)
        supView.bringSubviewToFront(self)
        self.alpha = 0

        UIView.animate(withDuration: 0.3, delay: delay, usingSpringWithDamping: 2.0, initialSpringVelocity: 3.0, options: .curveEaseIn, animations: {
            self.alpha = 1
            self.center.y = self.center.y - 75
        }) { (true) in
            if remove{
                UIView.animate(withDuration: 0.3, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
                    self.alpha = 0
                    }, completion: { (true) in
                        self.removeFromSuperview()
                })
            }
        }
    }
}
