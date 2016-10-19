//
//  FavoritesVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/27/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FavoritesVC: GeneralEventVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var events = [Event]()
    var likesArray = [String]()     //you have to set likes array as empty if you want to append it from empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("fav vc viewDidLoad")

        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoritesVC.removeCell(_:)), name: "heartDeleted", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoritesVC.addCell(_:)), name: "heartAdded", object: nil)

//        DataService.instance.currentUser.child("likes").observeEventType(.ChildRemoved, withBlock: { snapshot in
//            if snapshot.value == nil{
//            } else{
//                let keyToRemove = snapshot.key
//                let indexToRemove = self.likesArray.indexOf(keyToRemove)
//                self.likesArray.removeAtIndex(indexToRemove!)
//                self.events.removeAtIndex(indexToRemove!)
//                let indexPath = NSIndexPath(forRow: indexToRemove!, inSection: 0)
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            }
//        })
    }
    
    func loadData(){
        todaysStartTime = self.getTodaysStartTime()
        DataService.instance.currentUser.child("likes").queryOrderedByChild("timeStampOfEvent").queryStartingAtValue(self.todaysStartTime).observeSingleEventOfType(.Value, withBlock: {snapshot in
            if snapshot.value == nil{
            } else{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        var holdKey = snap.key
                        self.likesArray.append(holdKey)
                    }
                    for eventKey in self.likesArray{
                        DataService.instance.eventRef.child(eventKey).observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if snapshot.value == nil{
                                print("snapshot of liked posts = nil")
                            } else{
                                if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                                    let event = Event(key: snapshot.key, dict: postDict, isLiked: true)
                                    self.events.append(event)
                                    self.tableView.reloadData()
                                }
                                
                            }
                        })
                        
                    }
                    
                }
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        print("fav vc viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        print("fav vc viewDidAppear")
    }
    
    func addCell(notif: NSNotification){
        if let event = notif.object as? Event{
            likesArray.append(event.key)
            events.append(event)
            events.sortInPlace({$0.timeStampOfEvent < $1.timeStampOfEvent})
            tableView.reloadData()
        }
    }
    
    func removeCell(notif: NSNotification){
        if let key = notif.object as? String{
            print("tiger 1")
            if let indexValue = self.likesArray.indexOf(key), let favIndexValue = self.events.indexOf({$0.key == key}){
                print("tiger 2")
                self.likesArray.removeAtIndex(indexValue)
                print("tiger 3")
                self.events.removeAtIndex(favIndexValue)
                print("tiger 4")
                let indexPath = NSIndexPath(forRow: favIndexValue, inSection: 0)
                print("tiger 5")
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                print("tiger 6")
                
                
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("favCell") as? EventCell{

            
            cell.configureCell(event)
            return cell
        } else{
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
        return events.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfSection = 0
        
        if events.count > 0{
            numberOfSection = 1
            tableView.backgroundView = nil
        } else{
            let noDataLbl: UILabel = UILabel(frame: CGRectMake(20, 40, 200, 40))
            
            noDataLbl.numberOfLines = 10
            noDataLbl.text = "No events have been liked"
            noDataLbl.font = UIFont(name: "Avenir", size: 20)
            noDataLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
            noDataLbl.textAlignment = .Center
            tableView.backgroundView = noDataLbl
//            tableView.separatorStyle = .None
        }
        return 1
    }


    
}
