//
//  EventDetailsVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/22/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI
import EventKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    override func viewWillAppear(_ animated: Bool) {
        eventImgHeight = eventImg.frame.height
        eventImgWidth = eventImg.frame.width
        if darkView != nil{
            poppedBackFromImg()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
            garbageOutlet.isHidden = true
        }
        
        eventImg.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.toLargeImg))
        eventImg.addGestureRecognizer(tap)
        
        if event.isLiked{
            heartBtn.setImage(UIImage(named: "heartFilled"), for: UIControlState())
            
        } else{
            heartBtn.setImage(UIImage(named: "heartEmpty"), for: UIControlState())
        }
    }

    func setUpUI(){
        eventTitle.text = event.title
        eventDescription.text = event.description
        eventLocBtn.setTitle(event.location, for: UIControlState())
        eventLocBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        if event.pinInfoLongitude == nil || event.pinInfoLatitude == nil{
            eventLocBtn.setTitleColor(UIColor.black, for: UIControlState())
            eventLocBtn.isUserInteractionEnabled = false
        }
        
        eventDate.text = dateString()//event.date
        eventEmail.setTitle(event.email, for: UIControlState())
        eventEmail.titleLabel?.numberOfLines = 1
        eventEmail.titleLabel?.adjustsFontSizeToFitWidth = true
        eventEmail.titleLabel?.lineBreakMode = .byTruncatingMiddle
        eventEmail.titleLabel?.minimumScaleFactor = 0.7
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        
        if event.timeStampOfEvent > Int(Date().timeIntervalSince1970) + 86400 * 4{
            weatherStack.isHidden = true
        } else{
            callWeather(event.timeStampOfEvent!)
        }
        
        if event.email == nil || event.email == ""{
            emailStack.isHidden = true
        }
        
        if let holdEventImg = event.imgURL{
            print("img cache loader")
            
            let url = URL(string: holdEventImg)
            self.eventImg.ll(with: url, completed: { (image: UIImage?, error: Error?, cache: SDImageCacheType, url: URL?) in
                if image == nil{
                    self.eventImg.isHidden = true
                }
                self.eventImg.roundCornersForAspectFit(5)
                self.activityIndicator.stopAnimating()
            })
        }else{
            eventImg.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    func setBottomButtons(){
        bottomTextMessageBtn.adjustsImageWhenHighlighted = false        //prevents image from becoming darker when touched
        bottomCalenarBtn.adjustsImageWhenHighlighted = false
        bottomTextMessageBtn.addTarget(self, action: #selector(EventDetailsVC.textMessageReleaseInside(_:)), for: .touchUpInside)
        bottomCalenarBtn.addTarget(self, action: #selector(EventDetailsVC.showReminderVC), for: .touchUpInside)
    }
    
    func dateString() -> String{
        let timeStamp = event.timeStampOfEvent
        let timeInterval = TimeInterval(timeStamp!)
        let myDate = Date(timeIntervalSince1970: timeInterval)
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
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadDataAfterNewEvent"), object: event, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "eventDeleted"), object: nil, userInfo: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Calendar access
    
    func showReminderVC(){
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        if status == EKAuthorizationStatus.denied{
            self.accessPreviouslyDenied()
        } else if status == EKAuthorizationStatus.authorized{
            performSegue(withIdentifier: "ReminderVC", sender: nil)
        } else {
            requestAccessToCalendar()
        }
    }

    let eventStore = EKEventStore()
    func calendarReleaseInside(_ alarm: EKAlarm){     //delegate function
        let startDate: Date
        startDate = Date(timeIntervalSince1970: Double(event.timeStampOfEvent!))
        let endDate = startDate.addingTimeInterval(60 * 60)
        
        CreateEvent.instance.createEventFunc(self.eventStore, title: self.event.title, startDate: startDate, endDate: endDate, alarm: alarm)
        
        let img = UIImageView(image: UIImage(named: "checkmark"))
        img.showCheckmarkAnimatedTempImg(view, delay: 0.5)
    }
    
    func accessPreviouslyDenied(){
        let alertDeniedAccessCalendar = UIAlertController(title: "Access to calendar is denied", message: "Would you like to change your settings", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsURL{
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertDeniedAccessCalendar.addAction(settingsAction)
        alertDeniedAccessCalendar.addAction(cancelAction)
        
        present(alertDeniedAccessCalendar, animated: true, completion: nil)
    }
    
    func requestAccessToCalendar(){
        
        eventStore.requestAccess(to: .event, completion:  {(granted: Bool, error: Error?) in
            if granted == true{
                DispatchQueue.main.async(execute: { 
                    self.performSegue(withIdentifier: "ReminderVC", sender: nil)
                })
            } else{
                print("user declined to let app use calendar.")
            }
        } )
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //text message, garbage, heart pressed
    
    func textMessageReleaseInside(_ sender: UIButton){
        sender.backgroundColor = UIColor.clear
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        
        
        messageVC.body = "Hi would you want to go to \(event.title) on \(event.date) at \(event.location).\n\(event.description!)"
        
        if MFMessageComposeViewController.canSendText(){
            self.present(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func garbageAction(_ sender: AnyObject){
        deleteView.showDeleteView(self.view, lblText: "Delete Event?")
    }
    @IBAction func heartBtnPressed(_ sender: AnyObject){
        if event.isLiked{
            heartBtn.setImage(UIImage(named: "heartEmpty"), for: UIControlState())
            event.adjustLikes(false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "heartDeleted"), object: self.event.key, userInfo: nil)
        } else{
            heartBtn.setImage(UIImage(named: "heartFilled"), for: UIControlState())
            event.adjustLikes(true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "heartAdded"), object: self.event, userInfo: nil)
        }
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //to MailVC, Location, CommentsVC, largeImg
    
    @IBAction func eventLocBtnPressed(_ sender: AnyObject){
        if let eventLong = event.pinInfoLongitude, let eventLat = event.pinInfoLatitude{
            let cord = CLLocationCoordinate2D(latitude: eventLat, longitude: eventLong)
            let placemark = MKPlacemark(coordinate: cord, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(event.title)"
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }

    @IBAction func toMailVC(){
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setSubject("Question regarding Provo Events Post - \(event.title)")
        mailVC.setToRecipients([event.email!])
        mailVC.setMessageBody("Hello I have a question regarding \(event.title)\n", isHTML: true)

        if MFMailComposeViewController.canSendMail(){
            self.present(mailVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toCommentsVC(_ sender: AnyObject){
        performSegue(withIdentifier: "CommentsSegue", sender: nil)
    }
    
    var darkView: UIView!
    var zoomImgView = UIImageView()
    var animationDuration = 0.4
    var originalFrame = CGRect()
    var eventImgWidth: CGFloat!
    var eventImgHeight: CGFloat!
    
    func toLargeImg(){
        self.view.isUserInteractionEnabled = false
        if let img = self.eventImg.image{
            print("frame \(eventImg.frame)")
            if let startingFrame = eventImg.superview?.convert(eventImg.frame, to: nil){
                zoomImgView.frame = AVMakeRect(aspectRatio: img.size, insideRect: eventImg.frame)
                
                zoomImgView.frame.origin.y = startingFrame.origin.y
                let xOffset = (eventImg.frame.width - zoomImgView.frame.width) / 2
                zoomImgView.frame.origin.x = startingFrame.origin.x + xOffset
                originalFrame = startingFrame
                
                zoomImgView.layer.cornerRadius = 5
                zoomImgView.contentMode = .scaleAspectFit
                zoomImgView.clipsToBounds = true
                zoomImgView.image = img
                eventImg.alpha = 0
                view.addSubview(zoomImgView)
                
                darkView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                darkView.alpha = 0
                darkView.backgroundColor = UIColor.black
                
                perform(#selector(EventDetailsVC.segueImg), with: self, afterDelay: animationDuration * 2)

                UIView.animate(withDuration: animationDuration, animations: {
                    self.view.addSubview(self.darkView)
                    self.view.bringSubview(toFront: self.zoomImgView)
                    
                    let h = self.zoomImgView.bounds.height * UIScreen.main.bounds.width / self.zoomImgView.bounds.width
                    let y = self.view.bounds.height / 2 - h / 2

                    self.zoomImgView.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: h)
                    
//                    self.zoomImgView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
                    
                    }, completion: { (true) in
                        UIView.animate(withDuration: self.animationDuration, animations: {
                            self.darkView.alpha = 1
                            }, completion: { (true) in
                        })
                })
            }
        }
    }
    
    func segueImg(){
        self.performSegue(withIdentifier: "ImageLargeVC", sender: nil)
    }
    
    func poppedBackFromImg(){
        
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.darkView.alpha = 0
            }, completion: { (true) in
                UIView.animate(withDuration: self.animationDuration, animations: {
                    
                    self.zoomImgView.frame = CGRect(x: self.originalFrame.origin.x, y: self.originalFrame.origin.y, width: self.eventImg.frame.width, height: self.eventImg.frame.height)    
                    }, completion: { (true) in
                    self.eventImg.alpha = 1.0
                    self.zoomImgView.removeFromSuperview()
                    self.darkView.removeFromSuperview()
                    self.view.isUserInteractionEnabled = true
                })
        }) 
    }
    
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //segue and popBack
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageLargeVC"{
            if let destVC = segue.destination as? ImageLargeVC{
                destVC.img = self.eventImg.image
            }
        }
        
        if segue.identifier == "ReminderVC"{
            if let destVC = segue.destination as? ReminderVC{
                    destVC.delegate = self
            }
        }
        if segue.identifier == "CommentsSegue"{
            if let destVC = segue.destination as? EventDetailsCommVC{
                destVC.event = self.event
            }
        }
    }
    
    @IBAction func popBackBtn(_ sender: AnyObject){
        _ = self.navigationController?.popViewController(animated: true)
    }
}
