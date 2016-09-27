//
//  EventCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EventCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var heartImg: UIImageView!
    var event: Event!
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(EventCell.heartTapped))
        heartImg.userInteractionEnabled = true
        heartImg.addGestureRecognizer(tap)
    }

    func configureCell(event: Event){
        self.event = event
        self.likeRef = DataService.instance.currentUser.child("likes").child(event.key)

        
        title.text = event.title     //so these are all guaranteed a value of at least "" but what about property that isn't guaranteed like email
        location.text = event.location
        desc.text = event.description
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull{
                self.heartImg.image = UIImage(named: "heartEmpty")
            } else {
                self.heartImg.image = UIImage(named: "heartFilled")
            }
        })
    }

    
    func heartTapped(){
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if let doesNotExist = snapshot.value as? NSNull{
                self.heartImg.image = UIImage(named: "heartFilled")
                self.event.adjustLikes(true)
                self.likeRef.setValue(true)
            } else{
                self.heartImg.image = UIImage(named: "heartEmpty")
                self.event.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
}
