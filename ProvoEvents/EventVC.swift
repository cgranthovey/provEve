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


class EventVC: GeneralEventVC, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MilesChosen {
    
    var events = [Event]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var geoMarkerBtn: UIButton!
    var keyOfLast: String?
    
    var likesArray = [String]()

    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshController)
        Constants.instance.initCurrentUser()

//
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.loadData), name: "loadData", object: nil)
//        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.addLike(_:)), name: "heartAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.subtractLike(_:)), name: "heartDeleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.loadData), name: "loadDataAfterNewEvent", object: nil)
    }
    
    
    
    
    
    func numberOfMiles(miles: Int) {
        print("I'm called suckers")
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("byebye")
        
        if status == .AuthorizedWhenInUse {
            print("bye")
            
            locationManager.requestLocation()
        }
    }
    var currentLoc: CLLocation!
    var hasUserLocBeenFound = false
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !hasUserLocBeenFound{
            if let location = locations.first {
                currentLoc = location
                hasUserLocBeenFound = true
                print("in loc manager")
                loadData()

            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
    
    
    
    
    
    
    
    
    
    
    
    

//    below and above is code to add a pull to refresh option
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(EventVC.handleRefresh), forControlEvents: .ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl){
        loadData()
    }

    
    var keysArray = [String]()
    
    
    func loadData(){
        
        
       print("users cuurent loc \(currentLoc)")

        let geoFireRef = DataService.instance.geoFireRef
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        let locCoord2d = CLLocationCoordinate2DMake(currentLoc.coordinate.latitude, currentLoc.coordinate.longitude)
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let meters: Int!
        if let miles = prefs.objectForKey(Constants.instance.nsUserDefaultsKeySettingsMiles){
            meters = Int(Double(miles as! NSNumber) * 1609.34)
            print("meters \(meters)")
        } else{
            meters = Int(25 * 1609.34)
        }
        
        let region = MKCoordinateRegionMakeWithDistance(locCoord2d, CLLocationDistance(meters) * 2, CLLocationDistance(meters) * 2) // need to double to get expected distance
        print("region \(region)")
            //maybe should check if region is valid later
        let geoQuery = geoFire.queryWithRegion(region)
        keysArray = []
        todaysStartTime = self.getTodaysStartTime()

        var firebaseCalledOnce = false
        var queryHande = geoQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            self.keysArray.append(key)
            print("all keys in query \(key)")
            
            
            
            if !firebaseCalledOnce{
                DataService.instance.currentUser.child("likes").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    print("in here")
                    if snapshot.value == nil{
                        print("this snapshot = nil for likes .value")
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
                    print("self keys array count \(self.keysArray.count)")
                    var timesIterated = 0
                    for key in self.keysArray{
                        
                        print("can")
                        
                        DataService.instance.mainRef.child("Events").child(key).observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if snapshot.value == nil{
                            } else{
                                print("snapshot: \(snapshot)")
                                
                                if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                                    print("hear")
                                    let key = snapshot.key
                                    
                                    var isEventLiked = false
                                    for like in self.likesArray{
                                        if like == key{
                                            isEventLiked = true
                                        }
                                    }
                                    
                                    let post = Event(key: key, dict: postDict, isLiked: isEventLiked)
                                    self.events.append(post)
                                    print("thran")
                                    self.keyOfLast = post.key
                                }
                            }
                            print("love")
                            timesIterated = timesIterated + 1
                            if timesIterated == self.keysArray.count{
                                print("tonight")
                                self.EventsCategorized = self.events.NewDictWithTimeCategories()
                                self.shouldAddTableViewBackground()
                                self.tableView.reloadData()
                                if self.refreshController.refreshing{
                                    self.refreshController.endRefreshing()
                                }
                            }
                            
                            
                        })
                    }
                    
                })
            }
            
            firebaseCalledOnce = true

            
            
            
            
            
        })
        
        
            
            

            
        
            
            
            
            
            
            
            
            
            
            
            
            

        
        
        
        
        
        
        
        
        
        

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
//        todaysStartTime = self.getTodaysStartTime()
//        DataService.instance.currentUser.child("likes").observeSingleEventOfType(.Value, withBlock: { snapshot in
//            print("I'm in there suckers")
//            if snapshot.value == nil{
//                print("this snapshot = nil for likes .value")
//            } else{
//                self.events = []
//                self.likesArray = []
//                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
//                    for snap in snapshots{
//                        let key = snap.key
//                        self.likesArray.append(key)
//                    }
//                }
//            }
//            
//            DataService.instance.mainRef.child("Events").queryOrderedByChild("timeStampOfEvent").queryStartingAtValue(self.todaysStartTime).queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { snapshot in
//                if snapshot.value == nil{
//                } else{
//                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
//                        for snap in snapshots{
//                            if let postDict = snap.value as? Dictionary<String, AnyObject>{
//                                let key = snap.key
//                                
//                                var isEventLiked = false
//                                for like in self.likesArray{
//                                    if like == key{
//                                        isEventLiked = true
//                                    }
//                                }
//                                
//                                let post = Event(key: key, dict: postDict, isLiked: isEventLiked)
//                                self.events.append(post)
//                                self.timeStampOfLast = post.timeStampOfEvent
//                                self.keyOfLast = post.key
//                            }
//                        }
//                    }
//                }
//                self.EventsCategorized = self.events.NewDictWithTimeCategories()
//                self.shouldAddTableViewBackground()
//                self.tableView.reloadData()
//                self.isCurrentlyLoading = false
//                if self.refreshController.refreshing{
//                    self.refreshController.endRefreshing()
//                }
//            })
//        })
    }
    
    func shouldAddTableViewBackground(){
        if EventsCategorized.count > 0{
            tableView.backgroundView = nil
        } else{
            let noDataLbl: UILabel = UILabel(frame: CGRectMake(20, 40, 200, 40))
            
            noDataLbl.numberOfLines = 10
            noDataLbl.text = "Post the first event!"
            noDataLbl.font = UIFont(name: "Avenir", size: 20)
            noDataLbl.numberOfLines = 0
            noDataLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
            noDataLbl.textAlignment = .Center
            tableView.backgroundView = noDataLbl
        }
    }
    
    func addLike(notif: NSNotification){        // these 2 chunks of code make sure that heart image appears immediately after tapping from event details page
        if let holdEvent = notif.object as? Event{
            let holdKey = holdEvent.key
            likesArray.append(holdKey)
            var section = 0
            for keyEventsCategorized in 0 ..< 4{
                
                if let eventArray = EventsCategorized[keyEventsCategorized]{
                
                    if let i = EventsCategorized[keyEventsCategorized]?.indexOf({$0.key == holdKey}){
                        let indexPath = NSIndexPath(forRow: i, inSection: section)
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventCell{
                            cell.setHeartImgFill()
                        }
                    }
                    section = section + 1
                }
            }
        }
    }
    
    func subtractLike(notif: NSNotification){
        
        if let holdKey = notif.object as? String{
            print("sign")
            if let index = likesArray.indexOf(holdKey){
                print("Sing1")
                likesArray.removeAtIndex(index)
                var section = 0
                for keyEventsCategorized in 0 ..< 4{
                    print("sign2")
                    if let eventArray = EventsCategorized[keyEventsCategorized]{
                        print("sign3")
                        if let i = eventArray.indexOf({$0.key == holdKey}){
                            var event = eventArray[i]
                            event.adjustHeartImgIsLiked(false)
                            print("sign4")
                            print("i \(i)")
                            print("section \(section)")
                            let indexPath = NSIndexPath(forRow: i, inSection: section)
                            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventCell{
                                print("sign5")
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
    
    var isCurrentlyLoading = false
    

    // this currently breaks the loading above, before I added the geo find for events it was fine.
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        let currentArray = ArrayForSection(indexPath.section)
//        let lastElement = currentArray.count - 1
//        
//        var mySection = indexPath
//        
//        if indexPath.row == lastElement{
//            if isCurrentlyLoading == false{
//            isCurrentlyLoading = true
//                
//            DataService.instance.eventRef.queryOrderedByChild("timeStampOfEvent").queryStartingAtValue(timeStampOfLast, childKey: keyOfLast).queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                var x = 0
//                if snapshot.value == nil{
//                    print("Snap of load more is nil")
//                } else{
//                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
//                        for snap in snapshots{
//                            if x != 0 {
//                                if let postDict = snap.value as? Dictionary<String, AnyObject>{
//                                    let key = snap.key
//                                    
//                                    var isEventLiked: Bool = false
//                                    for likes in self.likesArray{
//                                        if likes == key{
//                                            isEventLiked = true
//                                        }
//                                    }
//                                    
//                                    let post = Event(key: key, dict: postDict, isLiked: isEventLiked)
//                                    self.timeStampOfLast = post.self.timeStampOfEvent
//                                    self.keyOfLast = post.key
//                                    self.events.append(post)
//                                }
//                            }
//                            x = x + 1
//                        }
//                    }
//                }
//                if x < 10 {      //if the number of posts uploaded is less than 10 then we will prevent new posts from being loaded in the future
//                    self.isCurrentlyLoading = true
//                } else{
//                    self.isCurrentlyLoading = false
//                }
//                self.EventsCategorized = self.events.NewDictWithTimeCategories()
//                tableView.reloadData()
//            })
//            }
//        }
//    }
    
    
    @IBAction func settingsBtnPress(sender: UIButton){
        UIView.animateWithDuration(0.5) { 
        }
        UIView.animateWithDuration(0.5, animations: { 
            sender.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
            }) { (true) in
                sender.transform = CGAffineTransformMakeRotation(CGFloat(0))

                self.performSegueWithIdentifier("SettingsVC", sender: nil)

        }
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventDetailsVC"{
            if let destVC = segue.destinationViewController as? EventDetailsVC{
                if let event = sender as? Event{
                    destVC.event = event
                }
            }
        }
    }
}










