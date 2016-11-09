//
//  DataService.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/16/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DataService{
    
    private static let _instance = DataService()
    
    static var instance: DataService{
        return _instance
    }
    
    var mainRef: FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
    
    var eventRef: FIRDatabaseReference{
        return mainRef.child("Events")
    }
    
    var userRef: FIRDatabaseReference{
        return mainRef.child("User")
    }
    
    var commentRef: FIRDatabaseReference{
        return mainRef.child("Comments")
    }
    
    var usernamesRef: FIRDatabaseReference{
        return mainRef.child("Usernames")
    }
    
    var currentUser: FIRDatabaseReference{
        print("current uid \(FIRAuth.auth()?.currentUser?.uid)")
        return userRef.child((FIRAuth.auth()?.currentUser?.uid)!)
    }
    
    
    
    var currentUserProfile: FIRDatabaseReference{
        return currentUser.child("profile")
    }
    
    func saveUser(uid: String){
        let profile: Dictionary<String, AnyObject> = ["firstName": "", "lastName": ""]
        userRef.child(uid).child("profile").setValue(profile)
    }
    
    var geoFireRef: FIRDatabaseReference{
        return mainRef.child("GeoFire")
    }
    
    ////////////////////////////////////////////////////////////////////////
    //Storage
    ////////////////////////////////////////////////////////////////////////
    
    var storage: FIRStorage{
        return FIRStorage.storage()
    }
    
    var storageRef: FIRStorageReference{
        return storage.referenceForURL("gs://provo-events.appspot.com")
    }
    
    var imgStorageRefData: FIRStorageReference{
        return storageRef.child("images")
    }
}