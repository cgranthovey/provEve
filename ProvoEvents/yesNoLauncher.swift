//
//  yesNoLauncher.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/17/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

protocol yesSelectedProtocol {
    func yesPressed()
}

class yesNoLauncher: NSObject {

    var delegate: yesSelectedProtocol?
    
    func showDeleteView(view: UIView!, lblText: String!){

            let rect = CGRectMake(0, 0, 230, 100)
            let lblRect = CGRectMake(0, 0, 230, 55)
            let yesBtnRect = CGRectMake(0, 55, 115, 45)
            let noBtnRect = CGRectMake(115, 55, 115, 45)
            
            verifyDeleteView = UIView(frame: rect)
            let verifyLbl = UILabel(frame: lblRect)
            yesBtn = UIButton(frame: yesBtnRect)
            noBtn = UIButton(frame: noBtnRect)
            
            verifyDeleteView.alpha = 0
            
            verifyDeleteView.center = view.center
            verifyDeleteView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
            verifyDeleteView.layer.cornerRadius = 5.0
            verifyDeleteView.clipsToBounds = true
            
            verifyLbl.text = lblText
            verifyLbl.textAlignment = .Center
            verifyLbl.font = UIFont(name: "Avenir", size: 18)
            
            var rect1 = CGRectMake(0, 0, view.frame.width, view.frame.height)
            darkView = UIView(frame: rect1)
            darkView.backgroundColor = UIColor.blackColor()
            darkView.alpha = 0
            view.addSubview(darkView)
            
            view.addSubview(verifyDeleteView)
            verifyDeleteView.addSubview(verifyLbl)
            verifyDeleteView.addSubview(yesBtn)
            verifyDeleteView.addSubview(noBtn)

            yesBtn.setTitle("YES", forState: .Normal)
            yesBtn.titleLabel?.font = UIFont(name: "Avenir", size: 14)
            yesBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            yesBtn.userInteractionEnabled = true
            noBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            noBtn.titleLabel?.font = UIFont(name: "Avenir", size: 14)
            noBtn.setTitle("NO", forState: .Normal)
            noBtn.userInteractionEnabled = true
            
            yesBtn.addTarget(self, action: #selector(yesNoLauncher.deleteCommentYes), forControlEvents: .TouchUpInside)
            yesBtn.addTarget(self, action: #selector(yesNoLauncher.touchUpOutside(_:)), forControlEvents: .TouchUpOutside)
            yesBtn.addTarget(self, action: #selector(yesNoLauncher.touchDownChgBtnColor(_:)), forControlEvents: .TouchDown)
            noBtn.addTarget(self, action: #selector(yesNoLauncher.deleteCommentNo), forControlEvents: .TouchUpInside)
            noBtn.addTarget(self, action: #selector(yesNoLauncher.touchDownChgBtnColor(_:)), forControlEvents: .TouchDown)
            noBtn.addTarget(self, action: #selector(yesNoLauncher.touchUpOutside(_:)), forControlEvents: .TouchUpOutside)
            
            view.bringSubviewToFront(verifyDeleteView)
            
            UIView.animateWithDuration(0.3, animations: {
                self.darkView.alpha = 0.45
                self.verifyDeleteView.alpha = 1
                }, completion: nil)
    }
    
    var deleteCommentKey: String!
    var darkView: UIView!
    var verifyDeleteView: UIView!
    var yesBtn: UIButton!
    var noBtn: UIButton!
    
    func touchUpOutside(btn: UIButton){
        btn.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }
    
    func touchDownChgBtnColor(btn: UIButton){
        print("touch down")

        btn.backgroundColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
    }
    
    func deleteCommentYes(){
        print("delete comment yes")

        yesBtn.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        
        UIView.animateWithDuration(0.3, animations: {
            self.darkView.alpha = 0
            self.verifyDeleteView.alpha = 0
        }) { (true) in
            self.darkView.removeFromSuperview()
            self.verifyDeleteView.removeFromSuperview()
        
            self.delegate?.yesPressed()
        }
    }
    
    func deleteCommentNo(){
        print("delete comment no")

        noBtn.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        UIView.animateWithDuration(0.3, animations: {
            self.darkView.alpha = 0
            self.verifyDeleteView.alpha = 0
        }) { (true) in
            self.darkView.removeFromSuperview()
            self.verifyDeleteView.removeFromSuperview()
        }
    }
}
