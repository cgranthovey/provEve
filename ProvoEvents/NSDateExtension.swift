//
//  NSDateExtension.swift
//  Ibento
//
//  Created by Chris Hovey on 11/5/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

extension Date {
    
    func weekInfo() -> String{
        let format = DateFormatter()
        format.dateStyle = .short
        var day = format.string(from: self)
        day.removeSubrange(day.index(day.endIndex, offsetBy: -3)..<day.endIndex)
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
        
        let calendar: Calendar = Calendar.current
        let components: DateComponents = (calendar as NSCalendar).components(.weekday, from: self)
        return weekdays[components.weekday! - 1]
    }
    
    func hourOfDay() -> Int {
        let calendar = Calendar.current
        let hour = (calendar as NSCalendar).component(.hour, from: self)
        return hour
    }
    
    
    func isTodayOrTomorrow() -> String?{
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = (calendar as NSCalendar).component(.hour, from: currentDate)
        let currentMinute = (calendar as NSCalendar).component(.minute, from: currentDate)
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
        
        let dateForm = DateFormatter()
        dateForm.dateStyle = .medium
        var dateDayString = dateForm.string(from: self)
        
        let dateForm2 = DateFormatter()
        dateForm2.timeStyle = .short
        let timeString = dateForm2.string(from: self)
        
        let day = dayOfTheWeek()
        
        dateDayString.removeSubrange(dateDayString.index(dateDayString.endIndex, offsetBy: -6)..<dateDayString.endIndex)
        
        let todayTomorrow = isTodayOrTomorrow()
        
        if let string1 = todayTomorrow{
            return string1 + " " + timeString
        } else{
            return day! + " " + dateDayString + ", " + timeString
        }
    }
}
