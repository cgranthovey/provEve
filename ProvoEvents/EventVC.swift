//
//  EventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

// the noun project - plus sign Icons Bazaar, settings Hysen Drogu

import UIKit
import FirebaseDatabase
import Firebase

class EventVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var events = [Event]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var timeStampOfLast: Int?
    var keyOfLast: String?
    
    var likesArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("event vc viewDidLoad")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.addLike(_:)), name: "heartAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.subtractLike(_:)), name: "heartDeleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.loadData), name: "loggedInLoadData", object: nil)
        tableView.addSubview(refreshController)
        
    }

//    below and above is code to add a pull to refresh option
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(EventVC.handleRefresh), forControlEvents: .ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl){
        //upload new data
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
            
            DataService.instance.mainRef.child("Events").queryOrderedByChild("timeStampOfEvent").queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { snapshot in
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
                
//                tableView.reloadData()      //seems wasteful
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
        let post = events[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as? EventCell{
            // add cell.request?.cancel() to cancel the request so we don't load date when we don't want to
            
            cell.configureCell(post)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("EventDetailsVC", sender: events[indexPath.row])
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    var isCurrentlyLoading = false
    
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        let lastElement = events.count - 1
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
                tableView.reloadData()
//                NSIndexPath(forRow: <#T##Int#>, inSection: <#T##Int#>)
//                
//                tableView.insertRowsAtIndexPaths(<#T##indexPaths: [NSIndexPath]##[NSIndexPath]#>, withRowAnimation: <#T##UITableViewRowAnimation#>)
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

//  this was before napScrollVC was added
//    @IBAction func heartTapped(sender: AnyObject){
//        performSegueWithIdentifier("FavoritesVC", sender: nil)
//    }
}










