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

class EventDetailsVC: GeneralVC, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITextViewDelegate,getReminderInfo, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLocBtn: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var eventEmail: UIButton!
    
    @IBOutlet weak var bottomTextMessageBtn: UIButton!
    @IBOutlet weak var bottomCalenarBtn: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var heartBtn: UIButton!
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentByUser: UITextView!
    
    
    var event: Event!
    var img: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()

        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.estimatedRowHeight = 40
        
        commentByUser.delegate = self
        commentsTableView.reloadData()
        
        bottomTextMessageBtn.imageView?.contentMode = .ScaleAspectFit
        bottomCalenarBtn.imageView?.contentMode = .ScaleAspectFit
        heartBtn.imageView?.contentMode = .ScaleAspectFit
        heartBtn.adjustsImageWhenHighlighted = false
        
        eventImg.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.toLargeImg))
        eventImg.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEventVC.makeLarger(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEventVC.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
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
        getComments()

    }
    
    func setUpUI(){
        eventTitle.text = event.title
        eventDescription.text = event.description
        eventLocBtn.setTitle(event.location, forState: .Normal)
        

        
        if event.pinInfoLongitude == nil || event.pinInfoLatitude == nil{
            eventLocBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            eventLocBtn.userInteractionEnabled = false
        }
        
        eventDate.text = event.date
        eventEmail.setTitle(event.email, forState: .Normal)
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        
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
    
    @IBOutlet weak var viewForScrollRect: UIView!
    var commentArray = [Comment]()
    
    
    
    
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func keyboardWillBeHidden(input: NSNotification){
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentInset.top = 22
    }
    
    func makeLarger(input: NSNotification){
        
        if let userInfo = input.userInfo{
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]
            let keyboardRect = keyboardFrame?.CGRectValue()
            if let keyboardHeight = keyboardRect?.height{
                scrollView.contentInset.bottom = (keyboardHeight )
                
                performSelector(#selector(EventDetailsVC.moveTextFieldIntoView))
            }
        }
    }
    
    func moveTextFieldIntoView(){
        scrollView.scrollRectToVisible(viewForScrollRect.frame, animated: true)
    }
    
    @IBAction func submitComment(sender: UITextView){
        let date = NSDate()
        let timeIntervalSince1970 = Int(date.timeIntervalSince1970)
        
        let key = DataService.instance.commentRef.child(event.key).childByAutoId().key
        
        if commentByUser.text == nil || commentByUser.text == ""{
            generalAlert("Error", message: "The comment field is not filled out")
        } else{
            print(FIRAuth.auth()?.currentUser?.uid)
            let setComment: Dictionary<String, AnyObject> = ["userId": (FIRAuth.auth()?.currentUser?.uid)!, "comment": commentByUser.text, "timeStamp": timeIntervalSince1970]
            DataService.instance.commentRef.child(event.key).child(key).setValue(setComment)
            DataService.instance.currentUser.child("comments").child(event.key).child(key).setValue("True")
        }
    }
    
    
    
    @IBOutlet var tableHeight: NSLayoutConstraint!
    
    func getComments(){
        print("hope")
        DataService.instance.commentRef.child(event.key).queryOrderedByChild("timeStamp").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snapshot in snapshots{
                    if let snap = snapshot.value as? Dictionary<String, AnyObject>{
                        let comment = Comment(dict: snap)
                        self.commentArray.append(comment)
                        print("count of snaps")
                    }
                }
            }
            self.commentsTableView.reloadData()
            self.updateViewConstraints()
            print("yo")

            self.scrollView.contentSize.height = self.scrollView.contentSize.height + self.tableHeight.constant
            print(self.commentArray.count)
        })
        print("yodle")

  //      commentsTableView.intrinsicContentSize()
        
     //   self.updateViewConstraints()
        
  //      self.tableHeight.constant = self.preferredContentSize.height
//        scrollView.contentInset.bottom = tableHeight.constant
        //self.commentsTableView.reloadData()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        print("hello \(tableHeight.constant)")
        tableHeight.constant = commentsTableView.contentSize.height + CGFloat(15 * commentArray.count)
        print("hey ther \(tableHeight.constant)")
    }
    
    
    var totCellHeight = 0
    func calcTotalCellHeight(){
        
        for i in 0..<commentArray.count{
            let index = NSIndexPath(forRow: i, inSection: 0)
            if let cell = commentsTableView.cellForRowAtIndexPath(index){
                totCellHeight = totCellHeight + Int(cell.intrinsicContentSize().height)
            }
        }
        print("totCellHeight \(totCellHeight)")
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("my count \(commentArray.count)")
        if let cell = tableView.dequeueReusableCellWithIdentifier("commentsCell") as? CommentsCell{
            cell.configureCell(commentArray[indexPath.row])
            cell.backgroundColor = UIColor.yellowColor()
            print("cHeight \(cell.frame.height)")
            return cell
        } else{
            return UITableViewCell()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("number of sections")
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of rows \(commentArray.count)")
        if commentArray.count > 0 {
            commentsTableView.hidden = false
        } else{
            commentsTableView.hidden = true
        }
        return commentArray.count
    }

}










extension EventDetailsVC{
    
    
    
}























