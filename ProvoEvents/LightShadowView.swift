//
//  LightShadowView.swift
//  Ibento
//
//  Created by Chris Hovey on 11/10/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class LightShadowView: UIView {

    override func awakeFromNib() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
        
        layer.masksToBounds = false
    }

}
