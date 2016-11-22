//
//  creditsCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/31/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class creditsCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var label1: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(_ credit: Credit){
        img.image = UIImage(named: credit.imageString)
        label1.attributedText = credit.labelText
    }
}
