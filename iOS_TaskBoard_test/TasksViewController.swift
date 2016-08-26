//
//  TasksViewController.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/14.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit

let kTaskListHeightDidChangedNotification = "taskListHeightDidChangedNotification"
let kTaskViewHeightNotigicationKey = "max_height"
let kTaskSuperViewHeightNotigicationKey = "super_view_height"

class TasksViewController: UIViewController {
  
  //MARK: - Public
  
  var taskListID: String = ""
  
  var tasksTableView: TasksTableView!
  var viewHeightConstrain: NSLayoutConstraint?
  var listHeaderViewLongPressActionClosure: ((longPressGuesture: UILongPressGestureRecognizer) -> Void)?
  
  var _listHeaderView: TaskListHeaderView!
  var _listFooterView: TaskListFooterView!
  
  func reloadTask(task: Task, atIndexPath indexPath: NSIndexPath) {
    _tasks[indexPath.row] = task
    tasksTableView.beginUpdates()
    tasksTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .Automatic)
    tasksTableView.endUpdates()
  }
  
  func insertTask(task: Task, atIndexPath indexPath: NSIndexPath) {
    tasksTableView.beginUpdates()
    _tasks.insert(task, atIndex: indexPath.row)
    tasksTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .Automatic)
    tasksTableView.endUpdates()
  }
  
  func removeTask(atIndexPath indexPath: NSIndexPath) {
    if indexPath.row < 0 || indexPath.row >= _tasks.count {
      return
    }
    tasksTableView.beginUpdates()
    _tasks.removeAtIndex(indexPath.row)
    tasksTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .Automatic)
    tasksTableView.endUpdates()
  }
  
  func moveTask(atIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
    tasksTableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
  }
  
  var tasksTableViewWillEndScrollClosure: ((position: CGPoint) -> Void)?
  
//  func setupData(tasks: [String], maxHeight: CGFloat, superViewHeight: CGFloat, scrollToPoint point: CGPoint?=nil) {
  func setupData(tasks: [Task], maxHeight: CGFloat, superViewHeight: CGFloat, scrollToPoint point: CGPoint?=nil) {

    _tasks = tasks
    
    tasksTableView.reloadData()
    
    updateTableViewHeight(false, maxHeight: maxHeight, superViewHeight: superViewHeight)
    
    guard let point = point else { return }
    tasksTableView.scrollRectToVisible(CGRect(origin: point, size: CGSize(width: 100, height: 5)), animated: false)
  }
  
  func updateTableViewHeight(animated: Bool, additionHeight: CGFloat=0, maxHeight: CGFloat, superViewHeight: CGFloat) {
    func updateTableViewHeight() -> CGFloat {
      //      self.tasksTableView.frame.size.height = self.tasksTableView.contentSize.height > 560 ? 560 : self.tasksTableView.contentSize.height
      //    view.layoutIfNeeded()
      //      self._listFooterView.frame.origin.y = self.tasksTableView.frame.size.height + 40
      //      self.view.frame.size.height = 80 + self.tasksTableView.frame.size.height
      
      let headerHeight = _listHeaderView.frame.height
      let tableViewHeight = tasksTableView.contentSize.height
      let footerHeight = _listFooterView.frame.height
      
      var viewHeight = headerHeight + tableViewHeight + footerHeight
      if headerHeight == 0 {
        viewHeight += 46.5
      }
      if footerHeight == 0 {
        viewHeight += 40
      }
      
      viewHeight += additionHeight
      viewHeight = viewHeight > maxHeight ? maxHeight : viewHeight
      
      debugPrint("********* tableViewHeight \(tableViewHeight) header \(headerHeight)  view_height \(viewHeight)")
      
      view.snp_updateConstraints { (make) in
        make.bottom.equalTo(-(superViewHeight - viewHeight))
      }
      
      return viewHeight
    }
    
    if animated {
      UIView.animateWithDuration(0.25) {
        let newViewHeight = updateTableViewHeight()
        let additionHeight = newViewHeight - self.view.frame.height
        self._listFooterView.frame.origin.y += additionHeight
        self.tasksTableView.frame.size.height += additionHeight
        self.view.frame.size.height = newViewHeight
      }
    } else {
      updateTableViewHeight()
    }
  }
  
  
  //MARK: - Property
  
  private var _tasks: [Task] = []
  
  //MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _setupAppearance()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_viewHeightDidChanged(_:)), name: kTaskListHeightDidChangedNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension TasksViewController: UITableViewDataSource, UITableViewDelegate {
  
  //MARK: - UITableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return _tasks.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TaskTableViewCell
    cell.textLabel?.text = _tasks[indexPath.row].title
    cell.contentView.hidden = _tasks[indexPath.row].hidden
    
    return cell
  }
  
  //MARK: - UITableViewDelegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

