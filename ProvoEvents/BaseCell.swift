//
//  BaseCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/12/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    func setUpViews(){
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}