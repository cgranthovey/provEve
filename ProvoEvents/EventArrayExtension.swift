//
//  EventArrayExtension.swift
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
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = (calendar as NSCalendar).component(.hour, from: currentDate)
        let currentMinute = (calendar as NSCalendar).component(.minute, from: currentDate)
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
