//
//  NoInternetView.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 11/1/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit


class NoInternetView: UIView {

    var view: UIView!
    
    var delegate: noConnectionGotIt!
    
    @IBOutlet weak var gotItBtn: UIButton!

    @IBOutlet var img: UIImageView!
    
    @IBAction func gotItBtnPressed(_ sender: UIButton){
        delegate.dismissNoConnectionView()
    }
    
    @IBAction func gotItBtnTouchDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor().boilerPlateColor(198, green: 40, blue: 40)
    }
    
    @IBAction func gotItBtnTouchUpOutside(_ sender: UIButton) {
        sender.backgroundColor = UIColor().boilerPlateColor(244, green: 67, blue: 54)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("mice30")
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("mice40")
        setUp()
    }
    
    func setUp(){
        
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        print("mice20")
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NoInternetView", bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        print("mice10")
        return view!
    }

}
