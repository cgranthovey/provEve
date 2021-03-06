//
//  setCancelColorController.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 11/1/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class setCancelColorController: LoginButton {

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(setCancelColorController.onTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(setCancelColorController.onTouchUpOutside), for: .touchUpOutside)
        
        if self.titleLabel?.text == "SET"{
            backgroundColor = UIColor().boilerPlateColor(239, green: 108, blue: 0)
        } else if self.titleLabel?.text == "CANCEL"{
            backgroundColor = UIColor().boilerPlateColor(194, green: 24, blue: 91)
        }
    }
    
    @objc func onTouchDown(){
        if self.currentTitle == "SET"{
            backgroundColor = UIColor().boilerPlateColor(230, green: 81, blue: 0)
        } else if self.currentTitle == "CANCEL"{
            backgroundColor = UIColor().boilerPlateColor(136, green: 14, blue: 79)
        }
    }
    
    @objc func onTouchUpOutside(){
        if self.currentTitle == "SET"{
            backgroundColor = UIColor().boilerPlateColor(239, green: 108, blue: 0)
        } else if self.currentTitle == "CANCEL"{
            backgroundColor = UIColor().boilerPlateColor(194, green: 24, blue: 91)
        }
    }
}
