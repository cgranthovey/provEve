//
//  ConnectedToInternet.swift
//  Ibento
//
//  Created by Chris Hovey on 11/3/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import UIKit


typealias isConnected = ((connected: Bool!) -> Void)?

class ConnectedToInternet{
    private static let _instance1 = ConnectedToInternet()
    
    static var instance1: ConnectedToInternet{
        return _instance1
    }
    
    func areWeConnected(view: UIView, showNoInternetView: Bool, onComplete: isConnected){
                let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://www.google.com/")!, completionHandler: { (data, response, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { 
                        if error != nil{
                            if let errorCode = NSURLError(rawValue: error!.code){
                                if errorCode.rawValue == NSURLErrorNotConnectedToInternet{
                                    print("not connected!!!")
                                    if showNoInternetView{
                                        print("antArmy2")
                                        NoConnectionView().showNoConnectionView(view)
                                    }
                                    if onComplete != nil{
                                        onComplete!(connected: false)
                                    }
                                }
                            }
                        } else{
                            if onComplete != nil{
                                onComplete!(connected: true)
                            }
                        }
                    })
                })
                task.resume()
    }
}



