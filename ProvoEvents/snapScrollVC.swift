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
        
        
        let mainTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("addEventVC")
        
        self.addChildViewController(mainTableVC!)
        self.snapScroll.addSubview((mainTableVC?.view)!)
        mainTableVC?.didMoveToParentViewController(self)
        
        
        let favoritesTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTableVC")
        
        var frame1 = favoritesTableVC?.view.frame
        frame1?.origin.x = self.view.frame.width
        favoritesTableVC!.view.frame = frame1!
        
        self.addChildViewController(favoritesTableVC!)
        self.snapScroll.addSubview((favoritesTableVC?.view)!)
        favoritesTableVC?.didMoveToParentViewController(self)
        
//        self.snapScroll.contentSize = CGSizeMake(self.view.frame.width * 2, self.view.frame.height)
        
        
        let addEventVC = self.storyboard?.instantiateViewControllerWithIdentifier("favoritesTableVC")
        var frame2 = addEventVC?.view.frame
        frame2?.origin.x = 2 * self.view.frame.width
        addEventVC!.view.frame = frame2!
        
        self.addChildViewController(addEventVC!)
        self.snapScroll.addSubview((addEventVC?.view)!)
        addEventVC?.didMoveToParentViewController(self)
        
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
