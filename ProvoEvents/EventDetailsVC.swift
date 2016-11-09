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
import MapKit
import FirebaseDatabase
import FirebaseAuth

class EventDetailsVC: GeneralVC, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, getReminderInfo, yesSelectedProtocol{

    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLocBtn: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var eventEmail: UIButton!
    @IBOutlet weak var bottomTextMessageBtn: UIButton!
    @IBOutlet weak var bottomCalenarBtn: UIButton!
    @IBOutlet weak var garbageOutlet: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherIconImg: UIImageView!
    @IBOutlet weak var weatherStack: UIStackView!
    @IBOutlet weak var weatherDescLbl: UILabel!
    
    var event: Event!
    var img: UIImage!
    let deleteView = yesNoLauncher()
    var currentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        deleteView.delegate = self
        setUpUI()
        setBottomButtons()
        setUpImgs()
        scrollView.delaysContentTouches = false
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.resignKeyboard))
        view.addGestureRecognizer(tapDismiss)
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        if stackView.frame.height + 160 > self.view.frame.height{
            scrollView.contentSize.height = stackView.frame.height + 160
        } else{
            scrollView.contentSize.height = self.view.frame.height - 22
        }
        scrollView.contentSize.width = self.view.frame.width
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Set Up UI
    
    func setUpImgs(){
        heartBtn.adjustsImageWhenHighlighted = false
        if event.user != FIRAuth.auth()?.currentUser?.uid{
            garbageOutlet.hidden = true
        }
        
        eventImg.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.toLargeImg))
        eventImg.addGestureRecognizer(tap)
        
        if event.isLiked{
            heartBtn.setImage(UIImage(named: "heartFilled"), forState: .Normal)
            
        } else{
            heartBtn.setImage(UIImage(named: "heartEmpty"), forState: .Normal)
        }
    }

    func setUpUI(){
        eventTitle.text = event.title
        eventDescription.text = event.description
        eventLocBtn.setTitle(event.location, forState: .Normal)
        
        if event.pinInfoLongitude == nil || event.pinInfoLatitude == nil{
            eventLocBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            eventLocBtn.userInteractionEnabled = false
        }
        
        eventDate.text = dateString()//event.date
        eventEmail.setTitle(event.email, forState: .Normal)
        eventEmail.titleLabel?.numberOfLines = 1
        eventEmail.titleLabel?.adjustsFontSizeToFitWidth = true
        eventEmail.titleLabel?.lineBreakMode = .ByTruncatingMiddle
        eventEmail.titleLabel?.minimumScaleFactor = 0.7
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        
        if event.timeStampOfEvent > Int(NSDate().timeIntervalSince1970) + 86400 * 4{
            weatherStack.hidden = true
        } else{
            callWeather(event.timeStampOfEvent!)
        }
        
        if event.email == nil || event.email == ""{
            emailStack.hidden = true
        }
        
        if let holdEventImg = event.imgURL{
            ImgCacheLoader.sharedLoader.imageForUrl(holdEventImg) { (image, url) in
                if image != nil{            // without this if no internet connection we receive nil image causing crash.
                    self.img = image
                    self.eventImg.image = self.img!
                    self.eventImg.roundCornersForAspectFit(5)
                } else{
                    self.eventImg.hidden = true
                }
                self.activityIndicator.stopAnimating()
            }
        }else{
            eventImg.hidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    func setBottomButtons(){
        bottomTextMessageBtn.adjustsImageWhenHighlighted = false        //prevents image from becoming darker when touched
        bottomCalenarBtn.adjustsImageWhenHighlighted = false
        bottomTextMessageBtn.addTarget(self, action: #selector(EventDetailsVC.textMessageReleaseInside(_:)), forControlEvents: .TouchUpInside)
        bottomCalenarBtn.addTarget(self, action: #selector(EventDetailsVC.showReminderVC), forControlEvents: .TouchUpInside)
    }
    
    func dateString() -> String{
        let timeStamp = event.timeStampOfEvent
        let timeInterval = NSTimeInterval(timeStamp!)
        let myDate = NSDate(timeIntervalSince1970: timeInterval)
        return myDate.dateEventDetailsString()
    }
    
    func resignKeyboard(){
        view.endEditing(true)
    }
    
    func yesPressed() {
        DataService.instance.eventRef.child(event.key).removeValue()
        DataService.instance.currentUser.child("posts").child(event.key).removeValue()
        DataService.instance.geoFireRef.child(event.key).removeValue()
        DataService.instance.commentRef.child(event.key).removeValue()
        
        NSNotificationCenter.defaultCenter().postNotificationName("loadDataAfterNewEvent", object: event, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("eventDeleted", object: nil, userInfo: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
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
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //text message, garbage, heart pressed
    
    func textMessageReleaseInside(sender: UIButton){
        sender.backgroundColor = UIColor.clearColor()
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.body = "Hi would you want to go to \(event.title) on \(event.date) at \(event.location).\n\(event.description)"
        
        if MFMessageComposeViewController.canSendText(){
            self.presentViewController(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func garbageAction(sender: AnyObject){
        deleteView.showDeleteView(self.view, lblText: "Delete Event?")
    }
    @IBAction func heartBtnPressed(sender: AnyObject){
        if event.isLiked{
            heartBtn.setImage(UIImage(named: "heartEmpty"), forState: .Normal)
            event.adjustLikes(false)
            NSNotificationCenter.defaultCenter().postNotificationName("heartDeleted", object: self.event.key, userInfo: nil)
        } else{
            heartBtn.setImage(UIImage(named: "heartFilled"), forState: .Normal)
            event.adjustLikes(true)
            NSNotificationCenter.defaultCenter().postNotificationName("heartAdded", object: self.event, userInfo: nil)
        }
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //to MailVC, Location, CommentsVC, largeImg
    
    @IBAction func eventLocBtnPressed(sender: AnyObject){
        if let eventLong = event.pinInfoLongitude, let eventLat = event.pinInfoLatitude{
            let cord = CLLocationCoordinate2D(latitude: eventLat, longitude: eventLong)
            let placemark = MKPlacemark(coordinate: cord, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(event.title)"
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }

    @IBAction func toMailVC(){
        let mailVC = MFMailComposeViewController()
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
    
    @IBAction func toCommentsVC(sender: AnyObject){
        performSegueWithIdentifier("CommentsSegue", sender: nil)
    }
    
    func toLargeImg(){
        if img != nil{
            performSegueWithIdentifier("ImageLargeVC", sender: nil)
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //segue and popBack
    
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
        if segue.identifier == "CommentsSegue"{
            if let destVC = segue.destinationViewController as? EventDetailsCommVC{
                destVC.event = self.event
            }
        }
    }
    
    @IBAction func popBackBtn(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
}
