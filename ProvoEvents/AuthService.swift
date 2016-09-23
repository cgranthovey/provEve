//
//  AuthService.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/16/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (errMsg: String!, data: AnyObject?) -> Void

class AuthService{
    private static let _instance = AuthService()
    
    static var instance: AuthService{
        return _instance
    }
    
    func login(password: String, email: String, onComplete: Completion){
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error != nil{
                self.handleErrors(error!, onComplete: onComplete)
            } else{
                onComplete(errMsg: nil, data: user)
            }
        })
    }
    
    func createUser(password: String, email: String, onComplete: Completion){
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error != nil{
                self.handleErrors(error!, onComplete: onComplete)
            } else{
                if user?.uid != nil{
                    DataService.instance.saveUser(user!.uid)
                    
                    FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                        if error != nil{
                            self.handleErrors(error!, onComplete: onComplete)
                        } else{
                            onComplete(errMsg: nil, data: user)
                        }
                    })
                }
            }
        })
    }
    
    func handleErrors(error: NSError, onComplete: Completion){
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code){
            switch errorCode {
            case FIRAuthErrorCode.ErrorCodeInvalidEmail: onComplete(errMsg: "Invalid Email", data: nil)
            case FIRAuthErrorCode.ErrorCodeWrongPassword: onComplete(errMsg: "Invalid Password", data: nil)
            case FIRAuthErrorCode.ErrorCodeWeakPassword: onComplete(errMsg: "Password too weak", data: nil)
            case FIRAuthErrorCode.ErrorCodeUserDisabled: onComplete(errMsg: "Account disabled", data: nil)
            case FIRAuthErrorCode.ErrorCodeUserNotFound: onComplete(errMsg: "Account could not be found", data: nil)
            case FIRAuthErrorCode.ErrorCodeTooManyRequests, .ErrorCodeNetworkError: onComplete(errMsg: "Please try logging in again later", data: nil)
            case FIRAuthErrorCode.ErrorCodeEmailAlreadyInUse: onComplete(errMsg: "Email address already in use", data: nil)
            default:
                onComplete(errMsg: "There was an error authenticating", data: nil)
            }
        }
    }
    
    var imagesCar = DataService.instance.storageRef.child("images/car.jpg")
    
}