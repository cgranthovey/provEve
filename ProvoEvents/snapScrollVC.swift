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
        
        
        let mainTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTableVC")
        
        self.addChildViewController(mainTableVC!)
        self.snapScroll.addSubview((mainTableVC?.view)!)
        mainTableVC?.didMoveToParentViewController(self)
        
        
        let favoritesTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("favoritesTableVC")
        
        var frame1 = favoritesTableVC?.view.frame
        frame1?.origin.x = self.view.frame.width
        favoritesTableVC!.view.frame = frame1!
        
        self.addChildViewController(favoritesTableVC!)
        self.snapScroll.addSubview((favoritesTableVC?.view)!)
        favoritesTableVC?.didMoveToParentViewController(self)
        
        self.snapScroll.contentSize = CGSizeMake(self.view.frame.width * 2, self.view.frame.height - 22)
        
        

    }



}
