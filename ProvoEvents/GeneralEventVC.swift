//
//  GeneralEventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/5/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Foundation

class GeneralEventVC: UIViewController {

    var todaysStartTime: Int!
    var name = String()
    var EventsCategorized = [Int: [Event]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        todaysStartTime = self.getTodaysStartTime()
    }

    func getTodaysStartTime() -> Int{
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let currentHour = calendar.component(.Hour, fromDate: currentDate)
        let currentMinute = calendar.component(.Minute, fromDate: currentDate)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(currentDate.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        return todayStartInSeconds
    }
    
    func ArrayForSection(section: Int) -> [Event]{
        var findKeys = Array(EventsCategorized.keys)
        findKeys.sortInPlace()
        if findKeys[section] == 0{
            return (EventsCategorized[0])!
        } else if findKeys[section] == 1{
            return (EventsCategorized[1])!
        } else if findKeys[section] == 2{
            return (EventsCategorized[2])!
        } else{
            return (EventsCategorized[3])!
        }
    }
    
    func numberOfRowsForSection(section: Int) -> Int{
        var findKeys = Array(EventsCategorized.keys)
        findKeys.sortInPlace()
        
        if findKeys[section] == 0{
            return (EventsCategorized[0]?.count)!
        } else if findKeys[section] == 1{
            return (EventsCategorized[1]?.count)!
        } else if findKeys[section] == 2{
            return (EventsCategorized[2]?.count)!
        } else{
            return (EventsCategorized[3]?.count)!
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //tableView
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var findKeys = Array(EventsCategorized.keys)
        findKeys.sortInPlace()
        if findKeys[section] == 0{
            return "Today"
        } else if findKeys[section] == 1{
            return "Tomorrow"
        } else if findKeys[section] == 2{
            return "This Week"
        } else{
            return "Upcoming"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let EventForSpecificTimeArray = ArrayForSection(indexPath.section)
        let myEvent = EventForSpecificTimeArray[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as? EventCell{
            cell.configureCell(myEvent)
            return cell
        } else{
            
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsForSection(section)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let eventArray = ArrayForSection(indexPath.section)
        performSegueWithIdentifier("EventDetailsVC", sender: eventArray[indexPath.row])
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return EventsCategorized.count
    }
}
