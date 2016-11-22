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
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsVC.animateTopStackView), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EventTypeSettings")
        
        do{
            let results = try managedContext?.fetch(fetchRequest)
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
        topStack.isHidden = true
        let prefs = UserDefaults.standard
        
        if let miles = prefs.object(forKey: Constants.instance.nsUserDefaultsKeySettingsMiles){
            milesBtnOutlet.setTitle("EVENTS WITHIN \(miles) MILES", for: UIControlState())
        }  else {
            milesBtnOutlet.setTitle("EVENTS WITHIN 50 MILES", for: UIControlState())
        }
    }

    func tapRemoveKeyboard(){
        firstNameTF.resignFirstResponder()
    }
    
//    func findCoord(){
//        let geoCode = CLGeocoder()
//        geoCode.geocodeAddressString("84604") { (placemarks: [CLPlacemark]?, error: NSError?) in
//            <#code#>
//        } as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler
//    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Top Stack View
    
    @IBOutlet weak var milesTopConstraint: NSLayoutConstraint!

    func animateTopStackView(){
        if animationShouldBeCalled{
            animationShouldBeCalled = false
            self.milesTopConstraint.constant = self.milesTopConstraint.constant + 40
            self.topStack.isHidden = false
            
            UIView.animate(withDuration: 3.15, delay: 0.2, options: UIViewAnimationOptions(), animations: {
                self.topStack.alpha = 1
                
                }, completion: nil)
            
            UIView.animate(withDuration: 3.15, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }) { (true) in
            }
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject){
        firstNameTF.text = holdOriginalName
        dismissTopStack()
    }
    
    @IBAction func applyBtn(_ sender: AnyObject){
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

        UIView.animate(withDuration: 0.25, animations: {
            self.topStack.alpha = 0
        }, completion: { (true) in
            self.topStack.isHidden = true
            self.milesTopConstraint.constant = self.milesTopConstraint.constant - 40
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (true) in
                    self.animationShouldBeCalled = true
            })
        }) 
    }
    
    func textColorChange(){
        UIView.transition(with: firstNameTF, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            self.firstNameTF.textColor = UIColor.green
            }) { (true) in
                UIView.transition(with: self.firstNameTF, duration: 0.45, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    }, completion: { (true) in
                        UIView.transition(with: self.firstNameTF, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                            self.firstNameTF.textColor = UIColor.black
                            }, completion: nil)
                })
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Logout, backbtn, credits, miles, segue
    
    @IBAction func logOutBtn(_ sender: AnyObject){
        yesNo.showDeleteView(self.view, lblText: "Log out?")
    }
    
    func yesPressed() {
        do {
            try FIRAuth.auth()?.signOut()
            _ = self.navigationController?.popToRootViewController(animated: true)
        } catch {
            let alert = UIAlertController(title: "Error", message: "There was an error logging out, please try again soon", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtn(_ sender: AnyObject){
        swipePopBack()
    }

    override func swipePopBack() {
        if collectionViewChanged{
            delegate.clearTableViewAndReload()
        }
        _ = self.navigationController?.popViewController(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func creditsVC(_ sender: AnyObject){
        performSegue(withIdentifier: "CreditsVC", sender: nil)
    }

    @IBAction func milesVC(_ sender: AnyObject){
        performSegue(withIdentifier: "MilesVC", sender: nil)
    }
    
    
    func numberOfMiles(_ miles: Int) {
        milesBtnOutlet.setTitle("\(miles) MILE RADIUS", for: UIControlState())
        let prefs = UserDefaults.standard
        prefs.set(miles, forKey: Constants.instance.nsUserDefaultsKeySettingsMiles)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MilesVC"{
            if let VC = segue.destination as? MilesVC{
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
        layout.scrollDirection = .horizontal
        collection.collectionViewLayout = layout
        collection.backgroundColor = UIColor.clear
        self.collection.allowsSelection = true
        self.collection.allowsMultipleSelection = false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return img.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapPinCell", for: indexPath) as? MapPinCell{
            cell.configureCell(img[indexPath.row], label: lbl[indexPath.row])
            cell.checkImg(false)
            for event in selectedEvents{
                if img[indexPath.row] == event.value(forKey: "eventNumber") as? String{
                    cell.checkImg(true)
                }
            }
            return cell
        } else{
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        print(collection.frame.width)
        return CGSize(width: 85, height: 70.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewChanged = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        
        if let cell = collection.cellForItem(at: indexPath) as? MapPinCell{
            if cell.isImgChecked() == false{
                let entity = NSEntityDescription.entity(forEntityName: "EventTypeSettings", in: moc)
                let eventNumber = NSManagedObject(entity: entity!, insertInto: moc)
                
                eventNumber.setValue(img[indexPath.row], forKey: "eventNumber")
                
                do {
                    try moc.save()
                    selectedEvents.append(eventNumber)
                } catch let error as NSError{
                    print("Could not save \(error), \(error.userInfo)")
                }
                cell.backgroundColor = UIColor.clear
                cell.checkImg(true)
            } else{
                var x = 0
                for event in selectedEvents{
                    if img[indexPath.row] == event.value(forKey: "eventNumber") as? String{
                        moc.delete(event)
                        cell.checkImg(false)
                        selectedEvents.remove(at: x)
                    }
                    x = x + 1
                }
            }
        }
    }
}



