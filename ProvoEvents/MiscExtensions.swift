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

extension UIView{
    
    func addConstraintWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))       
    }
}


extension NSMutableAttributedString{
    
    func setLink(text: String, link: String){
        let findString = self.mutableString.rangeOfString(text)
        if findString.location != NSNotFound{
            self.addAttribute(NSLinkAttributeName, value: link, range: findString)
        }
    }
}

extension String{
    
    func indexOf(string: String) -> String.Index?{
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex
    }
}

extension UIColor{
    func boilerPlateColor(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor{
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
    }
}