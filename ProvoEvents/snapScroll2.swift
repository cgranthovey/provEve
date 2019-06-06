//
//  snapScroll2.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/30/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//this vc is currently not used, it will allow for AnnotationMapVC be "above" EventVC and user can scroll to VC instead of through outlet

class snapScroll2: UIViewController {

    @IBOutlet weak var snapScroll: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainEventVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC")
        self.addChild(mainEventVC!)
        self.snapScroll.addSubview((mainEventVC?.view)!)
        mainEventVC?.didMove(toParent: self)
        
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTableVC")
        var frame1 = mapVC?.view.frame
        frame1?.origin.y = self.view.frame.height
        mapVC!.view.frame = frame1!
        self.addChild(mapVC!)
        self.snapScroll.addSubview((mapVC?.view)!)
        mapVC?.didMove(toParent: self)
        
        self.snapScroll.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 2)
        self.snapScroll.contentOffset = CGPoint(x: 0, y:  view.frame.height)
    }
}
