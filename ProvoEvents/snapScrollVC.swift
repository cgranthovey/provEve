//
//  snapScrollVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/3/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//sets up paging scroll view for 3 VCs - addEvent, EventVC, FavoritesVC

class snapScrollVC: UIViewController {

    @IBOutlet weak var snapScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets up 3 view controllers, addEvent first, main table 2nd and favoritsTable 3rd.  Then offsets scrollview to the middle VC
        
//        performSelector(#selector(snapScrollVC.calledLate), withObject: nil, afterDelay: 1.5)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(snapScrollVC.addEventSubmitSlide), name: "addEventSubmitSlide", object: nil)
    }
    
    var calledOnce = false
    
    override func viewDidAppear(animated: Bool) {
        if !calledOnce{
            calledLate()
            calledOnce = true
        }

    }
    
    func calledLate(){
        let addEventVC = self.storyboard?.instantiateViewControllerWithIdentifier("addEventVC")
        self.addChildViewController(addEventVC!)
        self.snapScroll.addSubview((addEventVC?.view)!)
        addEventVC?.didMoveToParentViewController(self)
        
        let mainTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTableVC")
        var frame1 = mainTableVC?.view.frame
        frame1?.origin.x = self.view.frame.width
        mainTableVC!.view.frame = frame1!
        self.addChildViewController(mainTableVC!)
        self.snapScroll.addSubview((mainTableVC?.view)!)
        mainTableVC?.didMoveToParentViewController(self)
        
        mainTableVC?.view.alpha = 0
        UIView.animateWithDuration(0.3) {
            mainTableVC?.view.alpha = 1
        }
        
        let favVC = self.storyboard?.instantiateViewControllerWithIdentifier("favoritesTableVC")
        var frame2 = favVC?.view.frame
        frame2?.origin.x = 2 * self.view.frame.width
        favVC!.view.frame = frame2!
        self.addChildViewController(favVC!)
        self.snapScroll.addSubview((favVC?.view)!)
        favVC?.didMoveToParentViewController(self)
        
        self.snapScroll.contentSize = CGSizeMake(self.view.frame.width * 3, self.view.frame.height)
        self.snapScroll.contentOffset = CGPoint(x: view.frame.width, y: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    
    //Called after addEvent is called and we want to scroll back to the EventVC
    func addEventSubmitSlide(){
        let point = CGPoint(x: view.frame.width, y: 0)
        self.snapScroll.setContentOffset(point, animated: true)
    }

}
