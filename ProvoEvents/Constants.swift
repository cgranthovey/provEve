//
//  Constants.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/19/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import FirebaseAuth

class Constants {
    
    private static let _instance = Constants()
    
    static var instance: Constants{
        return _instance
    }
    
    var successImg: UIImage{
        return UIImage(named: "checkmark")!
    }
    
    var FirConsFirstName: String{
        return "firstName"
    }
    
    var nsUserDefaultsKeySettingsMiles: String{
        let uid = FIRAuth.auth()?.currentUser?.uid
        return ("\(uid)Setting-Miles")
    }
    
    
    
    var currentUser: User!
    
    func initCurrentUser(){
        
        
        
        DataService.instance.currentUserProfile.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value == nil{
                
            } else{
                if let snapDict = snapshot.value as? Dictionary<String, String>{
                    
                    let firstName = snapDict["firstName"]
                    let profileImg = snapDict["profileImg"]
                    let userName = snapDict["userName"]
                    self.currentUser = User(firstName: firstName, userName: userName, imgString: profileImg)

                }
            }
        })
        

    }
    
    
}