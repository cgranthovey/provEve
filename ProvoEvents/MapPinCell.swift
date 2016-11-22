//
//  MapPinCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/10/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class MapPinCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var checkImg: UIImageView?
    func configureCell(_ image: String, label: String, isChecked: Bool = false){
        img.image = UIImage(named: image)
        lbl.text = label
        checkImg?.image = UIImage(named: "checkMap")
        if isChecked{
            checkImg?.isHidden = false
        } else{
            checkImg?.isHidden = true
        }
    }
    
    func isImgChecked() -> Bool{
        if checkImg?.isHidden == true{
            return false
        } else{
            return true
        }
    }
    
    func checkImg(_ shouldShow: Bool){
        if shouldShow{
            img.alpha = 1.0
            checkImg?.isHidden = false
        } else{
            img.alpha = 0.5
            checkImg?.isHidden = true
        }
    }
}
