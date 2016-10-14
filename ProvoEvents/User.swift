//
//  User.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/11/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User{

    private var _firstName: String?
    private var _profileImg: String?
    private var _userName: String?

    var firstName: String?{
        if _firstName == nil{
            _firstName = ""
        }
        return _firstName
    }

    var profileImg: String?{
        return _profileImg
    }

    var userName: String?{
        if _userName == nil{
            _userName = ""
        }
        return _userName
    }
    
    func initCurrentUser(){
        DataService.instance.currentUserProfile.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value == nil{
                print("snap is nil")
            } else{
                
                if let snapDict = snapshot.value as? Dictionary<String, String>{
                    self._firstName = snapDict["firstName"]
                    self._profileImg = snapDict["profileImg"]
                    self._userName = snapDict["userName"]
                }
            }
        })
    }
}