extension TasksViewController: UIScrollViewDelegate {
  
  //MARK: - UIScrollViewDelegate
  
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // targetContentOffset.memory.y (0...scrollView.contentSize.height)
    tasksTableViewWillEndScrollClosure?(position: CGPoint(x: 0, y: targetContentOffset.memory.y))
  }
}

extension TasksViewController {
  
  //MARK: - Private
  
  private func _setupAppearance() {
    view.backgroundColor = UIColor.lightGrayColor()
    view.layer.masksToBounds = true
    view.layer.cornerRadius = 5
    
    _listHeaderView = TaskListHeaderView(frame: CGRect.zero)
    
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(_listHeaderViewDidLongPressed(_:)))
    longPress.minimumPressDuration = 0.25
    _listHeaderView.addGestureRecognizer(longPress)
    
    view.addSubview(_listHeaderView)
    _listHeaderView.snp_makeConstraints { (make) in
      make.leading.equalTo(0)
      make.trailing.equalTo(0)
      make.top.equalTo(0)
    }
    //    headerView.frame = CGRect(x: 0, y: 0, width: 321, height: 40)
    
    tasksTableView = TasksTableView(frame: CGRect.zero)
    tasksTableView.dataSource = self
    tasksTableView.delegate = self
    tasksTableView.registerClass(TaskTableViewCell.self, forCellReuseIdentifier: "cell")
    tasksTableView.separatorStyle = .None
    tasksTableView.backgroundColor = UIColor.lightGrayColor()
    
    view.addSubview(tasksTableView)
    tasksTableView.snp_makeConstraints { (make) in
      make.leading.equalTo(0)
      make.trailing.equalTo(0)
      make.top.equalTo(_listHeaderView.snp_bottom)
      //      make.bottom.equalTo(0)
    }
    //    tasksTableView.frame = CGRect(x: 0, y: 40, width: 321, height: 0)
    
    _listFooterView = TaskListFooterView(frame: CGRect.zero)
    view.addSubview(_listFooterView)
    _listFooterView.snp_makeConstraints { (make) in
      make.leading.equalTo(0)
      make.trailing.equalTo(0)
      make.top.equalTo(tasksTableView.snp_bottom)
      make.bottom.equalTo(0)
      make.height.equalTo(40)
    }
    
    //    _listFooterView.frame = CGRect(x: 0, y: 40, width: 321, height: 40)
  }
  
  
  //MARK: - Notification
  
  @objc
  private func _viewHeightDidChanged(notification: NSNotification) {
    guard let maxHeight = notification.userInfo?["max_height"] as? CGFloat else { return }
    guard let superViewHeight = notification.userInfo?["super_view_height"] as? CGFloat else { return }
    
    updateTableViewHeight(true, maxHeight: maxHeight, superViewHeight: superViewHeight)
  }
  
  @objc
  private func _listHeaderViewDidLongPressed(pressGuesture: UILongPressGestureRecognizer) {
    listHeaderViewLongPressActionClosure?(longPressGuesture: pressGuesture)
  }
}