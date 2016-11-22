//
//  EventExtension.swift
//  Ibento
//
//  Created by Chris Hovey on 11/5/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


extension Event{
    
    func beforeToday() -> Bool{
        let currentDate = Date()
        let todayStartInSeconds = todayStart(currentDate)
        if timeStampOfEvent < todayStartInSeconds{
            return true
        } else{
            return false
        }
    }
    
    func onThisDay(_ date: Date) -> Bool{
        
        let start = date.timeIntervalSince1970
        let end = date.timeIntervalSince1970 + 86400
        
        let timeOfEvent = Double(self.timeStampOfEvent!)
        
        if timeOfEvent >= start && timeOfEvent < end{
            return true
        } else{
            return false
        }
    }
    
    func todayStart(_ date: Date) ->Int{
        
        let calendar = Calendar.current
        let currentHour = (calendar as NSCalendar).component(.hour, from: date)
        let currentMinute = (calendar as NSCalendar).component(.minute, from: date)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(date.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        return todayStartInSeconds
    }
}
