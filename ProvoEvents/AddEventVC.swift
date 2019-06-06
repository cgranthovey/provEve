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
import NVActivityIndicatorView

protocol HandleGetEventLoc {
    func getEventLoc(_ address:String?, name: String?, longitude: Double?, latitude: Double?, placemark: MKPlacemark?)
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
    
    //added to generalVC
    var img = ["football", "outdoors", "service", "theater", "dance", "art", "prayer", "music", "book", "sandwich"]
    var lbl = ["Sport", "Outdoor", "Service", "Theater/Cinema", "Dance", "Art", "Religion", "Music", "Education", "Food"]
    var selectedCellInt: Int!
    var cellHold = MapPinCell()
    var exit: UIButton!
    var yesNoView: yesNoLauncher!
    var actView: NVActivityIndicatorView!
    
    var delegate: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDelegates()
        setUpScrollAndCollection()
        setUpEventImgBtn()
        imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        
        yesNoView = yesNoLauncher()
        yesNoView.delegate = self
        
        eventImg.image = UIImage(named: "photoAlbumColor")
        
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actView = NVActivityIndicatorView(frame: frame, type: .lineScale, color: UIColor.white, padding: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddEventVC.makeLarger(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddEventVC.keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        correctCollectionViewWidth = collection.frame.width
        viewScrollHeight.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: scrollView.contentSize.height)
        viewScrollHeight.backgroundColor = UIColor.clear
        self.scrollView.addSubview(viewScrollHeight)
        scrollView.sendSubviewToBack(viewScrollHeight)
        setUpTaps()
    }
    
    func setUpScrollAndCollection(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collection.collectionViewLayout = layout
        collection.backgroundColor = UIColor.clear
        self.collection.allowsSelection = true
        
        scrollView.contentSize.height = 760
        scrollView.contentSize.width = view.frame.width
        scrollView.isDirectionalLockEnabled = true
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
        eventImgBtn.addTarget(self, action: #selector(AddEventVC.eventImgBtnTouchDown), for: .touchDown)
        eventImgBtn.addTarget(self, action: #selector(AddEventVC.eventImgBtnTouchUpInside), for: .touchUpInside)
        eventImgBtn.addTarget(self, action: #selector(AddEventVC.touchUpOutside), for: .touchUpOutside)
    }
    
    func setUpTaps(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.dismissKeyboard))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(AddEventVC.dismissKeyboard))
        viewScrollHeight.addGestureRecognizer(tap)
        topView.addGestureRecognizer(tap2)
    }
    
    override func swipePopBack() {
        //do nothing
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //animate image btn touch, imagePickerController
    
    @objc func eventImgBtnTouchDown(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.eventImg.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: nil)
    }
    
