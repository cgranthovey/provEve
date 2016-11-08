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
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        layer.shadowOffset = CGSizeMake(0, 0)
        clipsToBounds = false
    }
}
