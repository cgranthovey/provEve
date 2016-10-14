//
//  CommentsCell.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/11/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UILabel!

    func configureCell(comment: Comment){
        
        name.text = comment.userName
        self.comment.text = comment.commentText
        
    }
    
}
