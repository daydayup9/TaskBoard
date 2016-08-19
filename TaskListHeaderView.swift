//
//  TaskListHeaderView.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/15.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class TaskListHeaderView: UIView {
  
  //MARK: - Property
  
  private var _listNameLabel: UILabel
  private var _optionButton: UIButton
  
  
  //MARK: - Lifecycle
  
  override init(frame: CGRect) {
    _listNameLabel = UILabel(frame: CGRect.zero)
    _listNameLabel.text = "列表标题"
    
    _optionButton = UIButton()
    
    super.init(frame: frame)
    
    addSubview(_listNameLabel)
    _listNameLabel.snp_makeConstraints { (make) in
      make.leading.equalTo(7)
      make.top.equalTo(13)
      make.bottom.equalTo(-13)
    }
    
    addSubview(_optionButton)
    _optionButton.snp_makeConstraints { (make) in
      make.leading.equalTo(_listNameLabel.snp_trailing).offset(3).priorityLow()
      make.trailing.equalTo(-12)
      make.centerY.equalTo(_listNameLabel.snp_centerY)
    }
    
    backgroundColor = UIColor.orangeColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
