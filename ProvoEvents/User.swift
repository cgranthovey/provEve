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
    
    init(firstName: String?, userName: String?, imgString: String?){
        self._firstName = firstName
        self._userName = userName
        self._profileImg = imgString
    }
    

}
