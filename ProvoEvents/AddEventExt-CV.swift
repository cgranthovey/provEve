//
//  AddEventExt-CV.swift
//  Ibento
//
//  Created by Chris Hovey on 11/7/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation


extension AddEventVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapPinCell", for: indexPath) as? MapPinCell{
            cell.configureCell(img[indexPath.row], label: lbl[indexPath.row])
            if let pickedCell = selectedCellInt{
                if indexPath.row == pickedCell{
                    cell.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                } else{
                    cell.backgroundColor = UIColor.clear
                }
            }
            return cell
        } else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return img.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        print(collection.frame.width)
        return CGSize(width: 85, height: 70.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let pickedCellIndex = selectedCellInt{
            let indexPath = IndexPath(item: pickedCellIndex, section: 0)
            if let myCell = collection.cellForItem(at: indexPath) as? MapPinCell{
                myCell.backgroundColor = UIColor.clear
            }
        }
        let cell = collection.cellForItem(at: indexPath) as? MapPinCell
        selectedCellInt = indexPath.row
        cell?.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        cellHold = cell!
    }
}
