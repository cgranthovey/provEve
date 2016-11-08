//
//  AddEventExt-CV.swift
//  Ibento
//
//  Created by Chris Hovey on 11/7/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation


extension AddEventVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MapPinCell", forIndexPath: indexPath) as? MapPinCell{
            cell.configureCell(img[indexPath.row], label: lbl[indexPath.row])
            if let pickedCell = selectedCellInt{
                if indexPath.row == pickedCell{
                    cell.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                } else{
                    cell.backgroundColor = UIColor.clearColor()
                }
            }
            return cell
        } else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return img.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(collection.frame.width)
        return CGSizeMake(85, 70.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let pickedCellIndex = selectedCellInt{
            let indexPath = NSIndexPath(forItem: pickedCellIndex, inSection: 0)
            if let myCell = collection.cellForItemAtIndexPath(indexPath) as? MapPinCell{
                myCell.backgroundColor = UIColor.clearColor()
            }
        }
        let cell = collection.cellForItemAtIndexPath(indexPath) as? MapPinCell
        selectedCellInt = indexPath.row
        cell?.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        cellHold = cell!
    }
}