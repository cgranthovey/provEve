//
//  AuthService.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/16/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService{
    fileprivate static let _instance = AuthService()
    
    static var instance: AuthService{
        return _instance
    }
    
    func login(_ password: String, email: String, onComplete: @escaping Completion){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                self.handleErrors(error! as NSError, onComplete: onComplete)
            } else{
                onComplete(nil, user)
            }
        })
    }
    
    func createUser(_ password: String, email: String, onComplete: @escaping Completion){
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                self.handleErrors(error! as NSError, onComplete: onComplete)
            } else{
                if user?.uid != nil{
                    DataService.instance.saveUser(user!.uid)
                    
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil{
                            self.handleErrors(error! as NSError, onComplete: onComplete)
                        } else{
                            onComplete(nil, user)
                        }
                    })
                }
            }
        })
    }
    
    func passwordReset(_ password: String, onComplete: @escaping Completion){
        FIRAuth.auth()?.sendPasswordReset(withEmail: password, completion: { (error) in
            if error != nil{
                    self.handlePasswordResetErrors(error! as NSError, onComplete: onComplete)
            } else{
                onComplete(nil, nil)
            }
        })
    }
    
    func handlePasswordResetErrors(_ error: NSError, onComplete: Completion){
        if let errorCode = FIRAuthErrorCode(rawValue: error.code){
            switch errorCode {
            case FIRAuthErrorCode.errorCodeInvalidEmail: onComplete("This email is not in our system", nil)
            default:
                onComplete("There was a problem sending a password reset", nil)
            }
        }
    }
    
    func handleErrors(_ error: NSError, onComplete: Completion){
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code){
            switch errorCode {
            case FIRAuthErrorCode.errorCodeInvalidEmail: onComplete("Invalid Email", nil)
            case FIRAuthErrorCode.errorCodeWrongPassword: onComplete("Invalid Password", nil)
            case FIRAuthErrorCode.errorCodeWeakPassword: onComplete("Password too weak", nil)
            case FIRAuthErrorCode.errorCodeUserDisabled: onComplete("Account disabled", nil)
            case FIRAuthErrorCode.errorCodeUserNotFound: onComplete("Account could not be found", nil)
            case FIRAuthErrorCode.errorCodeTooManyRequests, .errorCodeNetworkError: onComplete("Please try logging in again later", nil)
            case FIRAuthErrorCode.errorCodeEmailAlreadyInUse: onComplete("Email address already in use", nil)
            default:
                onComplete("There was an error authenticating", nil)
            }
        }
    }
}
