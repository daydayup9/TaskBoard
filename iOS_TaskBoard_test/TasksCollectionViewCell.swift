//
//  TasksCollectionViewCell.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/14.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class TasksCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Public
    
  var tasksViewController: TasksViewController? {
    didSet {
      if _tasksViewController == nil {
        guard let tasksViewController = tasksViewController else { return }
        
        _tasksViewController = tasksViewController
        
        contentView.addSubview(tasksViewController.view)
        tasksViewController.view.snp_makeConstraints(closure: { (make) in
          make.leading.equalTo(0)
          make.trailing.equalTo(0)
          make.top.equalTo(0)
          make.bottom.equalTo(0)
        })
      }
    }
  }
  
  //MARK: - Property
  
  private var _tasksViewController: TasksViewController?
}
