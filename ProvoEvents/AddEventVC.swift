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
    
    var imgPickerController: UIImagePickerController!
    
    @IBOutlet weak var collection: UICollectionView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventImg.image = UIImage(named: "photoAlbumColor")
        setUpDelegates()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        collection.collectionViewLayout = layout
        
        
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.clearColor()
        self.collection.allowsSelection = true

        imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEventVC.keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEventVC.makeLarger(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEventVC.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        scrollView.contentSize.height = 750
        scrollView.contentSize.width = view.frame.width
        scrollView.directionalLockEnabled = true

    }
    
    var correctCollectionViewWidth = CGFloat(300)
    override func viewWillAppear(animated: Bool) {

        print("mommy2")
        print(collection.frame.width)
        correctCollectionViewWidth = collection.frame.width
        print("hi \(self.view.frame.width)")
        print("yo \(scrollView.contentSize.height)")
        viewScrollHeight.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: scrollView.contentSize.height)
        viewScrollHeight.backgroundColor = UIColor.clearColor()
        self.scrollView.addSubview(viewScrollHeight)
        scrollView.sendSubviewToBack(viewScrollHeight)
        setUpTaps()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.view.layoutIfNeeded()

    }

    var viewScrollHeight = UIView()
    
    func keyboardWillBeHidden(input: NSNotification){
        scrollView.contentInset.bottom = UIEdgeInsetsZero.bottom    //without this the views go up a bit
      //  scrollView.contentInset.top = 22
    }

    var activeTextField: UITextField!
    var activeTextView: UITextView!
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("minE")
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
    
    func setUpDelegates(){
        descriptionTextView.delegate = self
        titleTextField.delegate = self
        locationTextField.delegate = self
        emailTextField.delegate = self
    }
    
    @IBOutlet weak var topView: UIView!
    
    var myKeyBoardHeight: CGFloat!
    func makeLarger(input: NSNotification){
        scrollView.contentInset.right = UIEdgeInsetsZero.right    //without this the views go up a bit

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
    
    @IBOutlet weak var submitOutlet: UIButton!
    
    func moveTextFieldIntoView(){
        print("none")
        if activeTextField != nil{
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)       //for this to work you have to remember in addition to setting conent height to make sure content width is at least at wide as view.frame.width
        } else if activeTextView != nil{
            scrollView.scrollRectToVisible(submitOutlet.frame, animated: true)
            
        }
    }

    
    
    
    var pinLocDict: Dictionary<String, AnyObject>! = [:]
    var holdPlacemark: MKPlacemark!
    var holdAddress: String!
    var coordinateOfEvent: CLLocationCoordinate2D!
    
    func getEventLoc(address: String?, name: String?, longitude: Double?, latitude: Double?, placemark: MKPlacemark?) {
        
        if let placemark = placemark?.coordinate{
            print("placemark exists")
            coordinateOfEvent = placemark
        }
        
        if let address = address, let name = name{
            print("tiger " + address)
            print("monster " + name)
            if address.containsString(name){
                print("contained")
                setPinBtnOutlet.setTitle(address, forState: .Normal)
            } else{
                print("not contained")
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
        
        print("the address of the event is \(address), name: \(name), longitude: \(longitude), latitude: \(latitude)")
    }
    
    @IBAction func dateButtonTapped(sender: UIButton){
        resignAllFirstResponders()
        performSegueWithIdentifier("DateTimeVC", sender: nil)
    }
    
    @IBAction func addPinButtonTapped(sender: UIButton){
        resignAllFirstResponders()
        performSegueWithIdentifier("MapVC", sender: nil)
    }
    
    func resignAllFirstResponders(){
        titleTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    
    var loadingView: UIView!
    var spinIndicator: UIActivityIndicatorView!
    func makeLoadingView(){
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.loadingView.center = self.view.center
        self.loadingView.backgroundColor = UIColor.blackColor()
        self.loadingView.alpha = 0
        view.addSubview(self.loadingView)

        self.spinIndicator = UIActivityIndicatorView()
        self.spinIndicator.center = self.loadingView.center
        self.spinIndicator.color = UIColor.whiteColor()
        self.spinIndicator.startAnimating()
        self.spinIndicator.alpha = 0
        self.loadingView.addSubview(self.spinIndicator)

        UIView.animateWithDuration(0.5, animations: {
            self.loadingView.alpha = 0.8
            }) { (true) in
                UIView.animateWithDuration(0.5, animations: {
                    self.spinIndicator.alpha = 1
                    }, completion: nil)
        }
    }
    
    var imgSuccess: UIImageView!
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

    

    
    func popOut(){
        //self.navigationController?.popViewControllerAnimated(true)
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
        
        titleTextField.text = ""
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
        dateString = String()
        timeStampOfEvent = Int()
    }

    @IBAction func submit(sender: UIButton){
        print("yeak")
        resignAllFirstResponders()

        performSelector(#selector(AddEventVC.toFireBase), withObject: nil, afterDelay: 0)
    }
    
    func toFireBase(){
        print("yak")
        if titleTextField.text == nil || titleTextField.text == ""{
            print("3!")
            alert("Error", message: "Title Missing")
            print("4!")
            return
        }
        
        if locationTextField.text == nil || locationTextField.text == ""{
            alert("Error", message: "Location Missing")
            return
        }
        
        let selectedCellImgName: String!
        if selectedCellInt == nil{
            alert("Error", message: "Choose event type icon")
            return
        } else{
            selectedCellImgName = img[selectedCellInt]
        }
        
        if dateString == nil{
            alert("Error", message: "Date Missing")
            return
        }
        
        if descriptionTextView.text == nil || descriptionTextView.text == ""{
            alert("Error", message: "Description Missing")
            return
        }
        
        makeLoadingView()
        
        var timePosted: Int = Int(NSDate().timeIntervalSince1970)
        
        let toFirebaseDict: Dictionary<String, AnyObject> = ["title": titleTextField.text!, "location": locationTextField.text!, "pinInfo": pinLocDict,"date": dateString!, "timeStampOfEvent": timeStampOfEvent,"email": emailTextField.text!, "timePosted": timePosted, "description": descriptionTextView.text!, "user": (FIRAuth.auth()?.currentUser?.uid)!, "eventTypeImgName": selectedCellImgName]
        
        let key = DataService.instance.eventRef.childByAutoId().key
        holdKeyInCaseError = key
        

        
        let childValues: Dictionary<String, AnyObject> = ["/Events/\(key)": toFirebaseDict, "/User/\((FIRAuth.auth()?.currentUser?.uid)!)/posts/\(key)": "True"]
        DataService.instance.mainRef.updateChildValues(childValues) { (err, FIRDatabaseRef) in
            if err != nil{
                print(err?.localizedDescription)
                self.alert("Error", message: "Error uploading data, try again soon")
            } else{
                if let img = self.eventImg.image where img != UIImage(named: "photoAlbumColor"){
                    if let data: NSData = UIImageJPEGRepresentation(img, 0.8){
                        let imgName = "\(NSUUID().UUIDString)jpg"
                        let storageRef = DataService.instance.imgStorageRefData.child(imgName)
                        storageRef.putData(data, metadata: nil, completion: { (meta, err) in
                            if err != nil{
                                self.alertProblemUploadingImg()
                                return
                            } else{
                                self.postGeoFire(self.coordinateOfEvent, eventRef: key)
                                let downloadURL = meta?.downloadURL()?.absoluteString
                                DataService.instance.eventRef.child(key).child("image").setValue(downloadURL)
                                self.performSelector(#selector(AddEventVC.makeSuccessView), withObject: self, afterDelay: 1.5)
                            }
                        })
                    }
                } else {
                    print("about to call Geo Fire")
                    self.postGeoFire(self.coordinateOfEvent, eventRef: key)
                    self.performSelector(#selector(AddEventVC.makeSuccessView), withObject: self, afterDelay: 1.5)
                }
                print("i'm on bottom")
            }
        }

    }
    
    func postGeoFire(location: CLLocationCoordinate2D?, eventRef: String?){
        var geoFire: GeoFire!
        var geoFireRef: FIRDatabaseReference!
        print("in geo fire")
        geoFireRef = DataService.instance.mainRef.child("GeoFire")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        print("\(location) and key \(eventRef)")
        if let loc = location, let key = eventRef{
            print("inside")
            geoFire.setLocation(CLLocation(latitude: loc.latitude, longitude: loc.longitude), forKey: key) { (error) in
                if error != nil{
                    print("error")
                    print(error.debugDescription)
                } else{
                    print("upload successful!")
                }
            }
        }
    }
    
    func loadingViewFade(){
        if loadingView != nil{
            UIView.animateWithDuration(0.3, animations: {
                self.loadingView.alpha = 0
                }) { (true) in
                    self.loadingView.removeFromSuperview()
            }
        }
    }
    
    func spinIndicFade(){
        if spinIndicator != nil{
            UIView.animateWithDuration(0.5, animations: {
                self.spinIndicator.alpha = 0
                }, completion: nil)
            }
    }
    
    var holdKeyInCaseError: String!

    func alert(title: String, message: String){
        spinIndicFade()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel) { (UIAlertAction) in
            self.loadingView
        }
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertProblemUploadingImg(){
        spinIndicFade()
        let alert = UIAlertController(title: "Error Uploading Image", message: "Would you like to post now without the image, or try later with the image", preferredStyle: .Alert)
        let actionNow = UIAlertAction(title: "Now", style: .Default) {(action: UIAlertAction) in
            
            let imgSuccess2 = UIImageView(image: UIImage(named: "whiteCheck"))
            imgSuccess2.showCheckmarkAnimatedTempImg(self.view, delay: 0.2, remove: false)
            self.performSelector(#selector(AddEventVC.popOut), withObject: nil, afterDelay: 2)
            
            print("info uploaded without image")
        }
        let actionLater = UIAlertAction(title: "Later", style: .Default) {(action: UIAlertAction) in
            self.loadingViewFade()
            if let key = self.holdKeyInCaseError{
                DataService.instance.eventRef.child(key).removeValue()      //removes firebase data at location, however other users would be able to view post for a second until user deletes it
            }
        }
        alert.addAction(actionNow)
        alert.addAction(actionLater)
        self.presentViewController(alert, animated: true, completion: nil)
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
                }
            }
        }
        
    }
    
    
    func setUpTaps(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.dismissKeyboard))
       // tap.cancelsTouchesInView = false
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.dismissKeyboard))
       // tap2.cancelsTouchesInView = false
        viewScrollHeight.addGestureRecognizer(tap)
        topView.addGestureRecognizer(tap2)

        
        let tapImg = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.imageTapped))
        eventImg.userInteractionEnabled = true
        eventImg.addGestureRecognizer(tapImg)
    }
    
    func dismissKeyboard(){
        resignAllFirstResponders()
        //self.view.endEditing(true)
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
    
    var rightCollectionTapped: CGFloat = 1
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    var img = ["football", "outdoors", "service", "theater", "art", "prayer", "music", "book", "sandwich"]
    var lbl = ["Sports", "Outdoors", "Service", "Theater/Cinema", "Art", "Religous", "Music", "Education", "Culinary"]

    var selectedCellInt: Int!
    var cellHold = MapPinCell()

}




