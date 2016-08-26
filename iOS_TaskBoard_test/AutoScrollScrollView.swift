//
//  AutoScrollScrollView.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/19.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

protocol AutoScrollScrollView {
  var autoScrollManager: AutoScrollManager? { get set }
}

extension AutoScrollScrollView where Self: UIScrollView {

  mutating func touchRectDidChanged(touchRect: CGRect) {
    if autoScrollManager == nil {
      autoScrollManager = AutoScrollManager()
      autoScrollManager?.scrollViewRect = frame
      autoScrollManager?.shouldScroll = { [weak self](scrollDistance: CGFloat, scrollDirection: AutoScrollManager.ScrollDirection) in
        guard let weakSelf = self else { return }
        
        switch scrollDirection {
        case .horizontal:
          if scrollDistance > 0 {
            if weakSelf.contentOffset.x == 0 { return }
            if weakSelf.contentOffset.x - scrollDistance < 0 {
              weakSelf.contentOffset.x = 0
              return
            }
          } else {
            if weakSelf.contentOffset.x == weakSelf.contentSize.width - weakSelf.frame.width / weakSelf.transform.a { return }
            if weakSelf.contentOffset.x - scrollDistance > weakSelf.contentSize.width - weakSelf.frame.width / weakSelf.transform.a {
              weakSelf.contentOffset.x = weakSelf.contentSize.width - weakSelf.frame.width / weakSelf.transform.a
              return
            }
          }
          self?.contentOffset.x -= scrollDistance
        case .vertical:
          
          if scrollDistance > 0 {
            if weakSelf.contentOffset.y == 0 { return }
            if weakSelf.contentOffset.y - scrollDistance < 0 {
              weakSelf.contentOffset.y = 0
              return
            }
          } else {
            if weakSelf.contentOffset.y == weakSelf.contentSize.height - weakSelf.frame.height / weakSelf.transform.d { return }
            if weakSelf.contentOffset.y - scrollDistance > weakSelf.contentSize.height - weakSelf.frame.height / weakSelf.transform.d {
              weakSelf.contentOffset.y = weakSelf.contentSize.height - weakSelf.frame.height / weakSelf.transform.d
              return
            }
          }
          weakSelf.contentOffset.y -= scrollDistance
        }
      }
    }
    
    autoScrollManager?.touchRect = touchRect
  }
    
  func stopAutoScroll() {
    autoScrollManager?.stopAutoScroll()
  }
}
