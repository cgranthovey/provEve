//
//  snapScrollVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/3/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth

class snapScrollVC: UIViewController {

    @IBOutlet weak var snapScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let addEventVC = self.storyboard?.instantiateViewControllerWithIdentifier("addEventVC")
        
        self.addChildViewController(addEventVC!)
        self.snapScroll.addSubview((addEventVC?.view)!)
        addEventVC?.didMoveToParentViewController(self)
        
        
        let mainTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTableVC")
//        let mainTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("snapScroll2")

//snapScroll2
        var frame1 = mainTableVC?.view.frame
        frame1?.origin.x = self.view.frame.width
        mainTableVC!.view.frame = frame1!
        
        self.addChildViewController(mainTableVC!)
        self.snapScroll.addSubview((mainTableVC?.view)!)
        mainTableVC?.didMoveToParentViewController(self)
        
        
        
        let favVC = self.storyboard?.instantiateViewControllerWithIdentifier("favoritesTableVC")
        var frame2 = favVC?.view.frame
        frame2?.origin.x = 2 * self.view.frame.width
        favVC!.view.frame = frame2!
        
        self.addChildViewController(favVC!)
        self.snapScroll.addSubview((favVC?.view)!)
        favVC?.didMoveToParentViewController(self)
        
        
//        
//        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("mapVC")
//        var frame3 = favVC?.view.frame
//        frame3?.origin.y = self.view.frame.height
//        mapVC?.view.frame = frame3!
//        
//        self.addChildViewController(mapVC!)
//        self.snapScroll.addSubview((mapVC?.view)!)
//        mapVC?.didMoveToParentViewController(self)
//        
        
        self.snapScroll.contentSize = CGSizeMake(self.view.frame.width * 3, self.view.frame.height)
        self.snapScroll.contentOffset = CGPoint(x: view.frame.width, y: 0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(snapScrollVC.addEventSubmitSlide), name: "addEventSubmitSlide", object: nil)
    }
    
    func addEventSubmitSlide(){
        let point = CGPoint(x: view.frame.width, y: 0)
        self.snapScroll.setContentOffset(point, animated: true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
    }



}
