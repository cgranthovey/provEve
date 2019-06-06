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
    
    func changeImageAnimated(_ image: UIImage?) {
        guard let imageView = self.imageView, let _ = imageView.image, let newImage = image else {
            return
        }

        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            }, completion: { (true) in
                self.setImage(newImage, for: UIControl.State())
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = 1
                }, completion: { (true) in
                    self.isUserInteractionEnabled = true
                }) 
        }) 
    }
}

extension MKCoordinateRegion{

    func isRegionValid() -> Bool{
        
        let centerLatDegrees = self.center.latitude
        let topLatDegrees = centerLatDegrees + self.span.latitudeDelta / 2
        let bottomLatDegrees = centerLatDegrees - self.span.latitudeDelta / 2
        let centerLongDegrees = self.center.longitude
        let centerTop = CLLocationCoordinate2D(latitude: topLatDegrees, longitude: centerLongDegrees)
        let centerBottom = CLLocationCoordinate2D(latitude: bottomLatDegrees, longitude: centerLongDegrees)
        
        if CLLocationCoordinate2DIsValid(centerTop) && CLLocationCoordinate2DIsValid(centerBottom){
            return true
        } else{
            return false
        }
    }
}

extension UIView{
    
    func addConstraintWithFormat(_ format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))       
    }
}


extension NSMutableAttributedString{
    
    func setLink(_ text: String, link: String){
        let findString = self.mutableString.range(of: text)
        if findString.location != NSNotFound{
            self.addAttribute(NSAttributedString.Key.link, value: link, range: findString)
        }
    }
}

extension String{
    
    func indexOf(_ string: String) -> String.Index?{
        return range(of: string, options: .literal, range: nil, locale: nil)?.lowerBound
    }
}

extension UIColor{
    func boilerPlateColor(_ red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor{
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
    }
}
