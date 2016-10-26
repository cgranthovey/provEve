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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoritesVC.loadData), name: "eventDeleted", object: nil)
    }
    
    func loadData(){
        events = [Event]()
        likesArray = [String]()
        
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
                                    self.EventsCategorized = self.events.NewDictWithTimeCategories()
                                    self.tableView.reloadData()
                                    print("here i'm called")
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    func reloadCells(){
        print("i'm called")
        self.tableView.reloadData()
    }

    func addCell(notif: NSNotification){
        if let event = notif.object as? Event{
            likesArray.append(event.key)
            events.append(event)
            events.sortInPlace({$0.timeStampOfEvent < $1.timeStampOfEvent})
            self.EventsCategorized = self.events.NewDictWithTimeCategories()
            tableView.reloadData()
        }
    }
    
    func removeCell(notif: NSNotification){
        if let key = notif.object as? String{
            if let indexValue = self.likesArray.indexOf(key), let favIndexValue = self.events.indexOf({$0.key == key}){
//                self.likesArray.removeAtIndex(indexValue)
//                self.events.removeAtIndex(favIndexValue)
//                self.EventsCategorized = self.events.NewDictWithTimeCategories()
                
       //         tableView.reloadData()
                print("event cat \(EventsCategorized.count)")
            for index in 0 ..< 4{
                print("index \(index)")
                
                if let eventArrayTime = EventsCategorized[index]{
                    var currentSection = 0
                    for eventC in eventArrayTime{
                        if eventC.key == key{
                            if let i = eventArrayTime.indexOf({$0.key == eventC.key}){
                                
                                self.likesArray.removeAtIndex(indexValue)
                                self.events.removeAtIndex(favIndexValue)
                                self.EventsCategorized = self.events.NewDictWithTimeCategories()
                                
                                let indexPath = NSIndexPath(forRow: i, inSection: currentSection)
                                print("yep6")
                                
                                if eventArrayTime.count == 1 {
                                    let indexSet = NSIndexSet(index: currentSection)
                                    self.tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
                                } else{
                                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

                                }
                                
                                print("yep6.3")
                            }
                        }
                    }
                    currentSection = currentSection + 1
                }
            }
            print("tiger 6")
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
