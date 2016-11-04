//
//  mapSettingsCVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 11/2/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class mapSettingsCVC: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var mapSettingsLbl: UILabel!
    
    func configureCell(image: String, lbl2: String){
        img.image = UIImage(named: image)
        mapSettingsLbl.text = lbl2
    }
    
}
