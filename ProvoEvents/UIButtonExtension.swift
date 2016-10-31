//
//  UIButtonExtension.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/30/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import UIKit



extension UIButton {

    func changeImageAnimated(image: UIImage?) {
        guard let imageView = self.imageView, currentImage = imageView.image, newImage = image else {
            return
        }
//        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
//        crossFade.duration = 0.3
//        crossFade.fromValue = currentImage.CGImage
//        crossFade.toValue = newImage.CGImage
//        crossFade.removedOnCompletion = false
//        crossFade.fillMode = kCAFillModeForwards
//        imageView.layer.addAnimation(crossFade, forKey: "animateContents")
//        
        userInteractionEnabled = false
        UIView.animateWithDuration(0.5, animations: {
            self.alpha = 0
            }) { (true) in
                self.setImage(newImage, forState: .Normal)
                UIView.animateWithDuration(0.5, animations: {
                    self.alpha = 1
                }) { (true) in
                    self.userInteractionEnabled = true
                }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

extension Array where Element: Event{
    
    
    
    func NewDictWithTimeCategories() -> Dictionary<Int, [Event]>{
        
        var eventsToday = [Event]()
        var eventsTomorrow = [Event]()
        var eventsInTheNextWeek = [Event]()
        var eventsFuture = [Event]()
        
        var totalDict = Dictionary<Int, [Event]>()
        for event in self{
            if event.timeStampOfEvent < getTodaysEndTime(){
                eventsToday.append(event)
                totalDict[0] = eventsToday
            } else if event.timeStampOfEvent < getTomorrowsEndTime(){
                eventsTomorrow.append(event)
                totalDict[1] = eventsTomorrow
            } else if event.timeStampOfEvent < getEventsInNextWeekEndTime(){
                eventsInTheNextWeek.append(event)
                totalDict[2] = eventsInTheNextWeek
            } else{
                eventsFuture.append(event)
                totalDict[3] = eventsFuture
            }
        }
        
        return totalDict
    }
    
    func getTodaysEndTime() -> Int{
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let currentHour = calendar.component(.Hour, fromDate: currentDate)
        let currentMinute = calendar.component(.Minute, fromDate: currentDate)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(currentDate.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        return todayStartInSeconds + 86400 //86400 is seconds in a day
    }

    func getTomorrowsEndTime() -> Int{
        return getTodaysEndTime() + 86400
    }
    
    func getEventsInNextWeekEndTime() -> Int{
        return getTodaysEndTime() + 86400 * 6
    }
}



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


extension UIView{
    func addConstraintWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))       
    }
}

extension NSObject{
    func getCurrentDateInfo(){
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let currentHour = calendar.component(.Hour, fromDate: currentDate)
        let currentMinute = calendar.component(.Minute, fromDate: currentDate)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(currentDate.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        
        let todayEnd = todayStartInSeconds + 86400
    }
}


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















