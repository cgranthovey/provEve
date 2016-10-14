//
//  Comment.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/11/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

class Comment {
    private var _userId: String?
    private var _userName: String?
    private var _timeStamp: Int?
    private var _commentText: String?
    
    
    var userId: String?{
        return _userId
    }
    
    var userName: String?{
        if _userName == nil{
            _userName = "Drake"
        }
        return _userName
    }
    
    var timeStamp: Int?{
        return _timeStamp
    }
    
    var commentText: String?{
        return _commentText
    }
    

    
    init(dict: Dictionary<String, AnyObject>){
        _userId = dict["userId"] as? String
        _timeStamp = dict["timeStamp"] as? Int
        _commentText = dict["comment"] as? String
        
        
        DataService.instance.userRef.child(_userId!).child("profile").child("userName").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let snap = snapshot.value as? String{
                self._userName = snap
            }
        })
        
    }
}