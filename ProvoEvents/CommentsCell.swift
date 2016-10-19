//
//  CommentsCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/11/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth

class CommentsCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    @IBOutlet weak var deleteBtnOutlet: UIButton!
    @IBOutlet weak var deleteImg: UIImageView!

    var thisComment: Comment!
    var commentKey: String!
    
    func configureCell(comment: Comment){
        self.commentKey = comment.key
        self.thisComment = comment
        name.text = comment.userName
        self.comment.text = comment.commentText
        
        if comment.userId != FIRAuth.auth()?.currentUser?.uid{
            deleteBtnOutlet.hidden = true
            deleteImg.hidden = true
        }
        
    }
    
    @IBAction func deleteTapped(){
        NSNotificationCenter.defaultCenter().postNotificationName("commentDelete", object: commentKey, userInfo: nil)
    }
    
}
