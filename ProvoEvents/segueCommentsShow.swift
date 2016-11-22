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

        let sourceVC = self.source
        let destVC = self.destination
        destVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        destVC.isModalInPopover = true
        sourceVC.view.addSubview(destVC.view)
        destVC.view.center.x = destVC.view.center.x - destVC.view.frame.width
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            destVC.view.center.x = destVC.view.center.x + destVC.view.frame.width
            }) { (true) in
                sourceVC.present(destVC, animated: false, completion: nil)
        }
    }
}
