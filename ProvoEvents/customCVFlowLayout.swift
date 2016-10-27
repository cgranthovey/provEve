//
//  customCVFlowLayout.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/26/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

//class customCVFlowLayout: UICollectionViewLayout {
//    override func awakeFromNib() {
////        self.itemSize = CGSizeMake(75.0, 75.0);
////        self.minimumInteritemSpacing = 10.0;
////        self.minimumLineSpacing = 10.0;
////        self.scrollDirection = .Horizontal;
////        self.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
//    }
//    
//    
//    
//    
//    func collectionView(collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        var offsetAdjustment = CGFloat(MAXFLOAT)
//        let horizontalOffset = CGFloat(proposedContentOffset.x + 5)
//        
//        let targetRect = CGRectMake(proposedContentOffset.x, 0, (self.collectionView?.bounds.size.width)!, self.collectionView!.bounds.size.height)
//        var array: NSArray = [super.layoutAttributesForElementsInRect(targetRect)!]
//        
//        
//        for layoutAttributes in array{
//            var itemOffset = CGFloat(layoutAttributes.frame.origin.x)
//            if (abs(itemOffset - horizontalOffset) < abs(offsetAdjustment)){
//                offsetAdjustment = itemOffset - horizontalOffset
//            }
//        }
//        return CGPointMake(proposedContentOffset.x + CGFloat(offsetAdjustment), proposedContentOffset.y)
//    }
//    
//
//}
