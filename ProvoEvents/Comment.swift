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
    private var _key: String?
    
    var userId: String?{
        return _userId
    }
    var userName: String?{
        set{
            _userName = newValue
        } get{
            if _userName == nil{
                _userName = "unavailable"
            }
            return _userName
        }
    }
    var timeStamp: Int?{
        return _timeStamp
    }
    var commentText: String?{
        return _commentText
    }
    var key: String?{
        return _key
    }

    init(dict: Dictionary<String, AnyObject>, key: String){
        _userId = dict["userId"] as? String
        _timeStamp = dict["timeStamp"] as? Int
        _commentText = dict["comment"] as? String
        _key = key
    }
}