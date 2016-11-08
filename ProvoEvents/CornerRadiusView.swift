//
//  CornerRadiusView.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/14/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class CornerRadiusView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 5
        clipsToBounds = true
        
    }
}
