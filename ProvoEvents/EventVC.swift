//
//  EventVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

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
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.currentUser.child("likes").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value == nil{
                print("this snapshot = nil for likes .value")
            } else{
                self.likesArray = []
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        let key = snap.key
                        self.likesArray.append(key)
                    }
                }
                print("munch")
                print("Likes Array \(self.likesArray.count) \(self.likesArray)")
                
            }

            DataService.instance.mainRef.child("Events").queryOrderedByChild("timeStampOfEvent").queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { snapshot in
                print("snapshot \(snapshot)")
                if snapshot.value == nil{
                    print("nil snapshot")
                } else{
                    print("tiger 1")
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            print("tiger 2")
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
                                print("post email \(post.email)")
                            }
                        }
                    }
                }
                print("i'm called")
                self.tableView.reloadData()
                
            })
            
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.addLike(_:)), name: "heartAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventVC.subtractLike(_:)), name: "heartDeleted", object: nil)
        
        
        
//        tableView.addSubview(refreshController)
    }

    //below and above is code to add a pull to refresh option
//    lazy var refreshController: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(EventVC.handleRefresh), forControlEvents: .ValueChanged)
//        return refreshControl
//    }()
//    
//    func handleRefresh(refreshControl: UIRefreshControl){
//        //upload new data
//        
//        self.tableView.reloadData()
//        refreshControl.endRefreshing()
//    }
    
    
    
    func addLike(notif: NSNotification){
        if let holdKey = notif.object as? String{
            likesArray.append(holdKey)
        }
    }
    
    func subtractLike(notif: NSNotification){
        print("help")
        if let holdKey = notif.object as? String{
            print("rhinosaurus")
            if let index = likesArray.indexOf(holdKey){
                likesArray.removeAtIndex(index)
                print("elephant")
                for event in events{
                    print("iguana")
                    if event.key == holdKey{
                        print("hyenna")
                        event.adjustHeartImgIsLiked(false)
                    }
                }
                
                tableView.reloadData()      //seems wasteful
            }
        }
    }
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        print("moonray \(likesArray.count) \(likesArray)")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = events[indexPath.row]
        print("\(events.count) and post \(post)")
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
                print("tiger")
                var x = 0

                if snapshot.value == nil{
                    print("Snap of load more is nil")
                } else{
                    print("snapshot!: \(snapshot.value)")
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        print("tiger2 \(snapshots)")
                        for snap in snapshots{
                            print("tiger3")
                            if x != 0 {
                                if let postDict = snap.value as? Dictionary<String, AnyObject>{
                                    print("tiger4")
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
                                    print("it's the email of the refresh \(post.email)")
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

    @IBAction func heartTapped(sender: AnyObject){
        performSegueWithIdentifier("FavoritesVC", sender: nil)
    }
    

}










