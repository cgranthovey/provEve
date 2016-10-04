//
//  GeneralShadowView.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/3/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class GeneralShadowView: UIView {

    override func awakeFromNib() {
        layer.shadowColor = UIColor.lightGrayColor().CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSizeMake(0, 4)
        
        clipsToBounds = false
    }

}
