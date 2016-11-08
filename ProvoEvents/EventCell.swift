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
    @IBOutlet weak var anotherImg: UIImageView!
    var event: Event!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventCell.heartTapped))
        heartImg.userInteractionEnabled = true
        heartImg.addGestureRecognizer(tap)
    }

    func configureCell(event: Event){
        self.event = event
        let eventLiked = event.isLiked
        title.text = event.title
        location.text = event.location
        desc.text = event.description
        anotherImg?.image = UIImage(named: event.eventTypeImgName)
        
        if self.tag == 2{       //tag 2 is the favorites vc
            self.heartImg.image = UIImage(named: "heartFilled")
        } else {
            if eventLiked{
                self.heartImg.image = UIImage(named: "heartFilled")
            } else{
                self.heartImg.image = UIImage(named: "heartEmpty")
            }
        }
    }

    func setHeartImgFill(){
        self.heartImg.image = UIImage(named: "heartFilled")
    }
    
    func setHeartImgEmpty(){
        self.heartImg.image = UIImage(named: "heartEmpty")
    }
    
    func heartTapped(){
        if !event.isLiked{
            self.heartImg.image = UIImage(named: "heartFilled")
            NSNotificationCenter.defaultCenter().postNotificationName("heartAdded", object: self.event, userInfo: nil)
            self.event.adjustLikes(true)
        } else{
            self.heartImg.image = UIImage(named: "heartEmpty")
            NSNotificationCenter.defaultCenter().postNotificationName("heartDeleted", object: self.event.key, userInfo: nil)
            self.event.adjustLikes(false)
        }
    }
}