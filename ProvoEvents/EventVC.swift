//
//  EventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

// the noun project - plus sign Icons Bazaar, settings Hysen Drogu


// theNounProject - profile Julynn B., photo album Michal Kučera,  checkmark Adam Stevenson, textmessage Gregor Črešnar, alarmClock IconfactoryTeam, calendar David Ly, map AFY Studio, world map Tom Walsh, map pin icons - anbileru adaleru, thicker map pin icons -lastspark, RU,  weather icons  Sofya Ovchinnikova
// icons 8 - back,

import UIKit
import FirebaseDatabase
import Firebase
import CoreData
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


class EventVC: GeneralEventVC, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MilesChosen, settingsProtocol {
    
    var events = [Event]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var geoMarkerBtn: UIButton!
    
    var keyOfLast: String?
    var likesArray = [String]()
    var locationManager = CLLocationManager()
    var keysArray = [String]()
    var isCurrentlyLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkFirstLogin()
        setUpLocationManagerAndTableView()
        Constants.instance.initCurrentUser()

        NotificationCenter.default.addObserver(self, selector: #selector(EventVC.addLike(_:)), name: NSNotification.Name(rawValue: "heartAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventVC.subtractLike(_:)), name: NSNotification.Name(rawValue: "heartDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventVC.clearTableViewAndReload), name: NSNotification.Name(rawValue: "loadDataAfterNewEvent"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("view will disappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear")
    }
    
