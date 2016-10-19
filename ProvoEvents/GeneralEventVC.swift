//
//  GeneralEventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/5/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class GeneralEventVC: UIViewController {

    var todaysStartTime: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todaysStartTime = self.getTodaysStartTime()
        // Do any additional setup after loading the view.
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

}
