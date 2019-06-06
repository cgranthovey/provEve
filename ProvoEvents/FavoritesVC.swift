//
//  FavoritesVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/27/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseDatabase
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

class FavoritesVC: GeneralEventVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var events = [Event]()
    var likesArray = [String]()     //you have to set likes array as empty if you want to append it from empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesVC.removeCell(_:)), name: NSNotification.Name(rawValue: "heartDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesVC.addCell(_:)), name: NSNotification.Name(rawValue: "heartAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesVC.loadData), name: NSNotification.Name(rawValue: "eventDeleted"), object: nil)
    }
    
    @objc func loadData(){
        events = [Event]()
        likesArray = [String]()
        self.shouldAddTableViewBackground()
        todaysStartTime = self.getTodaysStartTime()
        
        DataService.instance.currentUser.child("likes").queryOrdered(byChild: "timeStampOfEvent").queryStarting(atValue: self.todaysStartTime).observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.value == nil{
            } else{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        self.likesArray.append(snap.key)
                    }
                    for eventKey in self.likesArray{
                        DataService.instance.eventRef.child(eventKey).observeSingleEvent(of: .value, with: { snapshot in
                            if snapshot.value == nil{
                            } else{
                                if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                                    let event = Event(key: snapshot.key, dict: postDict, isLiked: true)
                                    self.events.append(event)
                                    self.EventsCategorized = self.events.NewDictWithTimeCategories()
                                    self.tableView.reloadData()
                                    self.shouldAddTableViewBackground()
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    func reloadCells(){
        self.tableView.reloadData()
    }

    @objc func addCell(_ notif: Notification){
        if let event = notif.object as? Event{
            likesArray.append(event.key)
            events.append(event)
            events.sort(by: {$0.timeStampOfEvent < $1.timeStampOfEvent})
            self.EventsCategorized = self.events.NewDictWithTimeCategories()
            tableView.reloadData()
        }
        self.shouldAddTableViewBackground()
    }
    
    @objc func removeCell(_ notif: Notification){
        if let key = notif.object as? String{
            if let indexValue = self.likesArray.index(of: key), let favIndexValue = self.events.index(where: {$0.key == key}){
                var section = 0         //need this b/c index finds key in dictionary
                for keyEventCategorized in 0 ..< 4{
                    if let eventArray = EventsCategorized[keyEventCategorized]{
                        if let i = eventArray.index(where: {$0.key == key}){
                            
                            self.likesArray.remove(at: indexValue)
                            self.events.remove(at: favIndexValue)
                            if EventsCategorized[keyEventCategorized]?.count == 1{
                                EventsCategorized[keyEventCategorized] = nil
                            } else{
                                self.EventsCategorized[keyEventCategorized]?.remove(at: i)
                            }
                            let indexPath = IndexPath(row: i, section: section)
                            if eventArray.count == 1 {
                                let indexSet = IndexSet(integer: section)
                                self.tableView.deleteSections(indexSet, with: .automatic)
                            } else{
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            }
                        }
                        section = section + 1
                    }
                }
            }
        }
    }
    
    func shouldAddTableViewBackground(){
        tableView.backgroundView = nil
        if events.count > 0{
            tableView.backgroundView = nil
        } else{
            let noDataLbl: UILabel = UILabel(frame: CGRect(x: 20, y: 40, width: 200, height: 40))
            
            noDataLbl.numberOfLines = 10
            noDataLbl.text = "Swipe right to like events."
            noDataLbl.font = UIFont(name: "Avenir", size: 20)
            noDataLbl.numberOfLines = 0
            noDataLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
            noDataLbl.textAlignment = .center
            tableView.backgroundView = noDataLbl
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventDetailsVC"{
            if let destVC = segue.destination as? EventDetailsVC{
                if let event = sender as? Event{
                    destVC.event = event
                }
            }
        }
    }
}