    @objc func eventImgBtnTouchUpInside(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.eventImg.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { (true) in
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
                self.eventImg.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.imageTapped()

                }, completion: { (true) in
            })
        }
    }
    
    @objc func touchUpOutside(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.eventImg.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }
    
    
    func imageTapped(){
        self.present(imgPickerController, animated: true, completion: nil)
    }
    
    var imgChoosen = false
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgChoosen = true
        imgPickerController.dismiss(animated: true, completion: nil)
        eventImg.image = image
        eventImg.roundCornersForAspectFit(5)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imgPickerController.dismiss(animated: true, completion: nil)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //active textfield/view.  Increase scroll view size
    
    @objc func keyboardWillBeHidden(_ input: Notification){
        scrollView.contentInset.bottom = UIEdgeInsets.zero.bottom    //without this the views go up a bit
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        activeTextField = nil
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = textView
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        activeTextView = nil
        return true
    }
    
    func resignAllFirstResponders(){
        titleTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    @objc func dismissKeyboard(){
        resignAllFirstResponders()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @objc func makeLarger(_ input: Notification){
        scrollView.contentInset.right = UIEdgeInsets.zero.right    //without this the views go up a few pixels

        if let userInfo = input.userInfo{
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]
            let keyboardRect = (keyboardFrame as AnyObject).cgRectValue
            if let keyboardHeight = keyboardRect?.height{
                myKeyBoardHeight = keyboardHeight
                scrollView.contentInset.bottom = keyboardHeight
                var aRect = self.view.frame
                aRect.size.height = aRect.size.height - keyboardHeight
                
                if activeTextField != nil{
                    let point = activeTextField.frame.origin
                    if !aRect.contains(point){
                        perform(#selector(AddEventVC.moveTextFieldIntoView), with: nil, afterDelay: 0.0)
                    }
                } else if activeTextView != nil{
                    let point = activeTextView.frame.origin
                    if !aRect.contains(point){
                        perform(#selector(AddEventVC.moveTextFieldIntoView), with: nil, afterDelay: 0.0)
                    }
                }
            }
        }
    }
    
    @objc func moveTextFieldIntoView(){
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
    func getEventLoc(_ address: String?, name: String?, longitude: Double?, latitude: Double?, placemark: MKPlacemark?) {
        
        if let placemark = placemark?.coordinate{
            coordinateOfEvent = placemark
        }
        
        if let address = address, let name = name{
            if address.contains(name){
                setPinBtnOutlet.setTitle(address, for: UIControl.State())
            } else{
                setPinBtnOutlet.setTitle("\(name) - \(address)", for: UIControl.State())
            }
        } else if let coordLat = latitude, let coordLong = longitude{
            setPinBtnOutlet.setTitle("\(coordLat), \(coordLong)", for: UIControl.State())
        } else{
            setPinBtnOutlet.setTitle("SET PIN", for: UIControl.State())
        }

        holdAddress = address
        holdPlacemark = placemark
        pinLocDict["address"] = address as AnyObject?
        pinLocDict["name"] = name as AnyObject?
        pinLocDict["longitude"] = longitude as AnyObject?
        pinLocDict["latitude"] = latitude as AnyObject?
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Date and Time
    
    @IBAction func dateButtonTapped(_ sender: UIButton){
        resignAllFirstResponders()
        performSegue(withIdentifier: "DateTimeVC", sender: nil)
    }
    
    @IBAction func addPinButtonTapped(_ sender: UIButton){
        resignAllFirstResponders()
        performSegue(withIdentifier: "MapVC", sender: nil)
    }
    
    var currentDate: Date?
    var dateString: String!
    var timeStampOfEvent: Int!
    func getTheDateTime(_ date: Date){
        timeStampOfEvent = Int(date.timeIntervalSince1970)
        currentDate = date
        
        let dateForm = DateFormatter()
        dateForm.dateStyle = .medium
        var dateDayString = dateForm.string(from: date)
        
        let dateForm2 = DateFormatter()
        dateForm2.timeStyle = .short
        let timeString = dateForm2.string(from: date)
        
        dateDayString.removeSubrange(dateDayString.index(dateDayString.endIndex, offsetBy: -6)..<dateDayString.endIndex)
        dateString = dateDayString + ", " + timeString
        dateButtonTappedOutlet.setTitle(dateString, for: UIControl.State())
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //to firebase then Reset
    @IBAction func submit(_ sender: UIButton){
        resignAllFirstResponders()
        perform(#selector(AddEventVC.areYouSureLauncher), with: nil, afterDelay: 0)
    }
    var loadingView: UIView!
    var spinIndicator: UIActivityIndicatorView!

    @objc func popOut(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addEventSubmitSlide"), object: nil)
        perform(#selector(AddEventVC.reset), with: nil, afterDelay: 0.5)
    }
    
    @objc func reset(){
        if actView != nil{
            actView.removeFromSuperview()
        }
        if spinIndicator != nil{
            spinIndicator.removeFromSuperview()
        }
        if imgSuccess != nil{
            imgSuccess.removeFromSuperview()
        }
        if loadingView != nil{
            loadingView.removeFromSuperview()
        }
        
        imgChoosen = false
        scrollView.scrollRectToVisible(topViewScroll.frame, animated: false)
        titleTextField.text = ""
        dateString = nil
        locationTextField.text = ""
        emailTextField.text = ""
        descriptionTextView.text = ""
        setPinBtnOutlet.setTitle("ADD PIN", for: UIControl.State())
        dateButtonTappedOutlet.setTitle("DATE/TIME", for: UIControl.State())
        eventImg.image = UIImage(named: "photoAlbumColor")
        eventImg.roundCornersForAspectFit(0)
        cellHold.backgroundColor = UIColor.clear
        selectedCellInt = nil
        pinLocDict = [:]
        holdPlacemark = nil
        holdAddress = nil
        coordinateOfEvent = CLLocationCoordinate2D()
        currentDate = Date()
        timeStampOfEvent = Int()
        exit.removeFromSuperview()
    }

    @objc func makeSuccessView(){
        imgSuccess = UIImageView(image: UIImage(named: "whiteCheck"))
        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadDataAfterNewEvent"), object: nil)
        UIView.animate(withDuration: 0.5, animations: {
  //          self.spinIndicator.alpha = 0
            self.actView.alpha = 0
        }, completion: { (true) in
            self.imgSuccess.showCheckmarkAnimatedTempImg(self.view, delay: 0.1, remove: false)
            self.perform(#selector(AddEventVC.popOut), with: nil, afterDelay: 1)
        }) 
    }
    
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Alerts, segue
    
    func alert(_ title: String, message: String){
        spinIndicFade()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
            _ = self.loadingView
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DateTimeVC"{
            if let destinationVC = segue.destination as? DateTimeVC{
                destinationVC.delegate = self
                if let curDate = currentDate{
                    destinationVC.currentDate = curDate
                }
            }
        }
        if segue.identifier == "MapVC"{
            if let destinationVC = segue.destination as? MapVC{
                destinationVC.handleGetEventLocDelegate = self
                if let pm = holdPlacemark, let ad = holdAddress{
                    destinationVC.mkPlacemarkPassed = pm
                    destinationVC.addressPassed = ad
                    destinationVC.wasAddressPassed = true
                }
            }
        }
    }
}
