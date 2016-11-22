//
//  SettingsCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/12/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import UIKit

class SettingsCell: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont(name: "Avenir", size: 16)
        return label
    }()
    
    func configureCell(_ dayOfWeek: String, weekInfo: String?, currentlySelected: Bool){
        if weekInfo != nil{
            nameLabel.text = dayOfWeek + " " + weekInfo!
        } else{
            nameLabel.text = dayOfWeek
        }
        if currentlySelected{
            iconImgView.isHidden = false
        } else{
            iconImgView.isHidden = true
        }
    }

    func makeImgHidden(){
        iconImgView.isHidden = true
    }
    
    func makeImgViewable(){
        iconImgView.isHidden = false
    }
    
    let iconImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "checkMap")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func setUpViews() {
        super.setUpViews()
        addSubview(nameLabel)
        addSubview(iconImgView)
        addConstraintWithFormat("H:|-10-[v0(20)]-8-[v1]|", views: iconImgView, nameLabel)
        addConstraintWithFormat("V:|[v0]|", views: nameLabel)
        addConstraintWithFormat("V:[v0(20)]", views: iconImgView)
        
        addConstraint(NSLayoutConstraint(item: iconImgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}
