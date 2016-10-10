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
    
    func configureCell(image: String, label: String){
        img.image = UIImage(named: image)
        lbl.text = label
    }
}
