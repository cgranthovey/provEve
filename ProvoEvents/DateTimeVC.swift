//
//  DateTimeVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/20/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol GetDateTime {
    func getTheDateTime(_ date: Date)
}

class DateTimeVC: UIViewController {

    var delegate: GetDateTime?
    var currentDate: Date?
    
    @IBOutlet weak var timeDatePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        timeDatePicker.datePickerMode = .dateAndTime
        timeDatePicker.minuteInterval = 5
        timeDatePicker.minimumDate = Date(timeIntervalSinceNow: 0)
        timeDatePicker.maximumDate = Date(timeIntervalSinceNow: 10510000)
        timeDatePicker.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
        if let curDate = currentDate{
            timeDatePicker.date = curDate
        }
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
    }
    
    func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func set(){
        let nsDate = timeDatePicker.date
        delegate?.getTheDateTime(nsDate)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
}
