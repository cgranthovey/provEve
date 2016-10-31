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
        self.shouldAddTableViewBackground()
        todaysStartTime = self.getTodaysStartTime()
        DataService.instance.currentUser.child("likes").queryOrderedByChild("timeStampOfEvent").queryStartingAtValue(self.todaysStartTime).observeSingleEventOfType(.Value, withBlock: {snapshot in
            if snapshot.value == nil{
            } else{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        self.likesArray.append(snap.key)
                    }
                    for eventKey in self.likesArray{
                        DataService.instance.eventRef.child(eventKey).observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if snapshot.value == nil{

                            } else{
                                if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                                    let event = Event(key: snapshot.key, dict: postDict, isLiked: true)
                                    self.events.append(event)
                                    self.EventsCategorized = self.events.NewDictWithTimeCategories()
                                    self.tableView.reloadData()
                                    self.shouldAddTableViewBackground()

                                    print("here i'm called")
                                }
                                print("snapshot of liked posts = nil")

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
            print("add cell called")
            likesArray.append(event.key)
            events.append(event)
            events.sortInPlace({$0.timeStampOfEvent < $1.timeStampOfEvent})
            self.EventsCategorized = self.events.NewDictWithTimeCategories()
            tableView.reloadData()
        }
        self.shouldAddTableViewBackground()

    }
    
    func removeCell(notif: NSNotification){
        if let key = notif.object as? String{
            if let indexValue = self.likesArray.indexOf(key), let favIndexValue = self.events.indexOf({$0.key == key}){
                print("event cat \(EventsCategorized.count)")
                var section = 0         //need this b/c index finds key in dictionary
                for keyEventCategorized in 0 ..< 4{
                    print("index \(keyEventCategorized)")
                    
                    if let eventArray = EventsCategorized[keyEventCategorized]{
                                if let i = eventArray.indexOf({$0.key == key}){
                                    
                                    self.likesArray.removeAtIndex(indexValue)
                                    self.events.removeAtIndex(favIndexValue)
                                    print("mice \(EventsCategorized.count)")
                                    if EventsCategorized[keyEventCategorized]?.count == 1{
                                        EventsCategorized[keyEventCategorized] = nil
                                    } else{
                                        print("winter")
                                        print(self.EventsCategorized[keyEventCategorized]?.count)
                                        self.EventsCategorized[keyEventCategorized]?.removeAtIndex(i)
                                        print(self.EventsCategorized[keyEventCategorized]?.count)
                                    }
                                    print("mice222 \(EventsCategorized.count)")
                                    let indexPath = NSIndexPath(forRow: i, inSection: section)
                                    print("yep6")
                                    
                                    if eventArray.count == 1 {
                                        print("yep6.1")
                                        let indexSet = NSIndexSet(index: section)
                                        self.tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
                                    } else{
                                        print("yep6.2")
                                        print(section)
                                        print(i)
                                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                    }

                                }
                        section = section + 1

                    }
                }
                print("tiger 6")
            }
        }
    }
    
    func shouldAddTableViewBackground(){
        print("yep")
        tableView.backgroundView = nil
        if events.count > 0{
            tableView.backgroundView = nil
        } else{
            let noDataLbl: UILabel = UILabel(frame: CGRectMake(20, 40, 200, 40))
            
            noDataLbl.numberOfLines = 10
            noDataLbl.text = "Swipe right to like events."
            noDataLbl.font = UIFont(name: "Avenir", size: 20)
            noDataLbl.numberOfLines = 0
            noDataLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
            noDataLbl.textAlignment = .Center
            tableView.backgroundView = noDataLbl
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
