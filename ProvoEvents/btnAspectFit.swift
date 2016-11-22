//
//  btnAspectFit.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/29/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class btnAspectFit: UIButton {

    override func awakeFromNib() {
        self.imageView?.contentMode = .scaleAspectFit
    }
}
