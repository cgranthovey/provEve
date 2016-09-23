//
//  DateTimeVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/20/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

protocol GetDateTime {
    func getTheDateTime(date: NSDate)
}

class DateTimeVC: UIViewController {

    @IBOutlet weak var timeDatePicker: UIDatePicker!
    
    var delegate: GetDateTime?
    var currentDate: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        timeDatePicker.datePickerMode = .DateAndTime
        timeDatePicker.minuteInterval = 5
        timeDatePicker.minimumDate = NSDate(timeIntervalSinceNow: 0)
        timeDatePicker.maximumDate = NSDate(timeIntervalSinceNow: 10510000)
        timeDatePicker.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
        if let curDate = currentDate{
            timeDatePicker.date = curDate
        }
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        
        let tapOut = UITapGestureRecognizer(target: self, action: #selector(DateTimeVC.dismissVC))
        view.addGestureRecognizer(tapOut)
    }
    
    func dismissVC(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func set(){
        print("I'm called")
        let nsDate = timeDatePicker.date
        delegate?.getTheDateTime(nsDate)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(){
        print("hehe")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}