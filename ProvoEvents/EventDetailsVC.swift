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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        deleteView.delegate = self

        setUpUI()
        
        

        bottomTextMessageBtn.imageView?.contentMode = .ScaleAspectFit
        bottomCalenarBtn.imageView?.contentMode = .ScaleAspectFit
        heartBtn.imageView?.contentMode = .ScaleAspectFit
        garbageOutlet.imageView?.contentMode = .ScaleAspectFit
        heartBtn.adjustsImageWhenHighlighted = false
        
        if event.user != FIRAuth.auth()?.currentUser?.uid{
            garbageOutlet.hidden = true
        }
        
        
        eventImg.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.toLargeImg))
        eventImg.addGestureRecognizer(tap)
        
        scrollView.delaysContentTouches = false
        setBottomButtons()
        
        if event.isLiked{
            print("it is liked")
            heartBtn.setImage(UIImage(named: "heartFilled"), forState: .Normal)
            
        } else{
            print("it is not liked")
            heartBtn.setImage(UIImage(named: "heartEmpty"), forState: .Normal)
        }

        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.resignKeyboard))
        view.addGestureRecognizer(tapDismiss)
        
       // scrollView.contentSize.height = 800
    }
    
    
    var currentView: UIView!
    func tapToDismissKeyboard(myView: UIView){

    }
    func resignKeyboard(){
        view.endEditing(true)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {

    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if stackView.frame.height + 160 > self.view.frame.height{
            scrollView.contentSize.height = stackView.frame.height + 160
        } else{
            scrollView.contentSize.height = self.view.frame.height - 22
        }
        scrollView.contentSize.width = self.view.frame.width
    }
    
    
    @IBAction func garbageAction(sender: AnyObject){
        deleteView.showDeleteView(self.view, lblText: "Delete Event?")
    }
    
    func yesPressed() {
    
        DataService.instance.eventRef.child(event.key).removeValue()
        DataService.instance.currentUser.child("posts").child(event.key).removeValue()
        DataService.instance.geoFireRef.child(event.key).removeValue()
        DataService.instance.commentRef.child(event.key).removeValue()
        
        print("yes called!!!")
        
        NSNotificationCenter.defaultCenter().postNotificationName("loadDataAfterNewEvent", object: event, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("eventDeleted", object: nil, userInfo: nil)
        self.navigationController?.popViewControllerAnimated(true)
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
                self.img = image
                self.eventImg.image = self.img!
                self.eventImg.roundCornersForAspectFit(5)
                self.activityIndicator.stopAnimating()
            }
        }else{
            eventImg.hidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    
    
    func dateString() -> String{
        let timeStamp = event.timeStampOfEvent
        let timeInterval = NSTimeInterval(timeStamp!)
        let myDate = NSDate(timeIntervalSince1970: timeInterval)
        
        return myDate.dateEventDetailsString()
        
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
    //Like Heart access
    

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
        if segue.identifier == "CommentsSegue"{
            if let destVC = segue.destinationViewController as? EventDetailsCommVC{
                destVC.event = self.event
            }
        }
    }
    
    //////////////////////////////////////////////////
    //to mail vc
    @IBAction func eventLocBtnPressed(sender: AnyObject){
        
        //google
        
        if let eventLong = event.pinInfoLongitude, let eventLat = event.pinInfoLatitude{
            
            
            print("cats \(event.pinInfoLatitude!) \(event.pinInfoLongitude!)")
            
            if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
                UIApplication.sharedApplication().openURL(NSURL(string:
                    "comgooglemaps://?saddr=&daddr=\(eventLat),\(eventLong)")!)
  //              "comgooglemaps://?saddr=&daddr=\(eventLat),\(eventLong)&directionsmode=driving")!)

                
            } else {
                print("Can't use comgooglemaps://, trying apple maps")
                let cord = CLLocationCoordinate2D(latitude: eventLat, longitude: eventLong)
                let placemark = MKPlacemark(coordinate: cord, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = "Christopher's Neighborhood"
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
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
    
    
    @IBAction func toCommentsVC(sender: AnyObject){
        performSegueWithIdentifier("CommentsSegue", sender: nil)
    }
    


}










extension EventDetailsVC{
    
    
    
}























