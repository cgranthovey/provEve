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
        self.addTarget(self, action: #selector(setCancelColorController.onTouchDown), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(setCancelColorController.onTouchUpOutside), forControlEvents: .TouchUpOutside)
        
        if self.titleLabel == "SET"{
            backgroundColor = UIColor().boilerPlateColor(239, green: 108, blue: 0)
        } else if self.titleLabel == "CANCEL"{
            backgroundColor = UIColor().boilerPlateColor(194, green: 24, blue: 91)
        }
    }
    
    func onTouchDown(){
        print("touchDown")
        
        if self.currentTitle == "SET"{
            backgroundColor = UIColor().boilerPlateColor(230, green: 81, blue: 0)

        } else if self.currentTitle == "CANCEL"{
            backgroundColor = UIColor().boilerPlateColor(136, green: 14, blue: 79)
        }
    }
    
    func onTouchUpOutside(){
        print("touch up outside")
        if self.currentTitle == "SET"{
            backgroundColor = UIColor().boilerPlateColor(239, green: 108, blue: 0)

        } else if self.currentTitle == "CANCEL"{
            backgroundColor = UIColor().boilerPlateColor(194, green: 24, blue: 91)
        }
    }

}
