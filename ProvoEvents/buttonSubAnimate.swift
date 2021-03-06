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
    
    func setUpEventImgBtn(_ img: UIImageView){
        myImg = img
        self.addTarget(self, action: #selector(buttonSubAnimate.eventImgBtnTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonSubAnimate.eventImgBtnTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonSubAnimate.touchUpOutside), for: .touchUpOutside)
    }
    
    @objc func eventImgBtnTouchDown(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.myImg.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: nil)
    }
    
    @objc func eventImgBtnTouchUpInside(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.myImg.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            
        }) { (true) in
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
                self.myImg.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                
            }) { (true) in
                UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
                    self.myImg.transform = CGAffineTransform(scaleX: 1, y: 1)
                    //         self.imageTapped()
                    self.delegate!.imageCompletedPop()
                    }, completion: { (true) in
                })
            }
        }
    }
    
    @objc func touchUpOutside(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.myImg.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }
    

}
