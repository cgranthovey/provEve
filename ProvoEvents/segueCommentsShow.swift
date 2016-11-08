//
//  segueCommentsShow.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/15/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class segueCommentsShow: UIStoryboardSegue {
    
    override func perform() {

        let sourceVC = self.sourceViewController
        let destVC = self.destinationViewController
        destVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        destVC.modalInPopover = true
        sourceVC.view.addSubview(destVC.view)
        destVC.view.center.x = destVC.view.center.x - destVC.view.frame.width
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: {
            destVC.view.center.x = destVC.view.center.x + destVC.view.frame.width
            }) { (true) in
                sourceVC.presentViewController(destVC, animated: false, completion: nil)
        }
    }
}
