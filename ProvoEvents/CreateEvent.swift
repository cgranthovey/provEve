//
//  CreateEvent.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/26/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import EventKit

class CreateEvent {
    
    private static let _instance = CreateEvent()
    
    static var instance: CreateEvent{
        return _instance
    }
    

    var savedEventId: String = ""
    func createEventFunc(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate, alarm: EKAlarm?){
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        
        if let alarm1 = alarm {
            event.addAlarm(alarm1)
        }
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            savedEventId = event.eventIdentifier
        } catch{
            print("there was an error creating event")
        }
    }
    

}