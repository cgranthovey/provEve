//
//  AddEventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/19/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

protocol HandleGetEventLoc {
    func getEventLoc(address:String?, name: String?, longitude: Double?, latitude: Double?, placemark: MKPlacemark?)
}

class AddEventVC: GeneralVC, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, GetDateTime, HandleGetEventLoc {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: LoginTextField!
    @IBOutlet weak var locationTextField: LoginTextField!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var descriptionTextView: TextView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var dateButtonTappedOutlet: UIButton!
    @IBOutlet weak var setPinBtnOutlet: UIButton!
    @IBOutlet weak var eventImgBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var submitOutlet: UIButton!
    @IBOutlet weak var topViewScroll: UIView!

    var imgPickerController: UIImagePickerController!
    var viewScrollHeight = UIView()
    var correctCollectionViewWidth = CGFloat(300)
    var activeTextField: UITextField!
    var activeTextView: UITextView!
    var myKeyBoardHeight: CGFloat!
    var holdKeyInCaseError: String!
    var imgSuccess: UIImageView!
    var img = ["football", "outdoors", "service", "theater", "dance", "art", "prayer", "music", "book", "sandwich"]
    var lbl = ["Sports", "Outdoors", "Service", "Theater/Cinema", "Dance", "Art", "Religous", "Music", "Education", "Culinary"]
    var selectedCellInt: Int!
    var cellHold = MapPinCell()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDelegates()
        setUpScrollAndCollection()
        setUpEventImgBtn()
        imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEventVC.makeLarger(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEventVC.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        print(collection.frame.width)
        correctCollectionViewWidth = collection.frame.width
        viewScrollHeight.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: scrollView.contentSize.height)
        viewScrollHeight.backgroundColor = UIColor.clearColor()
        self.scrollView.addSubview(viewScrollHeight)
        scrollView.sendSubviewToBack(viewScrollHeight)
        setUpTaps()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "addEventSubmitSlide", object: nil)
    }
    
    func setUpScrollAndCollection(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        collection.collectionViewLayout = layout
        collection.backgroundColor = UIColor.clearColor()
        self.collection.allowsSelection = true
        
        scrollView.contentSize.height = 760
        scrollView.contentSize.width = view.frame.width
        scrollView.directionalLockEnabled = true
    }
    
    func setUpDelegates(){
        collection.delegate = self
        collection.dataSource = self
        descriptionTextView.delegate = self
        titleTextField.delegate = self
        locationTextField.delegate = self
        emailTextField.delegate = self
    }

    func setUpEventImgBtn(){
        eventImg.image = UIImage(named: "photoAlbumColor")
        eventImgBtn.addTarget(self, action: #selector(AddEventVC.eventImgBtnTouchDown), forControlEvents: .TouchDown)
        eventImgBtn.addTarget(self, action: #selector(AddEventVC.eventImgBtnTouchUpInside), forControlEvents: .TouchUpInside)
        eventImgBtn.addTarget(self, action: #selector(AddEventVC.touchUpOutside), forControlEvents: .TouchUpOutside)
    }
    
    func setUpTaps(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.dismissKeyboard))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.dismissKeyboard))
        viewScrollHeight.addGestureRecognizer(tap)
        topView.addGestureRecognizer(tap2)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //animate image btn touch, imagePickerController
    
    func eventImgBtnTouchDown(){
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
            self.eventImg.transform = CGAffineTransformMakeScale(1.05, 1.05)
            }, completion: nil)
    }
    
    func eventImgBtnTouchUpInside(){
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
            self.eventImg.transform = CGAffineTransformMakeScale(0.85, 0.85)
        }) { (true) in
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { 
                self.eventImg.transform = CGAffineTransformMakeScale(1, 1)
                self.imageTapped()

                }, completion: { (true) in
            })
        }
    }
    
    func touchUpOutside(){
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { 
            self.eventImg.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    
    func imageTapped(){
        self.presentViewController(imgPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPickerController.dismissViewControllerAnimated(true, completion: nil)
        eventImg.image = image
        eventImg.roundCornersForAspectFit(5)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imgPickerController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //active textfield/view.  Increase scroll view size
    
    func keyboardWillBeHidden(input: NSNotification){
        scrollView.contentInset.bottom = UIEdgeInsetsZero.bottom    //without this the views go up a bit
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        activeTextField = nil
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        activeTextView = textView
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        activeTextView = nil
        return true
    }
    
    func resignAllFirstResponders(){
        titleTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    func dismissKeyboard(){
        resignAllFirstResponders()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func makeLarger(input: NSNotification){
        scrollView.contentInset.right = UIEdgeInsetsZero.right    //without this the views go up a few pixels

        if let userInfo = input.userInfo{
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]
            let keyboardRect = keyboardFrame?.CGRectValue()
            if let keyboardHeight = keyboardRect?.height{
                myKeyBoardHeight = keyboardHeight
                scrollView.contentInset.bottom = keyboardHeight
                var aRect = self.view.frame
                aRect.size.height = aRect.size.height - keyboardHeight
                
                if activeTextField != nil{
                    print("hey")
                    let point = activeTextField.frame.origin
                    if !CGRectContainsPoint(aRect, point){
                        performSelector(#selector(AddEventVC.moveTextFieldIntoView), withObject: nil, afterDelay: 0.0)
                    }
                } else if activeTextView != nil{
                    let point = activeTextView.frame.origin
                    if !CGRectContainsPoint(aRect, point){
                        performSelector(#selector(AddEventVC.moveTextFieldIntoView), withObject: nil, afterDelay: 0.0)
                    }
                }
            }
        }
    }
    
    func moveTextFieldIntoView(){
        print("none")
        if activeTextField != nil{
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)       //for this to work you have to remember in addition to setting conent height to make sure content width is at least at wide as view.frame.width
        } else if activeTextView != nil{
            scrollView.scrollRectToVisible(submitOutlet.frame, animated: true)
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //event Loc
    var pinLocDict: Dictionary<String, AnyObject>! = [:]
    var holdPlacemark: MKPlacemark!
    var holdAddress: String!
    var coordinateOfEvent: CLLocationCoordinate2D!
    func getEventLoc(address: String?, name: String?, longitude: Double?, latitude: Double?, placemark: MKPlacemark?) {
        
        if let placemark = placemark?.coordinate{
            coordinateOfEvent = placemark
        }
        
        if let address = address, let name = name{
            if address.containsString(name){
                setPinBtnOutlet.setTitle(address, forState: .Normal)
            } else{
                setPinBtnOutlet.setTitle("\(name) - \(address)", forState: .Normal)
            }
        } else if let coordLat = latitude, let coordLong = longitude{
            setPinBtnOutlet.setTitle("\(coordLat), \(coordLong)", forState: .Normal)
        } else{
            setPinBtnOutlet.setTitle("SET PIN", forState: .Normal)
        }

        holdAddress = address
        holdPlacemark = placemark
        pinLocDict["address"] = address
        pinLocDict["name"] = name
        pinLocDict["longitude"] = longitude
        pinLocDict["latitude"] = latitude
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Date and Time
    
    @IBAction func dateButtonTapped(sender: UIButton){
        resignAllFirstResponders()
        performSegueWithIdentifier("DateTimeVC", sender: nil)
    }
    
    @IBAction func addPinButtonTapped(sender: UIButton){
        resignAllFirstResponders()
        performSegueWithIdentifier("MapVC", sender: nil)
    }
    
    var currentDate: NSDate?
    var dateString: String!
    var timeStampOfEvent: Int!
    func getTheDateTime(date: NSDate){
        timeStampOfEvent = Int(date.timeIntervalSince1970)
        currentDate = date
        
        let dateForm = NSDateFormatter()
        dateForm.dateStyle = .MediumStyle
        var dateDayString = dateForm.stringFromDate(date)
        
        let dateForm2 = NSDateFormatter()
        dateForm2.timeStyle = .ShortStyle
        let timeString = dateForm2.stringFromDate(date)
        
        dateDayString.removeRange(dateDayString.endIndex.advancedBy(-6)..<dateDayString.endIndex)
        dateString = dateDayString + ", " + timeString
        dateButtonTappedOutlet.setTitle(dateString, forState: .Normal)
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //to firebase then Reset
    @IBAction func submit(sender: UIButton){
        resignAllFirstResponders()
        performSelector(#selector(AddEventVC.toFireBase), withObject: nil, afterDelay: 0)
    }
    var loadingView: UIView!
    var spinIndicator: UIActivityIndicatorView!

    func popOut(){
        NSNotificationCenter.defaultCenter().postNotificationName("addEventSubmitSlide", object: nil)
        performSelector(#selector(AddEventVC.reset), withObject: nil, afterDelay: 0.5)
    }
    
    func reset(){
        if spinIndicator != nil{
            spinIndicator.removeFromSuperview()
        }
        if imgSuccess != nil{
            imgSuccess.removeFromSuperview()
        }
        if loadingView != nil{
            loadingView.removeFromSuperview()
        }
        
        scrollView.scrollRectToVisible(topViewScroll.frame, animated: false)
        titleTextField.text = ""
        dateString = nil
        locationTextField.text = ""
        emailTextField.text = ""
        descriptionTextView.text = ""
        setPinBtnOutlet.setTitle("ADD PIN", forState: .Normal)
        dateButtonTappedOutlet.setTitle("DATE/TIME", forState: .Normal)
        eventImg.image = UIImage(named: "photoAlbumColor")
        eventImg.roundCornersForAspectFit(0)
        cellHold.backgroundColor = UIColor.clearColor()
        selectedCellInt = nil
        pinLocDict = [:]
        holdPlacemark = nil
        holdAddress = nil
        coordinateOfEvent = CLLocationCoordinate2D()
        currentDate = NSDate()
        timeStampOfEvent = Int()
    }

    func makeSuccessView(){
        imgSuccess = UIImageView(image: UIImage(named: "whiteCheck"))
        NSNotificationCenter.defaultCenter().postNotificationName("loadDataAfterNewEvent", object: nil)
        UIView.animateWithDuration(0.5, animations: {
            self.spinIndicator.alpha = 0
        }) { (true) in
            self.imgSuccess.showCheckmarkAnimatedTempImg(self.view, delay: 0.1, remove: false)
            self.performSelector(#selector(AddEventVC.popOut), withObject: nil, afterDelay: 1)
        }
    }
    
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Alerts, segue
    
    func alert(title: String, message: String){
        spinIndicFade()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel) { (UIAlertAction) in
            self.loadingView
        }
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DateTimeVC"{
            if let destinationVC = segue.destinationViewController as? DateTimeVC{
                destinationVC.delegate = self
                if let curDate = currentDate{
                    destinationVC.currentDate = curDate
                }
            }
        }
        if segue.identifier == "MapVC"{
            if let destinationVC = segue.destinationViewController as? MapVC{
                destinationVC.handleGetEventLocDelegate = self
                if let pm = holdPlacemark, let ad = holdAddress{
                    print("holdTo \(ad)")
                    destinationVC.mkPlacemarkPassed = pm
                    destinationVC.addressPassed = ad
                    destinationVC.wasAddressPassed = true
                }
            }
        }
    }
}
