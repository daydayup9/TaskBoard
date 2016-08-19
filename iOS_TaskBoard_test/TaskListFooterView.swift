//
//  TaskListFooterView.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/15.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class TaskListFooterView: UIView {
  
  //MARK: - Property
  
  private var _addTaskButton: UIButton
  private var _taskNameTextView: UITextView
  private var _confirmButton: UIButton
  private var _cancelButton: UIButton
  
  
  //MARK: - Lifecycle
  
  override init(frame: CGRect) {
    _addTaskButton = UIButton()
    _addTaskButton.setTitle("添加任务", forState: .Normal)
    
    _taskNameTextView = UITextView()
    
    _confirmButton = UIButton()
    _cancelButton = UIButton()
    
    super.init(frame: frame)
    
//    addSubview(_addTaskButton)
//    _addTaskButton.snp_makeConstraints { (make) in
//      make.leading.equalTo(25)
//      make.top.equalTo(5)
//      make.bottom.equalTo(-5)
//    }
    
    addSubview(_taskNameTextView)
    _taskNameTextView.snp_makeConstraints { (make) in
      make.leading.equalTo(25)
      make.trailing.equalTo(-25)
      make.top.equalTo(5)
      make.bottom.equalTo(-5)
    }
    
    backgroundColor = UIColor.orangeColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
