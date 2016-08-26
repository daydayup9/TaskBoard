//
//  TasksTableView.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/20.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class TasksTableView: UITableView, AutoScrollScrollView {

  //MARK: - AutoScrollScrollView
  
  var autoScrollManager: AutoScrollManager?
  
  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_stopAutoScrollNotifice), name: "tableviewStopAutoScroll", object: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc
  private func _stopAutoScrollNotifice(notifice: NSNotification){
    autoScrollManager?.stopAutoScroll()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
}
