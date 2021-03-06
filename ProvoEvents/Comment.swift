//
//  Comment.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/11/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

class Comment {
    fileprivate var _userId: String?
    fileprivate var _userName: String?
    fileprivate var _timeStamp: Int?
    fileprivate var _commentText: String?
    fileprivate var _key: String?
    
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
