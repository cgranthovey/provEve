//
//  Post.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

class Event{
    private var _title: String!
    private var _location: String!
    private var _date: String!
    private var _timeStampOfEvent: Int?
    private var _datePosted: Int?
    private var _email: String?
    private var _imgURL: String?
    private var _description: String!
    private var _user: String!
    private var _key: String!
    
    var title: String{
        if _title == nil{
            _title = ""
        }
        return _title
    }
    var location: String{
        if _location == nil{
            _location = ""
        }
        return _location
    }
    var date: String{
        if _date == nil{
            _date = ""
        }
        return _date
    }
    var timeStampOfEvent: Int?{
        return _timeStampOfEvent
    }
    var datePosted: Int?{
        return _datePosted
    }
    var email: String?{
        return _email
    }
    var imgURL: String?{
        return _imgURL
    }
    var description: String!{
        if _description == nil{
            _description = ""
        }
        return _description
    }
    var user: String{
        return _user
    }
    
    var key: String{
        return _key
    }
    
    
    init(key: String, dict: Dictionary<String, AnyObject>){
        _title = dict["title"] as? String
        _location = dict["location"] as? String
        _date = dict["date"] as? String
        _timeStampOfEvent = dict["timeStampOfEvent"] as? Int
        _datePosted = dict["timePosted"] as? Int
        _email = dict["email"] as? String
        _imgURL = dict["image"] as? String
        _description = dict["description"] as? String
        _user = dict["user"] as? String
        _key = key
    }
    
}