//
//  EventCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(event: Event){
        title.text = event.title     //so these are all guaranteed a value of at least "" but what about property that isn't guaranteed like email
        location.text = event.location
        desc.text = event.description
    }


}
