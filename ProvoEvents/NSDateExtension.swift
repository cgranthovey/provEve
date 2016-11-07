//
//  NSDateExtension.swift
//  Ibento
//
//  Created by Chris Hovey on 11/5/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

extension NSDate {
    
    func weekInfo() -> String{
        let format = NSDateFormatter()
        format.dateStyle = .ShortStyle
        var day = format.stringFromDate(self)
        day.removeRange(day.endIndex.advancedBy(-3)..<day.endIndex)
        return day
    }
    
    func dayOfTheWeek() -> String! {
        let weekdays = [
            "Sun",
            "Mon",
            "Tues",
            "Wed",
            "Thur",
            "Fri",
            "Sat"
        ]
        
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = calendar.components(.Weekday, fromDate: self)
        return weekdays[components.weekday - 1]
    }
    
    func hourOfDay() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let hour = calendar.component(.Hour, fromDate: self)
        return hour
    }
    
    
    func isTodayOrTomorrow() -> String?{
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let currentHour = calendar.component(.Hour, fromDate: currentDate)
        let currentMinute = calendar.component(.Minute, fromDate: currentDate)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(currentDate.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        
        let todayEnd = todayStartInSeconds + 86400
        
        let tomorrowEnd = todayEnd + 86400
        
        if Int(self.timeIntervalSince1970) < todayEnd{
            return "Today at"
        } else if Int(self.timeIntervalSince1970) < tomorrowEnd{
            return "Tomorrow at"
        } else{
            return nil
        }
    }
    
    func dateEventDetailsString() -> String{
        
        let dateForm = NSDateFormatter()
        dateForm.dateStyle = .MediumStyle
        var dateDayString = dateForm.stringFromDate(self)
        
        let dateForm2 = NSDateFormatter()
        dateForm2.timeStyle = .ShortStyle
        let timeString = dateForm2.stringFromDate(self)
        
        let day = dayOfTheWeek()
        
        dateDayString.removeRange(dateDayString.endIndex.advancedBy(-6)..<dateDayString.endIndex)
        
        var todayTomorrow = isTodayOrTomorrow()
        
        if let string1 = todayTomorrow{
            return string1 + " " + timeString
        } else{
            return day + " " + dateDayString + ", " + timeString
        }
    }
}
