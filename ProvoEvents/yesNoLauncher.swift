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
    var deleteCommentKey: String!
    var darkView: UIView!
    var verifyDeleteView: UIView!
    var yesBtn: UIButton!
    var noBtn: UIButton!
    
    func showDeleteView(_ view: UIView!, lblText: String!){

            let rect = CGRect(x: 0, y: 0, width: 230, height: 100)
            let lblRect = CGRect(x: 0, y: 0, width: 230, height: 55)
            let yesBtnRect = CGRect(x: 0, y: 55, width: 115, height: 45)
            let noBtnRect = CGRect(x: 115, y: 55, width: 115, height: 45)
            
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
            verifyLbl.textAlignment = .center
            verifyLbl.font = UIFont(name: "Avenir", size: 18)
            
            let rect1 = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            darkView = UIView(frame: rect1)
            darkView.backgroundColor = UIColor.black
            darkView.alpha = 0
            view.addSubview(darkView)
            
            view.addSubview(verifyDeleteView)
            verifyDeleteView.addSubview(verifyLbl)
            verifyDeleteView.addSubview(yesBtn)
            verifyDeleteView.addSubview(noBtn)

            yesBtn.setTitle("YES", for: UIControlState())
            yesBtn.titleLabel?.font = UIFont(name: "Avenir", size: 14)
            yesBtn.setTitleColor(UIColor.black, for: UIControlState())
            yesBtn.isUserInteractionEnabled = true
            noBtn.setTitleColor(UIColor.black, for: UIControlState())
            noBtn.titleLabel?.font = UIFont(name: "Avenir", size: 14)
            noBtn.setTitle("NO", for: UIControlState())
            noBtn.isUserInteractionEnabled = true
            
            yesBtn.addTarget(self, action: #selector(yesNoLauncher.deleteCommentYes), for: .touchUpInside)
            yesBtn.addTarget(self, action: #selector(yesNoLauncher.touchUpOutside(_:)), for: .touchUpOutside)
            yesBtn.addTarget(self, action: #selector(yesNoLauncher.touchDownChgBtnColor(_:)), for: .touchDown)
            noBtn.addTarget(self, action: #selector(yesNoLauncher.deleteCommentNo), for: .touchUpInside)
            noBtn.addTarget(self, action: #selector(yesNoLauncher.touchDownChgBtnColor(_:)), for: .touchDown)
            noBtn.addTarget(self, action: #selector(yesNoLauncher.touchUpOutside(_:)), for: .touchUpOutside)
            
            view.bringSubview(toFront: verifyDeleteView)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.45
                self.verifyDeleteView.alpha = 1
                }, completion: nil)
    }
    
    func touchUpOutside(_ btn: UIButton){
        btn.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }
    
    func touchDownChgBtnColor(_ btn: UIButton){
        btn.backgroundColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
    }
    
    func deleteCommentYes(){
        yesBtn.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.darkView.alpha = 0
            self.verifyDeleteView.alpha = 0
        }, completion: { (true) in
            self.darkView.removeFromSuperview()
            self.verifyDeleteView.removeFromSuperview()
        
            self.delegate?.yesPressed()
        }) 
    }
    
    func deleteCommentNo(){
        noBtn.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        UIView.animate(withDuration: 0.3, animations: {
            self.darkView.alpha = 0
            self.verifyDeleteView.alpha = 0
        }, completion: { (true) in
            self.darkView.removeFromSuperview()
            self.verifyDeleteView.removeFromSuperview()
        }) 
    }
}
