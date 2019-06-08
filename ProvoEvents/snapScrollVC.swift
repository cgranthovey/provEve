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
        NotificationCenter.default.addObserver(self, selector: #selector(snapScrollVC.addEventSubmitSlide), name: NSNotification.Name(rawValue: "addEventSubmitSlide"), object: nil)
        print("snapScroll1")
        snapScroll.delegate = self
    }
    
    
    var calledOnce = false
    
    override func viewDidAppear(_ animated: Bool) {
        if !calledOnce{
            calledLate()
            calledOnce = true
        }
        print("snapScroll2")
    }
    
    func calledLate(){
        print("snapScroll3")
        let addEventVC = self.storyboard?.instantiateViewController(withIdentifier: "addEventVC")
        self.addChild(addEventVC!)
        self.snapScroll.addSubview((addEventVC?.view)!)
        addEventVC?.didMove(toParent: self)
        
        let mainTableVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTableVC")
        var frame1 = mainTableVC?.view.frame
        frame1?.origin.x = self.view.frame.width
        mainTableVC!.view.frame = frame1!
        self.addChild(mainTableVC!)
        self.snapScroll.addSubview((mainTableVC?.view)!)
        mainTableVC?.didMove(toParent: self)
        
        mainTableVC?.view.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            mainTableVC?.view.alpha = 1
        }) 
        
        let favVC = self.storyboard?.instantiateViewController(withIdentifier: "favoritesTableVC")
        var frame2 = favVC?.view.frame
        frame2?.origin.x = 2 * self.view.frame.width
        favVC!.view.frame = frame2!
        self.addChild(favVC!)
        self.snapScroll.addSubview((favVC?.view)!)
        favVC?.didMove(toParent: self)
        
        self.snapScroll.contentSize = CGSize(width: self.view.frame.width * 3, height: self.view.frame.height)
        self.snapScroll.contentOffset = CGPoint(x: view.frame.width, y: 0)
        
        print("uiScreen", UIScreen.main.bounds.height)
        print("frame height", self.view.frame.height)
        print("snapScroll", self.snapScroll.contentSize.height)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //Called after addEvent is called and we want to scroll back to the EventVC
    @objc func addEventSubmitSlide(){
        let point = CGPoint(x: view.frame.width, y: 0)
        self.snapScroll.setContentOffset(point, animated: true)
    }
}

extension snapScrollVC: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
}
