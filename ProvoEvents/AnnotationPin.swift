//
//  AnnotationPin.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/6/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class AnnotationPin: MKPinAnnotationView {

    override func awakeFromNib() {
        tintColor = UIColor.red
        canShowCallout = true
    }
}
