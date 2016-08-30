//
//  TaskListFooterView.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/15.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class TaskListFooterView: UIView {
  
  // MARK: - Public
  
  var saveNewTaskClosure: ((taskTitle: String) -> Void)?
  
  
  //MARK: - Property
  
  private var _addTaskButton: UIButton
  private lazy var _taskInputView: TaskInputView = {
    let taskInputView = TaskInputView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0))
    self.addSubview(taskInputView)
    return taskInputView
  }()
  
  
  //MARK: - Lifecycle
  
  override init(frame: CGRect) {
    _addTaskButton = UIButton()
    _addTaskButton.setTitle("添加任务", forState: .Normal)
    
    super.init(frame: frame)
    
    addSubview(_addTaskButton)
    _addTaskButton.snp_makeConstraints { (make) in
      make.leading.equalTo(25)
      make.top.equalTo(5)
      make.bottom.equalTo(-5)
    }
    _addTaskButton.addTarget(self, action: #selector(_addTaskButtonDidClick(_:)), forControlEvents: .TouchUpInside)
 
    backgroundColor = UIColor.orangeColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TaskListFooterView {
  
  //MARK: - Private
  
  @objc
  private func _addTaskButtonDidClick(button: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName("taskInputViewResignFirstResponder", object: self)
    _addTaskButton.hidden = true
    _taskInputView.hidden = false
    _taskInputView.alpha = 1
    
    _taskInputView.snp_remakeConstraints { (make) in
      make.leading.equalTo(0)
      make.trailing.equalTo(0)
      make.top.equalTo(0)
      make.bottom.equalTo(0)
    }
    
//    UIView.animateWithDuration(0.25) {
//      self.layoutIfNeeded()
    _taskInputView.becomeFirstResponder()
//    }
    _taskInputView.saveButtonDidClickAction = { (text: String) in
      self.saveNewTaskClosure?(taskTitle: text)
    }
    
    if _taskInputView.cancelButtonDidClickAction == nil {
      _taskInputView.cancelButtonDidClickAction = { [weak self] in
        self?._addTaskButton.hidden = false
        
        self?._taskInputView.snp_remakeConstraints { (make) in
          make.leading.equalTo(0)
          make.trailing.equalTo(0)
          make.top.equalTo(0)
        }
        
//        UIView.animateWithDuration(0.25, animations: {
//          self?.layoutIfNeeded()
          self?._taskInputView.alpha = 0
//          }, completion: { (finished: Bool) in
            self?._taskInputView.hidden = true
//        })
      }
    }
  }
}
