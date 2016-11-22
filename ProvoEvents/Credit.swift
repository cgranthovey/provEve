//
//  Credit.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/31/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

class Credit {
    
    fileprivate var _labelText: NSMutableAttributedString!
    fileprivate var _imageString: String!
    
    var labelText: NSMutableAttributedString{
        return _labelText
    }
    
    var imageString: String{
        return _imageString
    }
    
    init(lbl: NSMutableAttributedString, imageStr: String){
        _labelText = lbl
        _imageString = imageStr
    }
    
}
