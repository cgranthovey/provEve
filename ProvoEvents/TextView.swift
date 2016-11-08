//
//  TextView.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/19/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
@IBDesignable

class TextView: UITextView{
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor!{
        didSet{
            layer.borderColor = borderColor.CGColor
        }
    }
}