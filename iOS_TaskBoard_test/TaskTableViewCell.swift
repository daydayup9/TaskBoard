//
//  TaskTableViewCell.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/14.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
  
  //MARK: - Public
  
  var containerView: UIView

  
  //MARK: - Lifecycle

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    containerView = UIView(frame: CGRect.zero)
    containerView.layer.masksToBounds = true
    containerView.layer.cornerRadius = 3
    containerView.backgroundColor = UIColor.whiteColor()
    
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = UIColor.lightGrayColor()
    selectionStyle = .None
    
    contentView.addSubview(containerView)
    containerView.snp_makeConstraints { (make) in
      make.leading.equalTo(5)
      make.trailing.equalTo(-5)
      make.top.equalTo(3)
      make.bottom.equalTo(-3)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
