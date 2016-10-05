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
    
    
    
    func NewArrayWithTimeCategories() -> [[Event]]{
        
        var eventsToday = [Event]()
        var eventsTomorrow = [Event]()
        var eventsInTheNextWeek = [Event]()
        var eventsFuture = [Event]()
        
        for event in self{
            if event.timeStampOfEvent < getTodaysEndTime(){
                eventsToday.append(event)
            } else if event.timeStampOfEvent < getTodaysEndTime(){
                eventsTomorrow.append(event)
            } else if event.timeStampOfEvent < getEventsInNextWeekEndTime(){
                eventsInTheNextWeek.append(event)
            } else{
                eventsFuture.append(event)
            }
        }
        let totalArray = [eventsToday, eventsTomorrow, eventsInTheNextWeek, eventsFuture]
        return totalArray
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
