    func checkFirstLogin(){
        let prefs = UserDefaults.standard
        
        if prefs.object(forKey: "firstLogin") != nil{
            //has logged in before
        } else{
            prefs.setValue("logged in before", forKey: "firstLogin")
            
            let appDel = UIApplication.shared.delegate as! AppDelegate
            let moc = appDel.managedObjectContext
            
            let img = ["football", "outdoors", "service", "theater", "dance", "art", "prayer", "music", "book", "sandwich"]

            for i in img{
                let entity = NSEntityDescription.entity(forEntityName: "EventTypeSettings", in: moc)
                let managedObject = NSManagedObject(entity: entity!, insertInto: moc)
                managedObject.setValue(i, forKey: "eventNumber")
            }
            
            do{
                try moc.save()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    func setUpLocationManagerAndTableView(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted: loadData() //will use default location for Provo
        default:
            print("do nothing")
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshController)
    }
    
    func numberOfMiles(_ miles: Int) {    //called when miles radius changes in settings
        loadData()
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //locationManager
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    var currentLoc: CLLocation!
    var hasUserLocBeenFound = false
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !hasUserLocBeenFound{
            if let location = locations.first {
                currentLoc = location
                hasUserLocBeenFound = true
                loadData()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //refreshController
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(EventVC.handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    func handleRefresh(_ refreshControl: UIRefreshControl){
        loadData()
    }

    @IBOutlet weak var bottomView: UIView!
    var bottomViewShowing = true
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation: CGPoint = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0{
            //dragging finger down
        } else{
            refreshController.endRefreshing()   //prevents spinner from going forever when no internet connection
            if bottomViewShowing{
                UIView.animate(withDuration: 0.3, animations: {
                    self.bottomView.center.y = self.bottomView.center.y + 35
                })
                bottomViewShowing = false
            }

        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if !bottomViewShowing{
            if scrollOffset <= 0 {
                bottomViewShowing = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.bottomView.center.y = self.bottomView.center.y - 35
                }) 
            }
        }
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //loadData
    
    func clearTableViewAndReload(){
        print("clear table View")
        events = []
        EventsCategorized = [:]
        tableView.reloadData()
        loadData()
    }
    
    var geoQuery: GFRegionQuery!
    func loadData(){
        if geoQuery != nil{
            print("remove all observers")
            geoQuery.removeAllObservers()       // prevents multiple geoQuery requests if internet connection is poor and users tries making multiple requests by pulling down charger
        }
        
        //checking for preset radius to use in query
        let prefs = UserDefaults.standard
        let meters: Int!
        if let miles = prefs.object(forKey: Constants.instance.nsUserDefaultsKeySettingsMiles){
            meters = Int(Double(miles as! NSNumber) * 1609.34)
        } else{
            meters = Int(50 * 1609.34)
        }
        
        perform(#selector(EventVC.shouldAddTableViewBackground), with: nil, afterDelay: 3.5)
        
        let geoFireRef = DataService.instance.geoFireRef
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        
        
        if currentLoc == nil{
            currentLoc = CLLocation(latitude: CLLocationDegrees(40.2338), longitude: CLLocationDegrees(-111.6586))
        }
        
        let locCoord2d = CLLocationCoordinate2DMake(currentLoc.coordinate.latitude, currentLoc.coordinate.longitude)
        let region = MKCoordinateRegionMakeWithDistance(locCoord2d, CLLocationDistance(meters) * 2, CLLocationDistance(meters) * 2) // need to double to get expected distance
        if !region.isRegionValid(){
            return
        }
        geoQuery = geoFire?.query(with: region)
        keysArray = []
        todaysStartTime = self.getTodaysStartTime()

        var firebaseCalledOnce = false
        _ = geoQuery.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            
            if key == nil || location == nil{
                return
            }
            
            if self.keysArray.index(of: key!) != nil{
                //already have key
                return
            }
            self.keysArray.append(key!)
            if !firebaseCalledOnce{
                DataService.instance.currentUser.child("likes").observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.value == nil{
                    } else{
                        self.events = []
                        self.likesArray = []
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            for snap in snapshots{
                                let key = snap.key
                                self.likesArray.append(key)
                            }
                        }
                    }
                    var timesIterated = 0
                    for key in self.keysArray{
                        DataService.instance.mainRef.child("Events").child(key).observeSingleEvent(of: .value, with: { snapshot in
                            if snapshot.value == nil{
                            } else{
                                if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                                    let key = snapshot.key
                                    var isEventLiked = false
                                    for like in self.likesArray{
                                        if like == key{
                                            isEventLiked = true
                                        }
                                    }
                                    let post = Event(key: key, dict: postDict, isLiked: isEventLiked)
                                    
                                    if let userCustomEvents = self.findCustomEvents(){
                                        
                                        
                                        for customEvent in userCustomEvents{
                                            if post.eventTypeImgName == customEvent{
                                                if !post.beforeToday(){
                                                    self.events.append(post)
                                                    self.events.sort(by: {$0.timeStampOfEvent < $1.timeStampOfEvent})
                                                    self.keyOfLast = post.key
                                                }
                                            }
                                        }
                                    } else{
                                        if !post.beforeToday(){
                                            self.events.append(post)
                                            self.events.sort(by: {$0.timeStampOfEvent < $1.timeStampOfEvent})
                                            self.keyOfLast = post.key
                                        }
                                    }
                                }
                            }
                            timesIterated = timesIterated + 1
                            if timesIterated == self.keysArray.count{
                                self.EventsCategorized = self.events.NewDictWithTimeCategories()
                                self.shouldAddTableViewBackground()
                                self.tableView.reloadData()
                                if self.refreshController.isRefreshing{
                                    self.refreshController.endRefreshing()
                                }
                            }
                        })
                    }
                })
            }
            firebaseCalledOnce = true
        })
    }
    
    func shouldAddTableViewBackground(){
        if EventsCategorized.count > 0{
            tableView.backgroundView = nil
        } else{
            let noDataLbl: UILabel = UILabel(frame: CGRect(x: 20, y: 40, width: 200, height: 40))
            noDataLbl.numberOfLines = 10
            noDataLbl.text = "Swipe right to post first event!"
            noDataLbl.font = UIFont(name: "Avenir", size: 20)
            noDataLbl.numberOfLines = 0
            noDataLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
            noDataLbl.textAlignment = .center
            tableView.backgroundView = noDataLbl
        }
    }
    
