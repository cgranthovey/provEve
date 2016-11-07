//
//  EventExtension.swift
//  Ibento
//
//  Created by Chris Hovey on 11/5/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

extension Event{
    
    func beforeToday() -> Bool{
        let currentDate = NSDate()
        let todayStartInSeconds = todayStart(currentDate)
        if timeStampOfEvent < todayStartInSeconds{
            return true
        } else{
            return false
        }
    }
    
    func onThisDay(date: NSDate) -> Bool{
        
        var start = date.timeIntervalSince1970
        var end = date.timeIntervalSince1970 + 86400
        
        let timeOfEvent = Double(self.timeStampOfEvent!)
        
        if timeOfEvent >= start && timeOfEvent < end{
            return true
        } else{
            return false
        }
    }
    
    func todayStart(date: NSDate) ->Int{
        
        let calendar = NSCalendar.currentCalendar()
        let currentHour = calendar.component(.Hour, fromDate: date)
        let currentMinute = calendar.component(.Minute, fromDate: date)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(date.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        return todayStartInSeconds
    }
}