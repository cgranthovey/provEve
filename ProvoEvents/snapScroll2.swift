//
//  snapScroll2.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/30/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class snapScroll2: UIViewController {

    @IBOutlet weak var snapScroll: UIScrollView!
    
    //mainTableVC
    //mapVC
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainEventVC = self.storyboard?.instantiateViewControllerWithIdentifier("mapVC")
        
        self.addChildViewController(mainEventVC!)
        self.snapScroll.addSubview((mainEventVC?.view)!)
        mainEventVC?.didMoveToParentViewController(self)
        
    
        
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTableVC")
        
        var frame1 = mapVC?.view.frame
        frame1?.origin.y = self.view.frame.height
        mapVC!.view.frame = frame1!
        
        self.addChildViewController(mapVC!)
        self.snapScroll.addSubview((mapVC?.view)!)
        mapVC?.didMoveToParentViewController(self)
        
        self.snapScroll.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height * 2)
        self.snapScroll.contentOffset = CGPoint(x: 0, y:  view.frame.height)
        
    }


}
