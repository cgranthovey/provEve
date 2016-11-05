//
//  ReminderVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/26/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import EventKit

protocol getReminderInfo {
    func calendarReleaseInside(timeInterval: EKAlarm)
}


class ReminderVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var delegate: getReminderInfo?

    var rowSelected = 0
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var arrayOfTimesForPickerView = ["5 minutes before", "15 minutes before", "30 minutes before", "1 hour before", "2 hours before", "4 hours before", "12 hours before", "24 hours before"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
    }

    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOfTimesForPickerView[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rowSelected = row
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfTimesForPickerView.count
    }
    
    @IBAction func set(sender: AnyObject){
        var alarm = EKAlarm()
        switch rowSelected {
        case 0:
            alarm.relativeOffset = -60 * 5
        case 1:
            alarm.relativeOffset = -60 * 15
        case 2:
            alarm.relativeOffset = -60 * 30
        case 3:
            alarm.relativeOffset = -60 * 60
        case 4:
            alarm.relativeOffset = -60 * 60 * 2
        case 5:
            alarm.relativeOffset = -60 * 60 * 4
        case 6:
            alarm.relativeOffset = -60 * 60 * 12
        case 7:
            alarm.relativeOffset = -60 * 60 * 24
        default:
            alarm.relativeOffset = -60 * 60 * 6
        }
        
        delegate?.calendarReleaseInside(alarm)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