////////////////////////////////////////////////////////////////////////////////
// extension for collection view
////////////////////////////////////////////////////////////////////////////////

extension AddEventVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MapPinCell", forIndexPath: indexPath) as? MapPinCell{
                cell.configureCell(img[indexPath.row], label: lbl[indexPath.row])
                print("mymy")
                if let pickedCell = selectedCellInt{
                    
                    print("tugo")
                    if indexPath.row == pickedCell{
                        cell.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                    } else{
                        cell.backgroundColor = UIColor.clearColor()
                    }
                }

                
                return cell
            } else{
                print("hugo")
                return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return img.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print("mommy")
        print(collection.frame.width)
       // return CGSizeMake(correctCollectionViewWidth / 3, 70.0)       if I add three for width back remember to set paging in interface builder
        return CGSizeMake(85, 70.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let pickedCellIndex = selectedCellInt{
            let indexPath = NSIndexPath(forItem: pickedCellIndex, inSection: 0)
            if let myCell = collection.cellForItemAtIndexPath(indexPath) as? MapPinCell{
                myCell.backgroundColor = UIColor.clearColor()
            }
        }
        
        print("hi")
        
        let cell = collection.cellForItemAtIndexPath(indexPath) as? MapPinCell
        selectedCellInt = indexPath.row
        //cell?.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5)
        cell?.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        cellHold = cell!
        print("called")
    }
}

















