//
//  TaskInputView.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/28.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class TaskInputView: UIView {
  
  //MARK: - Public

  let inputTextView: UITextView
  let confirmButton: UIButton
  let cancelButton: UIButton
  
  var viewHeightDidChangeClosure: ((height: CGFloat) -> Void)?
  var cancelButtonDidClickAction: (() -> Void)?
  
  //MARK: - Property
  
  var _textViewHeight: CGFloat = 36
  
  
  //MARK: - Lifecycle
  
  override init(frame: CGRect) {
    inputTextView = UITextView(frame: CGRect.zero)
    inputTextView.layer.masksToBounds = true
    inputTextView.layer.cornerRadius = 2
    inputTextView.layer.borderColor = UIColor.redColor().CGColor
    inputTextView.layer.borderWidth = 1
    
    confirmButton = UIButton()
    confirmButton.setTitle("确定", forState: .Normal)
    confirmButton.backgroundColor = UIColor.greenColor()
    confirmButton.layer.masksToBounds = true
    confirmButton.layer.cornerRadius = 4
    
    cancelButton = UIButton()
    cancelButton.setTitle("取消", forState: .Normal)

    super.init(frame: frame)
    
    self.frame = CGRect(x: 0, y: 0, width: frame.width, height: 95)
    
    addSubview(inputTextView)
    inputTextView.snp_makeConstraints { (make) in
      make.leading.equalTo(25)
      make.trailing.equalTo(-25)
      make.top.equalTo(5)
      make.height.equalTo(30)
    }
    inputTextView.delegate = self
    
    addSubview(confirmButton)
    confirmButton.snp_makeConstraints { (make) in
      make.trailing.equalTo(-8)
      make.top.equalTo(inputTextView.snp_bottom).offset(14)
      make.bottom.equalTo(-11)
      make.width.equalTo(65)
      make.height.equalTo(35)
    }
    confirmButton.addTarget(self, action: #selector(_confirmButtonDidClick(_:)), forControlEvents: .TouchUpInside)
    
    addSubview(cancelButton)
    cancelButton.snp_makeConstraints { (make) in
      make.trailing.equalTo(confirmButton.snp_leading).offset(-27)
      make.centerY.equalTo(confirmButton)
    }
    cancelButton.addTarget(self, action: #selector(_cancelButtonDidClick(_:)), forControlEvents: .TouchUpInside)
    
    layoutIfNeeded()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func becomeFirstResponder() -> Bool {
    return inputTextView.becomeFirstResponder()
  }
  
  override func resignFirstResponder() -> Bool {
    return inputTextView.resignFirstResponder()
  }
}

extension TaskInputView: UITextViewDelegate {
  
  //MARK: - UITextViewDelegate
  
  func textViewDidChange(textView: UITextView) {
    let textBounds = textView.bounds
    let newSize = textView.contentSize// sizeThatFits(CGSize(width: textBounds.width, height: CGFloat.max))
    textView.bounds.size = newSize
    
    let newHeight = newSize.height > 30 ? newSize.height : 30
    if newHeight != _textViewHeight {
      _textViewHeight = newHeight
      
      inputTextView.snp_updateConstraints { (make) in
        make.height.equalTo(newHeight)
      }
    }
  }
}

extension TaskInputView {
  
  //MARK: - Private
  
  @objc
  private func _confirmButtonDidClick(button: UIButton) {
    
  }
  
  @objc
  private func _cancelButtonDidClick(button: UIButton) {
    cancelButtonDidClickAction?()
    inputTextView.resignFirstResponder()
    inputTextView.text = ""
    textViewDidChange(inputTextView)
  }
}
