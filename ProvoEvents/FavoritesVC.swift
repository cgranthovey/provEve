//
//  FavoritesVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/27/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FavoritesVC: GeneralVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var events = [Event]()
    var likesArray = [String]()     //you have to set likes array as empty if you want to append it from empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.currentUser.child("likes").queryOrderedByChild("timeStampOfEvent").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if snapshot.value == nil{
            } else{
                print("my snapshot print: \(snapshot)")
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    print("2nd \(snapshots)")
                    for snap in snapshots{
                        print("key \(snap.key)")

                        var holdKey = snap.key
                        self.likesArray.append(holdKey)
                    }
                    for eventKey in self.likesArray{
                        DataService.instance.eventRef.child(eventKey).observeSingleEventOfType(.Value, withBlock: { snapshot in
                                if snapshot.value == nil{
                                    print("snapshot of liked posts = nil")
                                } else{
                                    print("tiger: \(snapshot)")
                                    
                                    if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                                        let event = Event(key: snapshot.key, dict: postDict)
                                        print("moose: \(event.description)")
                                        self.events.append(event)
                                        print("tableViewCalled")
                                        self.tableView.reloadData()
                                    }

                                }
                            })

                    }

                }
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoritesVC.removeCell(_:)), name: "heartDeleted", object: nil)

//        DataService.instance.currentUser.child("likes").observeEventType(.ChildRemoved, withBlock: { snapshot in
//            if snapshot.value == nil{
//                print ("it's nil")
//            } else{
//                let keyToRemove = snapshot.key
//                let indexToRemove = self.likesArray.indexOf(keyToRemove)
//                print("index to Remove \(indexToRemove)")
//                self.likesArray.removeAtIndex(indexToRemove!)
//                self.events.removeAtIndex(indexToRemove!)
//                print("likes Array: \(self.likesArray)")
//                let indexPath = NSIndexPath(forRow: indexToRemove!, inSection: 0)
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            }
//        })
    }
    
    func removeCell(notif: NSNotification){
        var dict = notif.userInfo as? Dictionary<String, String>
        var key = dict!["key"]
        var indexValue = self.likesArray.indexOf(key!)
        self.likesArray.removeAtIndex(indexValue!)
        self.events.removeAtIndex(indexValue!)
        let indexPath = NSIndexPath(forRow: indexValue!, inSection: 0)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("TV 1")
        let event = events[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("favCell") as? EventCell{

            
            cell.configureCell(event, eventLiked: true)
            return cell
        } else{
            print("catilac")
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let eventToSend = events[indexPath.row]
        performSegueWithIdentifier("EventDetailsVC", sender: eventToSend)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("TV 2")

        return events.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("TV 3")
        return 1
    }


    
}
