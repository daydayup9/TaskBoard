//
//  AddTaskListCollectionViewCell.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/27.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class AddTaskListCollectionViewCell: UICollectionViewCell {
  
  
  // MARK: - Public
  
  var saveNewTaskListsClosure: ((taskListsTitle: String) -> Void)?
  
  // MARK: - Private
  
  private var _addProjectButton: UIButton
  private var _backView: UIView
//  private var _taskInputView: TaskInputView
  private lazy var _taskInputView: TaskInputView = {
    let taskInputView = TaskInputView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0))
    self._backView.addSubview(taskInputView)
    return taskInputView
  }()
  
  override init(frame: CGRect) {
    _backView = UIView()
    _backView.translatesAutoresizingMaskIntoConstraints = false
    
    _backView.backgroundColor = UIColor.orangeColor()
    _backView.layer.cornerRadius = 4
    _backView.layer.masksToBounds = true
    
    _addProjectButton = UIButton(frame: CGRect.zero)
    _addProjectButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    _addProjectButton.setTitle("新增项目", forState: .Normal)

    super.init(frame: frame)
    
    backgroundColor = UIColor.purpleColor()
    
    contentView.addSubview(_backView)
    _backView.snp_makeConstraints { (make) in
      make.leading.equalTo(0)
      make.trailing.equalTo(0)
      make.top.equalTo(0)
      make.height.equalTo(50)
    }
    
    _backView.addSubview(_addProjectButton)
    _addProjectButton.snp_makeConstraints { (make) in
      make.leading.equalTo(0)
      make.trailing.equalTo(0)
      make.top.equalTo(0)
      make.bottom.equalTo(0)

    }

    _addProjectButton.addTarget(self, action: #selector(__addProjectButtonDidClick(_:)), forControlEvents: .TouchUpInside)
    
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension AddTaskListCollectionViewCell {
  
  @objc
  private func __addProjectButtonDidClick(button: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName("taskInputViewResignFirstResponder", object: self)
    _addProjectButton.hidden = true
    _taskInputView.hidden = false
    _taskInputView.alpha = 1
    
    _taskInputView.snp_remakeConstraints { (make) in
      make.leading.equalTo(0)
      make.trailing.equalTo(0)
      make.top.equalTo(0)
      make.bottom.equalTo(0).priorityHigh()
    }
    
    _backView.snp_updateConstraints { (make) in
      make.height.equalTo(_taskInputView.frame.height)
    }
    UIView.animateWithDuration(0.25) {
      self.layoutIfNeeded()
      self._taskInputView.becomeFirstResponder()
    }
 
    
    _taskInputView.saveButtonDidClickAction = { (text: String) in
      self.saveNewTaskListsClosure?(taskListsTitle: text)
    }
    
    if _taskInputView.cancelButtonDidClickAction == nil {
      _taskInputView.cancelButtonDidClickAction = { [weak self] in
        self?._addProjectButton.hidden = false
        self?._taskInputView.alpha = 0
        self?._taskInputView.hidden = true
        
        self?._taskInputView.snp_remakeConstraints { (make) in
          make.leading.equalTo(0)
          make.trailing.equalTo(0)
          make.top.equalTo(0)
        }
        self?._backView.snp_updateConstraints { (make) in
          make.height.equalTo(50)
        }

        UIView.animateWithDuration(0.25, animations: {
          self?.layoutIfNeeded()
          }, completion: { (finished: Bool) in
        })
      }
    }
  }
}
