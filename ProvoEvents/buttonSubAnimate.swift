//
//  buttonSubAnimate.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/29/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

protocol imagePopDelegate {
    func imageCompletedPop()
}

class buttonSubAnimate: UIButton {

    var delegate: imagePopDelegate?
    
    var myImg: UIImageView!
    
    func setUpEventImgBtn(img: UIImageView){
        print("called")
        myImg = img
        self.addTarget(self, action: #selector(buttonSubAnimate.eventImgBtnTouchDown), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(buttonSubAnimate.eventImgBtnTouchUpInside), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(buttonSubAnimate.touchUpOutside), forControlEvents: .TouchUpOutside)
    }
    
    func eventImgBtnTouchDown(){
        print("2ne")
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
            self.myImg.transform = CGAffineTransformMakeScale(1.05, 1.05)
            }, completion: nil)
    }
    
    func eventImgBtnTouchUpInside(){
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
            self.myImg.transform = CGAffineTransformMakeScale(1.15, 1.15)
            
        }) { (true) in
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                self.myImg.transform = CGAffineTransformMakeScale(0.85, 0.85)
                
            }) { (true) in
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                    self.myImg.transform = CGAffineTransformMakeScale(1, 1)
                    //         self.imageTapped()
                    self.delegate!.imageCompletedPop()
                    }, completion: { (true) in
                })
            }
        }
    }
    
    func touchUpOutside(){
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
            self.myImg.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    

}
