//
//  ShadowView.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/13/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 4
        
        layer.masksToBounds = false
    }
    
}
