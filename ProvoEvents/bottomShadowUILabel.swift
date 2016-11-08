//
//  bottomShadowUILabel.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/14/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class bottomShadowUILabel: UILabel {

    override func awakeFromNib() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSizeMake(0, 3)
    }
}
