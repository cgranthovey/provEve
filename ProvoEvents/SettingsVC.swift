//
//  SettingsVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/4/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import CoreData
import MapKit

protocol settingsProtocol {
    func clearTableViewAndReload()
}

class SettingsVC: GeneralVC, UITextFieldDelegate, yesSelectedProtocol, MilesChosen {

    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var milesBtnOutlet: UIButton!
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    var img = ["football", "outdoors", "service", "theater", "dance", "art", "prayer", "music", "book", "sandwich"]
    var lbl = ["Sport", "Outdoor", "Service", "Theater/Cinema", "Dance", "Art", "Religion", "Music", "Education", "Food"]
    
    var delegate: settingsProtocol!
    var holdOriginalName: String!
    let yesNo = yesNoLauncher()
    var animationShouldBeCalled = true

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTF.delegate = self
        yesNo.delegate = self
        collection.delegate = self
        collection.dataSource = self
        setUpCollectionView()
        setUpUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsVC.tapRemoveKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsVC.animateTopStackView), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "EventTypeSettings")
        
        do{
            let results = try managedContext?.executeFetchRequest(fetchRequest)
            selectedEvents = results as! [NSManagedObject]
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func setUpUI(){
        if let currUser = Constants.instance.currentUser{
            userNameTF.text = currUser.userName
            firstNameTF.text = currUser.firstName
            holdOriginalName = currUser.firstName
        }
        self.topStack.alpha = 0
        topStack.hidden = true
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let miles = prefs.objectForKey(Constants.instance.nsUserDefaultsKeySettingsMiles){
            milesBtnOutlet.setTitle("EVENTS WITHIN \(miles) MILES", forState: .Normal)
        }  else {
            milesBtnOutlet.setTitle("EVENTS WITHIN 50 MILES", forState: .Normal)
        }
    }

    func tapRemoveKeyboard(){
        firstNameTF.resignFirstResponder()
    }
    
    func findCoord(){
        let geoCode = CLGeocoder()
        geoCode.geocodeAddressString("84604") { (placemarks: [CLPlacemark]?, error: NSError?) in
            <#code#>
        }

    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Top Stack View
    
    @IBOutlet weak var milesTopConstraint: NSLayoutConstraint!

    func animateTopStackView(){
        if animationShouldBeCalled{
            animationShouldBeCalled = false
            self.milesTopConstraint.constant = self.milesTopConstraint.constant + 40
            self.topStack.hidden = false
            
            UIView.animateWithDuration(3.15, delay: 0.2, options: .CurveEaseInOut, animations: {
                self.topStack.alpha = 1
                
                }, completion: nil)
            
            UIView.animateWithDuration(3.15, delay: 0.0, options: .CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }) { (true) in
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject){
        firstNameTF.text = holdOriginalName
        dismissTopStack()
    }
    
    @IBAction func applyBtn(sender: AnyObject){
        textColorChange()
        dismissTopStack()
        let firstName: String!
        if firstNameTF.text == nil{
            firstName = ""
        } else{
            firstName = firstNameTF.text
        }
        holdOriginalName = firstName
        DataService.instance.currentUserProfile.child(Constants.instance.FirConsFirstName).setValue(firstName)
        Constants.instance.initCurrentUser()
    }
    
    func dismissTopStack(){
        self.view.endEditing(true)

        UIView.animateWithDuration(0.25, animations: {
            self.topStack.alpha = 0
        }) { (true) in
            self.topStack.hidden = true
            self.milesTopConstraint.constant = self.milesTopConstraint.constant - 40
            UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (true) in
                    self.animationShouldBeCalled = true
            })
        }
    }
    
    func textColorChange(){
        UIView.transitionWithView(firstNameTF, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.firstNameTF.textColor = UIColor.greenColor()
            }) { (true) in
                UIView.transitionWithView(self.firstNameTF, duration: 0.45, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    }, completion: { (true) in
                        UIView.transitionWithView(self.firstNameTF, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                            self.firstNameTF.textColor = UIColor.blackColor()
                            }, completion: nil)
                })
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Logout, backbtn, credits, miles, segue
    
    @IBAction func logOutBtn(sender: AnyObject){
        yesNo.showDeleteView(self.view, lblText: "Log out?")
    }
    
    func yesPressed() {
        do {
            try FIRAuth.auth()?.signOut()
            self.navigationController?.popToRootViewControllerAnimated(true)
        } catch {
            let alert = UIAlertController(title: "Error", message: "There was an error logging out, please try again soon", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(alertAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtn(sender: AnyObject){
        swipePopBack()
    }

    override func swipePopBack() {
        if collectionViewChanged{
            delegate.clearTableViewAndReload()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func creditsVC(sender: AnyObject){
        performSegueWithIdentifier("CreditsVC", sender: nil)
    }

    @IBAction func milesVC(sender: AnyObject){
        performSegueWithIdentifier("MilesVC", sender: nil)
    }
    
    
    func numberOfMiles(miles: Int) {
        milesBtnOutlet.setTitle("\(miles) MILE RADIUS", forState: .Normal)
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setObject(miles, forKey: Constants.instance.nsUserDefaultsKeySettingsMiles)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MilesVC"{
            if let VC = segue.destinationViewController as? MilesVC{
                VC.delegate = self
            }
        }
    }

    var selectedEvents = [NSManagedObject]()
    var collectionViewChanged: Bool = false
}


extension SettingsVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func setUpCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        collection.collectionViewLayout = layout
        collection.backgroundColor = UIColor.clearColor()
        self.collection.allowsSelection = true
        self.collection.allowsMultipleSelection = false
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return img.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MapPinCell", forIndexPath: indexPath) as? MapPinCell{
            cell.configureCell(img[indexPath.row], label: lbl[indexPath.row])
            cell.checkImg(false)
            for event in selectedEvents{
                if img[indexPath.row] == event.valueForKey("eventNumber") as? String{
                    cell.checkImg(true)
                }
            }
            return cell
        } else{
            return UICollectionViewCell()
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(collection.frame.width)
        return CGSizeMake(85, 70.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionViewChanged = true
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        
        if let cell = collection.cellForItemAtIndexPath(indexPath) as? MapPinCell{
            if cell.isImgChecked() == false{
                let entity = NSEntityDescription.entityForName("EventTypeSettings", inManagedObjectContext: moc)
                let eventNumber = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
                
                eventNumber.setValue(img[indexPath.row], forKey: "eventNumber")
                
                do {
                    try moc.save()
                    selectedEvents.append(eventNumber)
                } catch let error as NSError{
                    print("Could not save \(error), \(error.userInfo)")
                }
                cell.backgroundColor = UIColor.clearColor()
                cell.checkImg(true)
            } else{
                var x = 0
                for event in selectedEvents{
                    if img[indexPath.row] == event.valueForKey("eventNumber") as? String{
                        moc.deleteObject(event)
                        cell.checkImg(false)
                        selectedEvents.removeAtIndex(x)
                    }
                    x = x + 1
                }
            }
        }
    }
}



