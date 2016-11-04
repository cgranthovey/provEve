//
//  MapSettingsLauncher.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/11/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class MapSettingsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let blackView = UIView()
    let collectionWidth: CGFloat = 145
    
    let cellId = "myCell"
    
    var currentlySelectedInt: Int = 0
    var rowHeight: CGFloat = 43
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clearColor()

        
        return cv
    }()
    
    var holdingView = UIView()
    
    
    var button = UIButton()
    
    func showSettings(){
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.allowsSelection = true
        
        //collectionView.setContentOffset(CGPointMake(0, -30), animated: false)
        if let window = UIApplication.sharedApplication().keyWindow{
            
            getCurrentDateInfo1()
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSettings)))
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            let frame = CGRectMake(-self.collectionWidth, 0, self.collectionWidth, window.frame.height)
            holdingView = UIView(frame: frame)
            holdingView.layer.shadowColor = UIColor.blackColor().CGColor
            holdingView.layer.shadowRadius = 5
            holdingView.layer.shadowOpacity = 0.9
            
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissSettings))
            leftSwipe.direction = .Left
            holdingView.addGestureRecognizer(leftSwipe)
            holdingView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            holdingView.alpha = 1.0
            window.addSubview(holdingView)
            
            
            holdingView.addSubview(collectionView)
            collectionView.frame = CGRectMake(0, 25, self.collectionWidth, rowHeight * 8)
            
            holdingView.addSubview(button)

            button = UIButton(frame: CGRectMake(0, collectionView.frame.height + 40, collectionView.frame.width, 43))
            button.addTarget(self, action: #selector(MapSettingsLauncher.buttonPressed), forControlEvents: .TouchUpInside)
            //button.center.x = holdingView.center.x
            //button.center.y = holdingView.center.y
            button.backgroundColor = UIColor.redColor()
            button.hidden = true
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                self.blackView.alpha = 1
                self.holdingView.center.x = self.holdingView.center.x + self.collectionWidth
                }, completion: nil)
            

        }
    }
    
    func buttonPressed(){
        print("Ash pokemon pressed")
    }


    func dismissSettings(){
        print("dismiss map called")
        
        UIView.animateWithDuration(0.5, animations: { 
            self.blackView.alpha = 0
            //self.collectionView.center.x = self.collectionView.center.x - self.collectionWidth
            self.holdingView.center.x = self.holdingView.center.x - self.collectionWidth
            }) { (true) in
                self.blackView.removeFromSuperview()
                self.holdingView.removeFromSuperview()
        }
    }
    
    var dateArray = [NSDate]()
    func getCurrentDateInfo1(){
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let currentHour = calendar.component(.Hour, fromDate: currentDate)
        let currentMinute = calendar.component(.Minute, fromDate: currentDate)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(currentDate.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        
        let todayEnd = todayStartInSeconds + 86400
        let timeInterval = NSTimeInterval(todayEnd)
        
        for index in 0...6{
            let daysStart: Double = Double(todayStartInSeconds) + 86400 * Double(index)
            let date = NSDate(timeIntervalSince1970: daysStart)
            dateArray.append(date)
        }
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as? SettingsCell{
            print("yot")
            var currentlySelected = false
            if currentlySelectedInt == indexPath.row{
                currentlySelected = true
            }
            print("yot1")
            if indexPath.row == 0 {
                print("yot2")
                cell.configureCell("All Events", weekInfo: nil, currentlySelected: currentlySelected)
            } else if indexPath.row == 1{
                print("yot3")
                cell.configureCell("Today", weekInfo: nil, currentlySelected: currentlySelected)
            } else if indexPath.row == 2{
                print("yot4")
                cell.configureCell("Tomorrow", weekInfo: nil, currentlySelected: currentlySelected)
            } else{
                print("yot5")
                cell.configureCell(dateArray[indexPath.row - 1].dayOfTheWeek()!, weekInfo: dateArray[indexPath.row - 1].weekInfo(), currentlySelected: currentlySelected)
                print("mooo")
            }

            return cell
        } else{
            return UICollectionViewCell()
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width, rowHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.clearColor()
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let indexPathOriginal = NSIndexPath(forItem: currentlySelectedInt, inSection: 0)
        if let cell = collectionView.cellForItemAtIndexPath(indexPathOriginal) as? SettingsCell{
            cell.makeImgHidden()
        }
        currentlySelectedInt = indexPath.row
        if let cell2 = collectionView.cellForItemAtIndexPath(indexPath) as? SettingsCell{
            cell2.makeImgViewable()
        }
        
        //NSTimer.performSelector(#selector(MapSettingsLauncher.itemSelected), withObject: indexPath.row, afterDelay: 0.6)
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(MapSettingsLauncher.itemSelected(_:)), userInfo: indexPath.row, repeats: false)
    }
    
    func itemSelected(timer: NSTimer){
        dismissSettings()
        if let indexPathInt = timer.userInfo as? Int{
            
            if indexPathInt == 0 {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "mapParameterAll", object: self, userInfo: nil))
            } else{
                print("The new one is \(indexPathInt)")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "mapParameterChange", object: self, userInfo: ["date": dateArray[indexPathInt - 1]]))
            }
        }
//        if currentlySelectedInt != 0{
//            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "mapParameterChange", object: self, userInfo: ["date": dateArray[currentlySelectedInt - 1]]))
//        }
    }
    
    override init() {
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.registerClass(SettingsCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
