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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        DataService.instance.mainRef.child("Events").queryOrderedByChild("timeStampOfEvent").queryLimitedToFirst(10).observeSingleEventOfType(.Value, withBlock: { snapshot in
            print("snapshot \(snapshot)")
            if snapshot.value == nil{
                print("nil snapshot")
            } else{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if let postDict = snap.value as? Dictionary<String, AnyObject>{
                            let key = snap.key
                            let post = Event(key: key, dict: postDict)
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
        
        
        
        
        
//        
//        var x = 1
//        DataService.instance.eventRef.queryOrderedByChild("timeStampOfEvent").queryLimitedToFirst(10).observeEventType(.ChildAdded, withBlock: { snapshot in
//            print("\(x). snapShot: \(snapshot)")
//            if snapshot.value == nil{
//                print("nil snapshot")
//            } else{
//                if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
//                    let key = snapshot.key
//                    let event = Event(key: key, dict: postDict)
//                    print("myEvent: \(event.description)")
//                    self.events.append(event)
//                    self.timeStampOfLast = event.timeStampOfEvent
//                    self.keyOfLast = event.key
//                    
//                    print("event count: \(self.events.count)")
//                    let holdIndexPath = NSIndexPath(forRow: self.events.count, inSection: 1)
//                   // self.tableView.reloadData()
//                    self.tableView.beginUpdates()
//                    self.tableView.insertRowsAtIndexPaths([holdIndexPath], withRowAnimation: .Automatic)
//                    
//
//                    if let cell = self.tableView.cellForRowAtIndexPath(holdIndexPath) as? EventCell{
//                        print("me!")
//                        cell.configureCell(event)
//                    }
//                }
//            }
//            
//            
//            x = x + 1
//        })
//        tableView.reloadData()
//        
        
        
        
        
        
        
        
        
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
                                    let post = Event(key: key, dict: postDict)
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


}










