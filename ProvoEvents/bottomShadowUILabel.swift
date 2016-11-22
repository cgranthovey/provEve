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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
    }
}
