//
//  EventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

// the noun project - plus sign Icons Bazaar, settings Hysen Drogu


// theNounProject - profile Julynn B., photo album Michal Kučera,  checkmark Adam Stevenson, textmessage Gregor Črešnar, alarmClock IconfactoryTeam, calendar David Ly, map AFY Studio, world map Tom Walsh, map pin icons - anbileru adaleru, thicker map pin icons -lastspark, RU,
// icons 8 - back,

import UIKit
import FirebaseDatabase
import Firebase



class EventVC: GeneralEventVC, UITableViewDelegate, UITableViewDataSource {
    
    var events = [Event]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var timeStampOfLast: Int?
    var keyOfLast: String?
    
    var likesArray = [String]()
    
    var EventsCategorized = [Int: [Event]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("event vc viewDidLoad")

        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.addLike(_:)), name: "heartAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.subtractLike(_:)), name: "heartDeleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.loadData), name: "loadDataAfterNewEvent", object: nil)
        tableView.addSubview(refreshController)
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

    
    
    func loadData(){
        DataService.instance.currentUser.child("likes").observeSingleEventOfType(.Value, withBlock: { snapshot in
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
            
            DataService.instance.mainRef.child("Events").queryOrderedByChild("timeStampOfEvent").queryStartingAtValue(self.todaysStartTime).queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.value == nil{
                } else{
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            if let postDict = snap.value as? Dictionary<String, AnyObject>{
                                let key = snap.key
                                
                                var isEventLiked = false
                                for like in self.likesArray{
                                    if like == key{
                                        isEventLiked = true
                                    }
                                }
                                
                                
                                let post = Event(key: key, dict: postDict, isLiked: isEventLiked)
                                self.events.append(post)
                                self.timeStampOfLast = post.timeStampOfEvent
                                self.keyOfLast = post.key
                            }
                        }
                    }
                }
                self.EventsCategorized = self.events.NewDictWithTimeCategories()
                self.tableView.reloadData()
                self.isCurrentlyLoading = false
                if self.refreshController.refreshing{
                    self.refreshController.endRefreshing()
                }
            })
            
        })
    }
    
    func addLike(notif: NSNotification){
        if let holdEvent = notif.object as? Event{
            let holdKey = holdEvent.key
            likesArray.append(holdKey)
            for event in events{
                if event.key == holdKey{
                    if let i = events.indexOf({$0.key == event.key}){
                        let indexPath = NSIndexPath(forRow: i, inSection: 0)
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventCell{
                            cell.setHeartImgFill()
                        }
                    }
                }
            }
        }
    }
    
    func subtractLike(notif: NSNotification){
        if let holdKey = notif.object as? String{
            if let index = likesArray.indexOf(holdKey){
                likesArray.removeAtIndex(index)
                for event in events{
                    if event.key == holdKey{
                        event.adjustHeartImgIsLiked(false)
                        if let i = events.indexOf({$0.key == event.key}){
                            let indexPath = NSIndexPath(forRow: i, inSection: 0)
                            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventCell{
                                cell.setHeartImgEmpty()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print("event vc will will appear")
    }
    
    override func viewDidAppear(animated: Bool) {
        print("event vc view did appear")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("tiger")
        let EventForSpecificTimeArray = ArrayForSection(indexPath.section)
        
        print("tiger1.1")
        let myEvent = EventForSpecificTimeArray[indexPath.row]
        
        print("Tiger 1.3")
        if let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as? EventCell{
            print("tiger 2")
            print("myEvent \(myEvent.title)")
            cell.configureCell(myEvent)
            print("return from configure)")
            return cell
        } else{
            print("tiger 3")
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of rowsinsection: \(numberOfRowsForSection(section))")
        return numberOfRowsForSection(section)
    }
    
    func ArrayForSection(section: Int) -> [Event]{
        print("henry")
        
        var findKeys = Array(EventsCategorized.keys)
        findKeys.sortInPlace()
        if findKeys[section] == 0{
            return (EventsCategorized[0])!
        } else if findKeys[section] == 1{
            return (EventsCategorized[1])!
        } else if findKeys[section] == 2{
            return (EventsCategorized[2])!
        } else{
            return (EventsCategorized[3])!
        }
    }

    func numberOfRowsForSection(section: Int) -> Int{
        print("Robert")
        
        var findKeys = Array(EventsCategorized.keys)
        findKeys.sortInPlace()
        
        if findKeys[section] == 0{
            return (EventsCategorized[0]?.count)!
        } else if findKeys[section] == 1{
            return (EventsCategorized[1]?.count)!
        } else if findKeys[section] == 2{
            return (EventsCategorized[2]?.count)!
        } else{
            return (EventsCategorized[3]?.count)!
        }
    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        
//        return headerView
//    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("George")
        
        var findKeys = Array(EventsCategorized.keys)
        findKeys.sortInPlace()
        print("findKeys: \(findKeys)")
        print("current Section \(section)")
        if findKeys[section] == 0{
            return "Today"
        } else if findKeys[section] == 1{
            return "Tomorrow"
        } else if findKeys[section] == 2{
            print("thisWeek")
            return "This Week"
        } else{
            print("upcoming")
            return "Upcoming"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let eventArray = ArrayForSection(indexPath.section)
        performSegueWithIdentifier("EventDetailsVC", sender: eventArray[indexPath.row])
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("numberOfSectionsInTableView: \(EventsCategorized.count)")
        return EventsCategorized.count
    }
    
    var isCurrentlyLoading = false
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let currentArray = ArrayForSection(indexPath.section)
        let lastElement = currentArray.count - 1
        
        var mySection = indexPath
        
        if indexPath.row == lastElement{
            if isCurrentlyLoading == false{
            isCurrentlyLoading = true
                
            DataService.instance.eventRef.queryOrderedByChild("timeStampOfEvent").queryStartingAtValue(timeStampOfLast, childKey: keyOfLast).queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                var x = 0
                if snapshot.value == nil{
                    print("Snap of load more is nil")
                } else{
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            if x != 0 {
                                if let postDict = snap.value as? Dictionary<String, AnyObject>{
                                    let key = snap.key
                                    
                                    var isEventLiked: Bool = false
                                    for likes in self.likesArray{
                                        if likes == key{
                                            isEventLiked = true
                                        }
                                    }
                                    
                                    let post = Event(key: key, dict: postDict, isLiked: isEventLiked)
                                    self.timeStampOfLast = post.self.timeStampOfEvent
                                    self.keyOfLast = post.key
                                    self.events.append(post)
                                }
                            }
                            x = x + 1
                        }
                    }
                }
                if x < 10 {      //if the number of posts uploaded is less than 10 then we will prevent new posts from being loaded in the future
                    self.isCurrentlyLoading = true
                } else{
                    self.isCurrentlyLoading = false
                }
                print("yo \(self.EventsCategorized.count)")
                self.EventsCategorized = self.events.NewDictWithTimeCategories()
                print("yo2 \(self.EventsCategorized.count)")
                tableView.reloadData()
            })
            }
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










