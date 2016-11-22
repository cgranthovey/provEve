//
//  MapSettingsLauncher.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/11/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class MapSettingsLauncher: NSObject{
    
    let blackView = UIView()
    let collectionWidth: CGFloat = 145
    let cellId = "myCell"
    var currentlySelectedInt: Int = 0
    var rowHeight: CGFloat = 43
    var holdingView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        return cv
    }()
    
    func showSettings(){
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.allowsSelection = true
        
        if let window = UIApplication.shared.keyWindow{
            getCurrentDateInfo1()
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSettings)))
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            let frame = CGRect(x: -self.collectionWidth, y: 0, width: self.collectionWidth, height: window.frame.height)
            holdingView = UIView(frame: frame)
            holdingView.layer.shadowColor = UIColor.black.cgColor
            holdingView.layer.shadowRadius = 5
            holdingView.layer.shadowOpacity = 0.9
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissSettings))
            leftSwipe.direction = .left
            holdingView.addGestureRecognizer(leftSwipe)
            holdingView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            holdingView.alpha = 1.0
            window.addSubview(holdingView)
            holdingView.addSubview(collectionView)
            collectionView.frame = CGRect(x: 0, y: 25, width: self.collectionWidth, height: rowHeight * 8)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.holdingView.center.x = self.holdingView.center.x + self.collectionWidth
                }, completion: nil)
        }
    }

    func dismissSettings(){
        UIView.animate(withDuration: 0.5, animations: { 
            self.blackView.alpha = 0
            self.holdingView.center.x = self.holdingView.center.x - self.collectionWidth
            }, completion: { (true) in
                self.blackView.removeFromSuperview()
                self.holdingView.removeFromSuperview()
        }) 
    }
    
    var dateArray = [Date]()
    func getCurrentDateInfo1(){
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = (calendar as NSCalendar).component(.hour, from: currentDate)
        let currentMinute = (calendar as NSCalendar).component(.minute, from: currentDate)
        let secondsInToday = (currentHour * 60 * 60 + currentMinute * 60)
        let nowInSeconds = Int(currentDate.timeIntervalSince1970)
        let todayStartInSeconds = nowInSeconds - secondsInToday
        
        for index in 0...6{
            let daysStart: Double = Double(todayStartInSeconds) + 86400 * Double(index)
            let date = Date(timeIntervalSince1970: daysStart)
            dateArray.append(date)
        }
    }

    func itemSelected(_ timer: Timer){
        dismissSettings()
        if let indexPathInt = timer.userInfo as? Int{
            if indexPathInt == 0 {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "mapParameterChange"), object: self, userInfo: nil))
            } else{
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "mapParameterChange"), object: self, userInfo: ["date": dateArray[indexPathInt - 1]]))
            }
        }
    }
    
    override init() {
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SettingsCell.self, forCellWithReuseIdentifier: cellId)
    }
}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//collectionView extension

extension MapSettingsLauncher: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? SettingsCell{
            var currentlySelected = false
            if currentlySelectedInt == indexPath.row{
                currentlySelected = true
            }
            if indexPath.row == 0 {
                cell.configureCell("All Events", weekInfo: nil, currentlySelected: currentlySelected)
            } else if indexPath.row == 1{
                cell.configureCell("Today", weekInfo: nil, currentlySelected: currentlySelected)
            } else if indexPath.row == 2{
                cell.configureCell("Tomorrow", weekInfo: nil, currentlySelected: currentlySelected)
            } else{
                cell.configureCell(dateArray[indexPath.row - 1].dayOfTheWeek()!, weekInfo: dateArray[indexPath.row - 1].weekInfo(), currentlySelected: currentlySelected)
            }
            return cell
        } else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: rowHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexPathOriginal = IndexPath(item: currentlySelectedInt, section: 0)
        if let cell = collectionView.cellForItem(at: indexPathOriginal) as? SettingsCell{
            cell.makeImgHidden()
        }
        currentlySelectedInt = indexPath.row
        if let cell2 = collectionView.cellForItem(at: indexPath) as? SettingsCell{
            cell2.makeImgViewable()
        }
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MapSettingsLauncher.itemSelected(_:)), userInfo: indexPath.row, repeats: false)
    }
}
