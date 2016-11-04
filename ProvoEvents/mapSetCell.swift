//
//  mapSetCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 11/2/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class mapSetCell: UICollectionViewCell {
    
    
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "NoInternetView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as? UIView
        
        return view!
    }

}
