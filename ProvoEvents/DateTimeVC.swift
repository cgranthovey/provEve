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
        
//        let tapOut = UITapGestureRecognizer(target: self, action: #selector(DateTimeVC.dismissVC))
//        view.addGestureRecognizer(tapOut)
    }
    
    func dismissVC(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func set(){
        let nsDate = timeDatePicker.date
        delegate?.getTheDateTime(nsDate)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
//    
//    @IBAction func setTouchDown(sender: UIButton){
//        sender.backgroundColor = UIColor().boilerPlateColor(230, green: 81, blue: 0)
//    }
//    @IBAction func setTouchUpOutside(sender: UIButton){
//        sender.backgroundColor = UIColor().boilerPlateColor(239, green: 108, blue: 0)
//    }
//    
    
    
    @IBAction func cancel(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
//    @IBAction func cancelTouchDown(sender: UIButton){
//        sender.backgroundColor = UIColor().boilerPlateColor(136, green: 14, blue: 79)
//    }
//    @IBAction func cancelTouchUpOutside(sender: UIButton){
//        sender.backgroundColor = UIColor().boilerPlateColor(194, green: 24, blue: 91)
//    }

}
