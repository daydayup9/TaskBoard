//
//  CustomPageWidthCollectionViewFlowLayout.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/14.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class CustomPageWidthCollectionViewFlowLayout: UICollectionViewFlowLayout {
  
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    
    if let collectionView = collectionView,
      first = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)),
      last = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: collectionView.numberOfItemsInSection(0) - 1, inSection: 0))
    {
      sectionInset = UIEdgeInsets(top: 0, left: collectionView.frame.width / 2 - first.bounds.size.width / 2, bottom: 0, right: collectionView.frame.width / 2  - last.bounds.size.width / 2)
    }
    
    let collectionViewSize = self.collectionView!.bounds.size
    let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width * 0.5
    
    var proposedRect = self.collectionView!.bounds
    
    // comment this out if you don't want it to scroll so quickly
    proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
    
    var candidateAttributes: UICollectionViewLayoutAttributes?
    for attributes in self.layoutAttributesForElementsInRect(proposedRect)! {
      // == Skip comparison with non-cell items (headers and footers) == //
      if attributes.representedElementCategory != .Cell {
        continue
      }
      
      
      // Get collectionView current scroll position
      let currentOffset = self.collectionView!.contentOffset
      
      // Don't even bother with items on opposite direction
      // You'll get at least one, or else the fallback got your back
      if (attributes.center.x <= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x > 0) || (attributes.center.x >= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x < 0) {
        continue
      }
      
      
      // First good item in the loop
      if candidateAttributes == nil {
        candidateAttributes = attributes
        continue
      }
      
      // Save constants to improve readability
      let lastCenterOffset = candidateAttributes!.center.x - proposedContentOffsetCenterX
      let centerOffset = attributes.center.x - proposedContentOffsetCenterX
      
      if fabsf( Float(centerOffset) ) < fabsf( Float(lastCenterOffset) ) {
        candidateAttributes = attributes
      }
    }
    
    if candidateAttributes != nil {
      // Great, we have a candidate
      return CGPoint(x: candidateAttributes!.center.x - collectionViewSize.width * 0.5, y: proposedContentOffset.y)
    } else {
      // Fallback
      return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
  }
}
