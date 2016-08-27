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
  
  private var _textViewHeight: CGFloat = 36
  
  
  //MARK: - Lifecycle
  
  override init(frame: CGRect) {
    _addTaskButton = UIButton()
    _addTaskButton.setTitle("添加任务", forState: .Normal)
    
    _taskNameTextView = UITextView(frame: CGRect.zero)
    _taskNameTextView.layer.masksToBounds = true
    _taskNameTextView.layer.cornerRadius = 2
    _taskNameTextView.layer.borderColor = UIColor.redColor().CGColor
    _taskNameTextView.layer.borderWidth = 1
    _taskNameTextView.hidden = true
    
    _confirmButton = UIButton()
    _confirmButton.setTitle("确定", forState: .Normal)
    _confirmButton.hidden = true
    _confirmButton.alpha = 0
    _confirmButton.backgroundColor = UIColor.greenColor()
    _confirmButton.layer.masksToBounds = true
    _confirmButton.layer.cornerRadius = 4
    
    _cancelButton = UIButton()
    _cancelButton.setTitle("取消", forState: .Normal)
    _cancelButton.hidden = true
    _cancelButton.alpha = 0
    
    super.init(frame: frame)
    
    addSubview(_addTaskButton)
    _addTaskButton.snp_makeConstraints { (make) in
      make.leading.equalTo(25)
      make.top.equalTo(5)
      make.bottom.equalTo(-5)
    }
    _addTaskButton.addTarget(self, action: #selector(_addTaskButtonDidClick(_:)), forControlEvents: .TouchUpInside)
    
    addSubview(_taskNameTextView)
    _taskNameTextView.delegate = self
    
    addSubview(_confirmButton)
    _confirmButton.snp_makeConstraints { (make) in
      make.trailing.equalTo(-8)
      make.bottom.equalTo(-11)
      make.width.equalTo(65)
      make.height.equalTo(35)
    }
    _confirmButton.addTarget(self, action: #selector(_confirmButtonDidClick(_:)), forControlEvents: .TouchUpInside)
    
    addSubview(_cancelButton)
    _cancelButton.snp_makeConstraints { (make) in
      make.trailing.equalTo(_confirmButton.snp_leading).offset(-27)
      make.centerY.equalTo(_confirmButton)
    }
    _cancelButton.addTarget(self, action: #selector(_cancelButtonDidClick(_:)), forControlEvents: .TouchUpInside)

    backgroundColor = UIColor.orangeColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TaskListFooterView: UITextViewDelegate {
  
  //MARK: - UITextViewDelegate
  
  func textViewDidChange(textView: UITextView) {
    let textBounds = textView.bounds
    let newSize = textView.contentSize// sizeThatFits(CGSize(width: textBounds.width, height: CGFloat.max))
    textView.bounds.size = newSize
    
    let newHeight = newSize.height > 36 ? newSize.height : 36
    if newHeight != _textViewHeight {
      _textViewHeight = newHeight
      
      _taskNameTextView.snp_updateConstraints { (make) in
        make.height.equalTo(newHeight)
      }
      
      UIView.animateWithDuration(0.25) {
        self.layoutIfNeeded()
      }
    }
  }
}

extension TaskListFooterView {
  
  //MARK: - Private
  
  @objc
  private func _addTaskButtonDidClick(button: UIButton) {
    _addTaskButton.hidden = true
    _taskNameTextView.hidden = false
    _confirmButton.hidden = false
    _cancelButton.hidden = false
    
    _taskNameTextView.frame = CGRect(x: 25, y: 5, width: frame.width - 50, height: 46)
    _taskNameTextView.snp_remakeConstraints { (make) in
      make.leading.equalTo(25)
      make.trailing.equalTo(-25)
      make.top.equalTo(5)
      make.bottom.equalTo(_confirmButton.snp_top).offset(-14)
      make.height.equalTo(36)
    }
    
    _taskNameTextView.becomeFirstResponder()
    
    UIView.animateWithDuration(0.25) {
      self.layoutIfNeeded()
      
      self._confirmButton.alpha = 1
      self._cancelButton.alpha = 1
    }
  }
  
  @objc
  private func _confirmButtonDidClick(button: UIButton) {
    
  }
  
  @objc
  private func _cancelButtonDidClick(button: UIButton) {
    _addTaskButton.hidden = false
    _taskNameTextView.hidden = true
    _taskNameTextView.resignFirstResponder()
    
    _taskNameTextView.frame = CGRect(x: 25, y: 5, width: frame.width - 50, height: 46)
    _taskNameTextView.snp_removeConstraints()
    
    UIView.animateWithDuration(0.25, animations: {
      self.layoutIfNeeded()
      
      self._confirmButton.alpha = 0
      self._cancelButton.alpha = 0
    }) { (finished: Bool) in
      self._confirmButton.hidden = true
      self._cancelButton.hidden = true
    }
  }
}
