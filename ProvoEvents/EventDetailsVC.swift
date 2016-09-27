//
//  EventDetailsVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/22/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import MessageUI
import EventKit


class EventDetailsVC: GeneralVC, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, getReminderInfo {

    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLoc: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var eventEmail: UIButton!
    
    @IBOutlet weak var bottomTextMessageBtn: UIButton!
    @IBOutlet weak var bottomCalenarBtn: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var event: Event!
    var img: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        bottomTextMessageBtn.imageView?.contentMode = .ScaleAspectFit
        bottomCalenarBtn.imageView?.contentMode = .ScaleAspectFit
        
        eventImg.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.toLargeImg))
        eventImg.addGestureRecognizer(tap)
        
        
        scrollView.delaysContentTouches = false
        setBottomButtons()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize.height = stackView.frame.height + 95
    }
    
    
    func setUpUI(){
        eventTitle.text = event.title
        eventDescription.text = event.description
        eventLoc.text = event.location
        eventDate.text = event.date
        eventEmail.setTitle(event.email, forState: .Normal)
        
        if event.email == nil || event.email == ""{
            emailStack.hidden = true
        }
        
        if let holdEventImg = event.imgURL{
            ImgCacheLoader.sharedLoader.imageForUrl(holdEventImg) { (image, url) in
                self.img = image
                self.eventImg.image = self.img!
                self.eventImg.roundCornersForAspectFit(5)
            }
        }else{
            eventImg.hidden = true
        }
    }
    
    
    //////////////////////////////////////////////////
    //set up bottom buttons
    
    func setBottomButtons(){
        
        bottomTextMessageBtn.adjustsImageWhenHighlighted = false        //prevents image from becoming darker when touched
        bottomCalenarBtn.adjustsImageWhenHighlighted = false
        
        bottomTextMessageBtn.addTarget(self, action: #selector(EventDetailsVC.holdDown(_:)), forControlEvents: .TouchDown)
        bottomCalenarBtn.addTarget(self, action: #selector(EventDetailsVC.holdDown(_:)), forControlEvents: .TouchDown)
        
        bottomCalenarBtn.addTarget(self, action: #selector(EventDetailsVC.holdReleaseOutside(_:)), forControlEvents: .TouchUpOutside)
        bottomTextMessageBtn.addTarget(self, action: #selector(EventDetailsVC.holdReleaseOutside(_:)), forControlEvents: .TouchUpOutside)
        
        bottomTextMessageBtn.addTarget(self, action: #selector(EventDetailsVC.textMessageReleaseInside(_:)), forControlEvents: .TouchUpInside)
        bottomCalenarBtn.addTarget(self, action: #selector(EventDetailsVC.showReminderVC), forControlEvents: .TouchUpInside)
    }
    
    func holdDown(sender: UIButton){
        if sender == bottomTextMessageBtn{
            sender.imageView?.image = UIImage(named: "textMessageColor")
        } else if sender == bottomCalenarBtn{
            sender.imageView?.image = UIImage(named: "calendarColor")
        }
    }
    
    func holdReleaseOutside(sender: UIButton){
        if sender == bottomTextMessageBtn{
            sender.imageView?.image = UIImage(named: "textMessageClear")
        } else if sender == bottomCalenarBtn{
            sender.imageView?.image = UIImage(named: "calendarClear")
        }
    }

    //////////////////////////////////////////////////
    //Notification access
    
//    func notificationsReleaseInside(sender: UIButton){
//        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Reminder)
//        switch status {
//        case EKAuthorizationStatus.Denied:
//            <#code#>
//        default:
//            <#code#>
//        }
//    }
//    
    
    //////////////////////////////////////////////////
    //Calendar access
    
    
    func showReminderVC(){
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        if status == EKAuthorizationStatus.Denied{
            self.accessPreviouslyDenied()
        } else if status == EKAuthorizationStatus.Authorized{
            performSegueWithIdentifier("ReminderVC", sender: nil)
        } else {
            requestAccessToCalendar()
        }
    }

    let eventStore = EKEventStore()
    func calendarReleaseInside(alarm: EKAlarm){     //delegate function
        let startDate: NSDate
        startDate = NSDate(timeIntervalSince1970: Double(event.timeStampOfEvent!))
        let endDate = startDate.dateByAddingTimeInterval(60 * 60)
        
        CreateEvent.instance.createEventFunc(self.eventStore, title: self.event.title, startDate: startDate, endDate: endDate, alarm: alarm)
        
        let img = UIImageView(image: UIImage(named: "checkmark"))
        img.showCheckmarkAnimatedTempImg(view, delay: 0.5)
        
    }
    
    func accessPreviouslyDenied(){
        let alertDeniedAccessCalendar = UIAlertController(title: "Access to calendar is denied", message: "Would you like to change your settings", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) in
            let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsURL{
                UIApplication.sharedApplication().openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alertDeniedAccessCalendar.addAction(settingsAction)
        alertDeniedAccessCalendar.addAction(cancelAction)
        
        presentViewController(alertDeniedAccessCalendar, animated: true, completion: nil)
    }
    
    func requestAccessToCalendar(){
        eventStore.requestAccessToEntityType(.Event) { (accessGranted: Bool, error: NSError?) in
            if accessGranted == true{
                self.performSegueWithIdentifier("ReminderVC", sender: nil)
            } else{
                print("user declined to let app use calendar.")
            }
        }
    }
    
    
    //////////////////////////////////////////////////
    //message controller
    
    func textMessageReleaseInside(sender: UIButton){
        var messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.body = "Hey would you want to go to \(event.title) on \(event.date) at \(event.location).\n \(event.description)"
        
        if MFMessageComposeViewController.canSendText(){
            self.presentViewController(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //////////////////////////////////////////////////
    //to large img
    func toLargeImg(){
        if img != nil{
            performSegueWithIdentifier("ImageLargeVC", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ImageLargeVC"{
            if let destVC = segue.destinationViewController as? ImageLargeVC{
                destVC.img = img
            }
        }
        
        if segue.identifier == "ReminderVC"{
            if let destVC = segue.destinationViewController as? ReminderVC{
                    destVC.delegate = self
            }
        }
    }
    
    
    //////////////////////////////////////////////////
    //to mail vc
    
    @IBAction func toMailVC(){
        var mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setSubject("Question regarding Provo Events Post - \(event.title)")
        mailVC.setToRecipients([event.email!])
        mailVC.setMessageBody("Hello I have a question regarding \(event.title)\n", isHTML: true)

        if MFMailComposeViewController.canSendMail(){
            self.presentViewController(mailVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}