//
//  NVActivityIndicatorViewable.swift
//  NVActivityIndicatorViewDemo
//
//  Created by Basem Emara on 5/26/16.
//  Copyright © 2016 Nguyen Vinh. All rights reserved.
//

import UIKit

public protocol NVActivityIndicatorViewable { }

public extension NVActivityIndicatorViewable where Self: UIViewController {

    fileprivate var activityRestorationIdentifier: String {
        return "NVActivityIndicatorViewContainer"
    }

    /**
     Create a activity indicator view with specified frame, type, color and padding and start animation.
     
     - parameter frame: view's frame.
     - parameter type: animation type, value of NVActivityIndicatorType enum. Default type is BallSpinFadeLoader.
     - parameter color: color of activity indicator view. Default color is white.
     - parameter padding: view's padding. Default padding is 0.
     */
    public func startActivityAnimating(_ message: String? = nil, type: NVActivityIndicatorType? = nil, color: UIColor? = nil, padding: CGFloat? = nil) {
        let activityContainer: UIView = UIView(frame: view.bounds)
        activityContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityContainer.restorationIdentifier = activityRestorationIdentifier
        
        let width = activityContainer.frame.size.width / 3
        let height = width
        
        let activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: width, height: height),
            type: type,
            color: color,
            padding: padding)
        activityIndicatorView.center = activityContainer.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimation()
        activityContainer.addSubview(activityIndicatorView)
        
        if let message = message, !message.isEmpty {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
            label.center = CGPoint(
                x: activityIndicatorView.center.x,
                y: activityIndicatorView.center.y + height)
            label.textAlignment = .center
            label.text = message
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = activityIndicatorView.color
            activityContainer.addSubview(label)
        }
        
        view.addSubview(activityContainer)
    }

    /**
     Stop animation and remove from view hierarchy.
     */
    public func stopActivityAnimating() {
        for item in view.subviews
            where item.restorationIdentifier == activityRestorationIdentifier {
                item.removeFromSuperview()
        }
    }
    
}
