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
    var likeTimeStampRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(EventCell.heartTapped))
        heartImg.userInteractionEnabled = true
        heartImg.addGestureRecognizer(tap)
    }

    func configureCell(event: Event, eventLiked: Bool){
        self.event = event
        self.likeRef = DataService.instance.currentUser.child("likes").child(event.key)
        self.likeTimeStampRef = likeRef.child("timeStampOfEvent")
        
        title.text = event.title     //so these are all guaranteed a value of at least "" but what about property that isn't guaranteed like email
        location.text = event.location
        desc.text = event.description
        
        if self.tag == 2{       //tag 2 is the favorites vc
            self.heartImg.image = UIImage(named: "heartFilled")
        } else {
            
            if eventLiked{
                self.heartImg.image = UIImage(named: "heartFilled")
            } else{
                self.heartImg.image = UIImage(named: "heartEmpty")
            }
            
//            likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//                print("reload")
//                if let doesNotExist = snapshot.value as? NSNull{
//                    self.heartImg.image = UIImage(named: "heartEmpty")
//                } else {
//                    self.heartImg.image = UIImage(named: "heartFilled")
//                }
//            })
        }
    }

    
    func heartTapped(){
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if let doesNotExist = snapshot.value as? NSNull{
                self.heartImg.image = UIImage(named: "heartFilled")
                self.event.adjustLikes(true)
                self.likeTimeStampRef.setValue(self.event.timeStampOfEvent)
                
            } else{
                self.heartImg.image = UIImage(named: "heartEmpty")
                self.event.adjustLikes(false)
                self.likeRef.removeValue()
                NSNotificationCenter.defaultCenter().postNotificationName("heartDeleted", object: nil, userInfo: ["key": self.event.key])
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
}