    //uses core data to find which events user wants to see.
    func findCustomEvents() -> [String]?{
        var customEventTypes = [String]()
        let appDel = UIApplication.shared.delegate as? AppDelegate
        let moc = appDel?.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EventTypeSettings")
        
        do{
            if let results = try moc?.fetch(fetchRequest) as? [NSManagedObject]{
                for result in results{
                    if let eventName = result.value(forKey: "eventNumber") as? String{
                        customEventTypes.append(eventName)
                    }
                }
                
                if customEventTypes == [String](){
                    return nil
                } else{
                    return customEventTypes
                }
            }
        } catch let error as NSError{
            print("error \(error)")
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let EventForSpecificTimeArray = ArrayForSection(indexPath.section)
        let myEvent = EventForSpecificTimeArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as? EventCell{
            cell.configureCell(myEvent)
            return cell
        } else{
            
            return UITableViewCell()
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Likes
    
    func addLike(_ notif: Notification){        // these 2 chunks of code make sure that heart image appears immediately after tapping from event details page
        if let holdEvent = notif.object as? Event{
            let holdKey = holdEvent.key
            likesArray.append(holdKey)
            var section = 0
            for keyEventsCategorized in 0 ..< 4{
                //self.EventsCategorized = self.events.NewDictWithTimeCategories()

                
                if let eventArray = EventsCategorized[keyEventsCategorized]{
                    if let i = eventArray.index(where: {$0.key == holdKey}){
                        let event = eventArray[i]
                        event.adjustHeartImgIsLiked(true)
                        let indexPath = IndexPath(row: i, section: section)
                        if let cell = tableView.cellForRow(at: indexPath) as? EventCell{
                            cell.setHeartImgFill()
                            return
                        }
                    }
                    section = section + 1
                }
                
                
                
                
//                if EventsCategorized[keyEventsCategorized] != nil{
//                    
//                    if let i = EventsCategorized[keyEventsCategorized]?.indexOf({$0.key == holdKey}){
//                        let indexPath = NSIndexPath(forRow: i, inSection: section)
//                        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventCell{
//                            cell.setHeartImgFill()
//                        }
//                    }
//                    section = section + 1
//                }
            }
        }
    }
    
    func subtractLike(_ notif: Notification){
        if let holdKey = notif.object as? String{
            if let index = likesArray.index(of: holdKey){
                likesArray.remove(at: index)
                var section = 0
                for keyEventsCategorized in 0 ..< 4{
                    if let eventArray = EventsCategorized[keyEventsCategorized]{
                        if let i = eventArray.index(where: {$0.key == holdKey}){
                            let event = eventArray[i]
                            event.adjustHeartImgIsLiked(false)
                            let indexPath = IndexPath(row: i, section: section)
                            if let cell = tableView.cellForRow(at: indexPath) as? EventCell{
                                cell.setHeartImgEmpty()
                                return
                            }
                        }
                        section = section + 1
                    }
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //SettingBtn, GeoBtn, Segue
    
    @IBAction func settingsBtnPress(_ sender: UIButton){
        UIView.animate(withDuration: 0.5, animations: { 
        }) 
        UIView.animate(withDuration: 0.3, animations: {
            sender.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/3))
            }, completion: { (true) in
                sender.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                self.performSegue(withIdentifier: "SettingsVC", sender: nil)
        }) 
    }
    
    @IBAction func geoMarkerTapped(_ sender: AnyObject){
        performSegue(withIdentifier: "AnnotationMapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventDetailsVC"{
            if let destVC = segue.destination as? EventDetailsVC{
                if let event = sender as? Event{
                    destVC.event = event
                }
            }
        }
        if segue.identifier == "AnnotationMapVC" {
            if let destVC = segue.destination as? AnnotationMapVC{
                destVC.likesArray = self.likesArray
            }
        }
        if segue.identifier == "SettingsVC"{
            if let destVC = segue.destination as? SettingsVC{
                destVC.delegate = self
            }
        }
    }
}
