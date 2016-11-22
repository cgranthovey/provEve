//
//  Post.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Event{
    fileprivate var _title: String!
    fileprivate var _location: String!
    fileprivate var _date: String!
    fileprivate var _timeStampOfEvent: Int?
    fileprivate var _datePosted: Int?
    fileprivate var _email: String?
    fileprivate var _imgURL: String?
    fileprivate var _description: String!
    fileprivate var _user: String!
    fileprivate var _key: String!
    fileprivate var _likes: Int!
    fileprivate var _eventTypeImgName: String!
    
    fileprivate var _pinInfoAddress: String?
    fileprivate var _pinInfoName: String?
    fileprivate var _pinInfoLatitude: Double?
    fileprivate var _pinInfoLongitude: Double?
    fileprivate var _isLiked: Bool!
    
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
        if _email == nil{
            _email = ""
        }
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
    var likes: Int{
        if _likes == nil{
            _likes = 0
        }
        return _likes
    }
    var pinInfoAddress: String?{
        return _pinInfoAddress
    }
    var pinInfoName: String?{
        return _pinInfoName
    }
    var pinInfoLatitude: Double?{
        return _pinInfoLatitude
    }
    var pinInfoLongitude: Double?{
        return _pinInfoLongitude
    }
    var isLiked: Bool{
        return _isLiked
    }
    var eventTypeImgName: String{
        if _eventTypeImgName == nil{
            _eventTypeImgName = ""
        }
        return _eventTypeImgName
    }
    
    init(key: String, dict: Dictionary<String, AnyObject>, isLiked: Bool){
        _title = dict["title"] as? String
        _location = dict["location"] as? String
        _date = dict["date"] as? String
        _timeStampOfEvent = dict["timeStampOfEvent"] as? Int
        _datePosted = dict["timePosted"] as? Int
        _email = dict["email"] as? String
        _imgURL = dict["image"] as? String
        _description = dict["description"] as? String
        _user = dict["user"] as? String
        _eventTypeImgName = dict["eventTypeImgName"] as? String
        _key = key
        _likes = dict["likes"] as? Int
        _isLiked = isLiked
        if let pinInfoDict = dict["pinInfo"] as? Dictionary<String, AnyObject>{
            _pinInfoAddress = pinInfoDict["address"] as? String
            _pinInfoName = pinInfoDict["name"] as? String
            _pinInfoLatitude = pinInfoDict["latitude"] as? Double
            _pinInfoLongitude = pinInfoDict["longitude"] as? Double
        }
    }
    
    func adjustHeartImgIsLiked(_ isLiked: Bool){
        if isLiked{
            _isLiked = true
        } else{
            _isLiked = false
        }
    }
    
    func adjustLikes(_ addLike: Bool){
        
        adjustHeartImgIsLiked(addLike)
        
        var likeRef: FIRDatabaseReference!
        var likeTimeStampRef: FIRDatabaseReference!
        
        likeRef = DataService.instance.currentUser.child("likes").child(key)
        likeTimeStampRef = likeRef.child("timeStampOfEvent")
        
        if addLike{
            print("should be liked")
            likeTimeStampRef.setValue(self.timeStampOfEvent)
        } else{
            print("should be removed")
            likeRef.removeValue()
        }
        
        _isLiked = addLike  // will set the event to whether it is liked or not
        DataService.instance.eventRef.child(_key).child("likes").observeSingleEvent(of: .value, with: {snapshot in
            if let doesNotExist = snapshot.value as? NSNull{
                self._likes = 0
                self.finalAdjust(addLike)
            } else{
                self._likes = snapshot.value as! Int
                self.finalAdjust(addLike)
            }
        })
    }
    
    func finalAdjust(_ addLike: Bool){
        if addLike{
            _likes = _likes + 1
        } else{
            _likes = _likes - 1
        }
        DataService.instance.eventRef.child(_key).child("likes").setValue(_likes)
    }
}
