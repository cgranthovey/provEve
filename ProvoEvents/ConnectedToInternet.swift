//
//  ConnectedToInternet.swift
//  Ibento
//
//  Created by Chris Hovey on 11/3/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import UIKit

typealias isConnected = ((_ connected: Bool?) -> Void)?

class ConnectedToInternet{
    fileprivate static let _instance1 = ConnectedToInternet()
    
    static var instance1: ConnectedToInternet{
        return _instance1
    }
    
    func areWeConnected(_ view: UIView, showNoInternetView: Bool, onComplete: isConnected){
                let task = URLSession.shared.dataTask(with: URL(string: "https://www.google.com/")!, completionHandler: { (data, response, error) -> Void in
                    DispatchQueue.main.async(execute: { 
                        if error != nil{
                            let myError = error as! NSError
                            let errCode = URLError(_nsError: myError)
                            if errCode.errorCode == NSURLErrorNotConnectedToInternet{
                                print("not connected!!!")
                                if showNoInternetView{
                                    NoConnectionView().showNoConnectionView(view)
                                }
                                if onComplete != nil{
                                    onComplete!(false)
                                }
                            }
                        } else{
                            if onComplete != nil{
                                onComplete!(true)
                            }
                        }
                    })
                })
                task.resume()
    }
}



