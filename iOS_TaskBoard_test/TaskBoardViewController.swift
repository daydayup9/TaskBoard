//
//  ViewController.swift
//  iOS_TaskBoard_test
//
//  Created by darui on 16/8/10.
//  Copyright © 2016年 Worktile. All rights reserved.
//

import UIKit
import SnapKit
import YYKeyboardManager
import KeyboardMan

protocol TaskType {
  var hidden: Bool { get set }
}

protocol TaskListType {
  var hidden: Bool { get set }
  var tasks: [Task] { get set }
}

struct Task: TaskType {
  var title: String
  var hidden: Bool = false
}

struct TaskList: TaskListType {
  let name: String
  var hidden: Bool = false
  var tasks: [Task]
}

class TaskBoardViewController: UIViewController {
  
  //MARK: - Public
  
  var lineSpacing: CGFloat = 13
  var margin: CGFloat      = 14
  var top: CGFloat         = 10
  var bootom: CGFloat      = 20
  
  //MARK: - Commons
  
  private let kScreenWidth = UIScreen.mainScreen().bounds.width
  private let kScreenHeight = UIScreen.mainScreen().bounds.height
  
  private enum ScreenDirection {
    case vertical
    case horizontal
  }
  
  private let kZoomScale: CGFloat = 0.5
  
  
  //MARK: - Property
  
  private var _containerScrollView: UIScrollView!
  private var _collectionView: TaskBoardCollectionView!
  private var _collectionViewFlowLayout: UICollectionViewFlowLayout!
  private var _screenDirection: ScreenDirection = .vertical
  private var lastProposedContentOffsetX: CGFloat = 0
  private var _itemHeight: CGFloat {
    switch _screenDirection {
    case .vertical:
      return (kScreenHeight - top - bootom - _navigationBarHight) * (_isZooming ? 1 / kZoomScale : 1 )
    case .horizontal:
      return (kScreenWidth - top - bootom - _navigationBarHight) * (_isZooming ? 1 / kZoomScale : 1 )
    }
  }
  private var _keyboardHeight: CGFloat = 0
  
  private var _pageScrollView: UIScrollView!
  
  private var _snapshotView: UIView?
  private var _draggingTaskCell: TaskTableViewCell?
  private var _draggingListCell: TasksCollectionViewCell?
  
  private var _lastDragging: (listIndexPath: NSIndexPath, taskIndexPath: NSIndexPath)?
  
  //  private var _taskLists:[[String]] = []
  
  private var _taskLists: [TaskList] = []
  
  private var _keyboardMan: KeyboardMan!
  private var _isZooming: Bool = false
  private var _isListColelctionViewIsZooming: Bool = false
  private var _isCollectionViewIndexPathChanged: Bool = false
  private var _draggingCollectionViewCellLocation: CGPoint = CGPointZero
  private var _currentIndexPath: NSIndexPath?
  private var _saveTapPoint: CGPoint = CGPointZero
  private var _ScrollToLeftDirection: Bool = false
  
  private var _itemWidth: CGFloat {
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      return 375 - 2 * (margin + lineSpacing)
    }
    return kScreenWidth - 2 * (margin + lineSpacing)
  }
  
  private var _pageWidth: CGFloat {
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      return 375 - 2 * margin - lineSpacing
    }
    return kScreenWidth - 2 * margin - lineSpacing
  }
  private var _navigationBarHight: CGFloat {
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      return 64
    }
    
    switch _screenDirection {
    case .vertical:
      return 64
    case .horizontal:
      return 32
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    for index in 0...7 {
      var numbers = 0
      
      if index == 0 {
        numbers = 6
      } else if index == 1 {
        numbers = 32
      } else if index == 2 || index == 6 {
        numbers = 8
      } else if index == 3 || index == 4 {
        numbers == 13
      } else {
        numbers = 5
      }
      var tasks: [Task] = []
      
      
      for number in 0...numbers {
        let task = Task(title: "\(number)", hidden: false)
        tasks.append(task)
      }
      
      //    taskLists.append()
      _taskLists.append(TaskList(name: "新建任务\(index)", hidden: false, tasks: tasks))
    }
    //
    //    taskLists = _taskLists
    
    //    _taskLists = [
    //      ["1", "2", "3", "4", "5", "6"],
    //      ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16"],
    //      ["1", "2", "3", "4", "5", "6", "7", "8"],
    //      ["1", "2", "3", "4", "5", "6", "7", "8", "4", "5", "6", "7", "8"],
    //      ["1", "2", "3", "4", "5", "6", "7"],
    //      ["1", "2", "3", "4", "5", "6", "7", "8", "4", "5", "6", "7", "8"],
    //      ["1", "2", "3", "4", "5", "6", "7", "8"]
    //    ]
    
    let horizontalInset = margin + lineSpacing
    
    _collectionViewFlowLayout = UICollectionViewFlowLayout()
    _collectionViewFlowLayout.itemSize = CGSize(width: _itemWidth, height: _itemHeight)
    _collectionViewFlowLayout.scrollDirection = .Horizontal
    _collectionViewFlowLayout.minimumLineSpacing = lineSpacing
    _collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: top, left: horizontalInset, bottom: bootom, right: horizontalInset)
    
    _collectionView = TaskBoardCollectionView(frame: view.bounds, collectionViewLayout: _collectionViewFlowLayout)
    _collectionView.dataSource = self
    _collectionView.delegate = self
    _collectionView.registerClass(TasksCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    _collectionView.backgroundColor = UIColor.whiteColor()
    automaticallyAdjustsScrollViewInsets = false
    
    view.addSubview(_collectionView)
    //        _collectionView.snp_makeConstraints { (make) in
    //          make.leading.equalTo(0)
    //          make.trailing.equalTo(0)
    //          make.top.equalTo(topLayoutGuide)
    //          make.bottom.equalTo(bottomLayoutGuide)
    //          make.centerX.equalTo(0)
    //          make.centerY.equalTo(0)
    //        }
    _collectionView.frame = view.bounds
    _collectionView.frame.size.height -= _navigationBarHight
    _collectionView.frame.origin.y += _navigationBarHight
    _collectionView.backgroundColor = UIColor.cyanColor()
    
    _screenDirection = kScreenWidth < kScreenHeight ? .vertical : .horizontal
    _collectionView.showsHorizontalScrollIndicator = _screenDirection == .horizontal
    
    _pageScrollView = UIScrollView(frame: CGRect(x: margin + lineSpacing, y: 0, width: _pageWidth, height: 0.1))
    _pageScrollView.contentSize = CGSize(width: CGFloat(_taskLists.count) * _pageWidth, height: 0.1)
    _pageScrollView.pagingEnabled = true
    _pageScrollView.delegate = self
    
    view.addSubview(_pageScrollView)
    _pageScrollView.backgroundColor = UIColor.orangeColor()
    
    _setPageable(true)
    
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(_collectionViewDidLongPressed(_:)))
    longPressGesture.minimumPressDuration = 0.25
    _collectionView.addGestureRecognizer(longPressGesture)
    
    let tapPressGesture = UITapGestureRecognizer(target: self, action: #selector(_collectionViewDidTap(_:)))
    tapPressGesture.numberOfTapsRequired = 2
    _collectionView.addGestureRecognizer(tapPressGesture)
    
    _keyboardMan = KeyboardMan()
    _keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
      guard let weakSelf = self else { return }
      
      var keyboardHeight = keyboardHeight - weakSelf.bootom
      if weakSelf._isZooming {
        keyboardHeight = keyboardHeight / weakSelf.kZoomScale
      }
      weakSelf._keyboardHeight = keyboardHeight
      NSNotificationCenter.defaultCenter().postNotificationName(kTaskListHeightDidChangedNotification, object: nil, userInfo: ["max_height": weakSelf._itemHeight - keyboardHeight, "super_view_height": weakSelf._itemHeight])
    }
    
    _keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
      guard let weakSelf = self else { return }
      
      weakSelf._keyboardHeight = 0
      NSNotificationCenter.defaultCenter().postNotificationName(kTaskListHeightDidChangedNotification, object: nil, userInfo: ["max_height": weakSelf._itemHeight, "super_view_height": weakSelf._itemHeight])
    }
  }
}

extension TaskBoardViewController {
  
  //MARK: - Override
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    _screenDirection = size.width < size.height ? .vertical : .horizontal
    
    if _screenDirection == .vertical {
      _scrollToPage(atPosition: _collectionView.contentOffset.x)
    }
    
    _setPageable(_screenDirection == .vertical && !_isZooming)
    
    UIView.animateWithDuration(coordinator.transitionDuration()) {
      
      let y: CGFloat = self._navigationBarHight
      let width: CGFloat
      let height: CGFloat
      switch self._screenDirection {
      case.vertical:
        width = self.kScreenWidth
        height = self.kScreenHeight - y
      case .horizontal:
        width = self.kScreenHeight
        height = self.kScreenWidth - y
      }
      self._collectionView.frame.origin.y = y
      self._collectionView.frame.size.width = width
      self._collectionView.frame.size.height = height
    }
    self._collectionViewFlowLayout.itemSize.height = self._itemHeight
    self._collectionView.collectionViewLayout.invalidateLayout()
    self._collectionView.reloadData()
  }
}

extension TaskBoardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  //MARK: - UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return _taskLists.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TasksCollectionViewCell
    cell.backgroundColor = UIColor.redColor()
    
    if cell.tasksViewController == nil {
      cell.tasksViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TasksViewController") as? TasksViewController
    }
    cell.tasksViewController?.setupData(_taskLists[indexPath.item].tasks, maxHeight: _itemHeight - _keyboardHeight, superViewHeight: _itemHeight)
    cell.tasksViewController?.listHeaderViewLongPressActionClosure = { [weak self](longPressGuesture: UILongPressGestureRecognizer) in
      guard let weakSelf = self  else { return }
      weakSelf._listHeadViewLongGuestureAction(longPressGuesture)
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
}

extension TaskBoardViewController {
  
  //MARK: - cell headerView UILongPressGestureRecognizer Event
  @objc
  private func _listHeadViewLongGuestureAction(longPressGuesture: UILongPressGestureRecognizer) {
    switch longPressGuesture.state {
    case .Began:
      guard let (listIndexPath, taskIndexPath) = _taskIndexPath(atPoint: longPressGuesture.locationInView(_collectionView)) else { return }
      if !_isZooming {
        _isListColelctionViewIsZooming = true
        var currentContentOffset = _collectionView.contentOffset
        if currentContentOffset.x > 0 && currentContentOffset.x < _collectionView.contentSize.width {
          currentContentOffset = CGPointMake(currentContentOffset.x - _itemWidth / 2 - (margin + lineSpacing), 0)
        }
        _zoomingCollectionView(currentContentOffset)
      }
      
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        guard let tasksCell = self._collectionView.cellForItemAtIndexPath(listIndexPath) as? TasksCollectionViewCell else { return }
        self._collectionView.scrollsToTop = false
        self._draggingListCell = tasksCell
        self._snapshotView = tasksCell.contentView.snapshotViewAfterScreenUpdates(false)
        self._snapshotView?.backgroundColor = UIColor.orangeColor()
        self.view.addSubview(self._snapshotView!)
        
        tasksCell.contentView.hidden = true
        let point = longPressGuesture.locationInView(self.view)
        let cellFrame = tasksCell.frame
        let cellFinalRect = self.view.convertRect(cellFrame, fromView: self._collectionView)
        
        self._snapshotView?.frame = CGRectMake(cellFinalRect.origin.x, cellFinalRect.origin.y, (tasksCell.frame.size.width ?? 0) * self.kZoomScale, (tasksCell.frame.size.height ?? 0) * self.kZoomScale)
        self._snapshotView?.transform = CGAffineTransformMakeRotation(0.1) //使用它时，不能改变frame, 只能通过center 来改变平移时的位置
        self._saveTapPoint = point
        self._draggingCollectionViewCellLocation = self._snapshotView!.center
        self._lastDragging = (listIndexPath, taskIndexPath)
      }
    case .Changed:
      if _snapshotView == nil {
        return
      }
      _collectionView.touchRectDidChanged((_snapshotView?.frame)!)
      guard let (_, taskIndexPath) = _taskIndexPath(atPoint: longPressGuesture.locationInView(_collectionView)) else { return }
      let point = longPressGuesture.locationInView(view)
      
      let translationPoint = point.x - _saveTapPoint.x
      if translationPoint > 0 {
        _ScrollToLeftDirection = false
      } else {
        _ScrollToLeftDirection = true
      }
      _snapshotView?.center.x = translationPoint + _draggingCollectionViewCellLocation.x
      _snapshotView?.center.y = point.y - _saveTapPoint.y + _draggingCollectionViewCellLocation.y
      
      
      guard let oldListIndexPath = _lastDragging?.listIndexPath else { return }
      
      guard let collectionIndexPath = _collectionView.indexPathForItemAtPoint(longPressGuesture.locationInView(_collectionView)) else { return }
      _lastDragging = (collectionIndexPath, taskIndexPath)
      _isCollectionViewIndexPathChanged = true
      
      guard !oldListIndexPath.isEqual(collectionIndexPath) else { return }
      swap(&_taskLists[oldListIndexPath.item], &_taskLists[collectionIndexPath.item])
      _collectionView.moveItemAtIndexPath(collectionIndexPath, toIndexPath: oldListIndexPath)
    case .Failed, .Cancelled, .Ended:
      _draggingListCell?.contentView.hidden = false
      _draggingListCell = nil
      _collectionView.stopAutoScroll()
      
      if _snapshotView == nil {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
          if self._snapshotView != nil {
            self._headViewLongGuestureCancelled()
          }
        });
        return
      }
      _headViewLongGuestureCancelled()
    default:
      break
    }
  }
  
  private func _headViewLongGuestureCancelled() {
    _snapshotView?.transform = CGAffineTransformIdentity
    _snapshotView?.removeFromSuperview()
    _snapshotView = nil
    
    if _isListColelctionViewIsZooming {
      guard let indexpath = _lastDragging?.listIndexPath else {
        _isListColelctionViewIsZooming = false
        _isCollectionViewIndexPathChanged = false
        return
      }
      var rebackRow = 0
      if _isCollectionViewIndexPathChanged {
        if indexpath.row == (_collectionView.numberOfItemsInSection(0) - 1) || indexpath.row == 0 || _ScrollToLeftDirection {
          rebackRow = indexpath.row
        } else  {
          rebackRow = indexpath.row - 1
        }
      } else {
        rebackRow = indexpath.row
      }
      _currentIndexPath = NSIndexPath(forItem: rebackRow, inSection: 0)
      _zoomingCollectionView()
      _isListColelctionViewIsZooming = false
      _isCollectionViewIndexPathChanged = false
    }
  }
}

extension TaskBoardViewController: UIScrollViewDelegate {
  
  //MARK: - UIScrollViewDelegate
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView == _pageScrollView { //ignore collection view scrolling callbacks
      var contentOffset = scrollView.contentOffset
      contentOffset.x = contentOffset.x - _collectionView.contentInset.left
      _collectionView.contentOffset = contentOffset
    }
  }
}

extension TaskBoardViewController {
  
  //MARK: - Private
  
  private func _scrollToPage(atPosition targetOffsetX: CGFloat) {
    if _isZooming { return }
    
    let pageWidth: CGFloat = kScreenWidth - 2 * margin - lineSpacing
    let currentOffsetX = _collectionView.contentOffset.x
    var newTargetOffsetX: CGFloat = 0
    
    if targetOffsetX > currentOffsetX {
      newTargetOffsetX = CGFloat(ceilf(Float(currentOffsetX / pageWidth))) * pageWidth
    } else if targetOffsetX < currentOffsetX {
      newTargetOffsetX = CGFloat(floorf(Float(currentOffsetX / pageWidth))) * pageWidth
    } else { // targetOffsetX == currentOffsetX
      if currentOffsetX % pageWidth > pageWidth * 0.5 {
        newTargetOffsetX = CGFloat(ceilf(Float(currentOffsetX / pageWidth))) * pageWidth
      } else {
        newTargetOffsetX = CGFloat(floorf(Float(currentOffsetX / pageWidth))) * pageWidth
      }
      return
    }
    
    if newTargetOffsetX < 0 {
      newTargetOffsetX = 0
    } else if newTargetOffsetX > _collectionView.contentSize.width {
      newTargetOffsetX = _collectionView.contentSize.width
    }
    
    _collectionView.setContentOffset(CGPoint(x: newTargetOffsetX, y: 0), animated: true)
    
    lastProposedContentOffsetX = newTargetOffsetX
  }
  
  @objc
  private func _collectionViewDidLongPressed(gestureRecognizer: UILongPressGestureRecognizer) {
    switch gestureRecognizer.state {
    case .Began:
      
      guard let (listIndexPath, taskIndexPath) = _taskIndexPath(atPoint: gestureRecognizer.locationInView(_collectionView)) else { return }
      
      debugPrint("======  listIndexPath: \(listIndexPath.item)")
      
      guard let tasksCell = _collectionView.cellForItemAtIndexPath(listIndexPath) as? TasksCollectionViewCell else { return }
      guard let tasksTableView = tasksCell.tasksViewController?.tasksTableView else { return }
      guard let taskCell = tasksTableView.cellForRowAtIndexPath(taskIndexPath) as? TaskTableViewCell else { return }
      
      taskCell.contentView.hidden = true
      _draggingTaskCell = taskCell
      _snapshotView = taskCell.contentView.snapshotViewAfterScreenUpdates(false)
      _snapshotView?.backgroundColor = UIColor.orangeColor()
      view.addSubview(_snapshotView!)
      if _isZooming {
        _snapshotView?.transform = CGAffineTransformMakeScale(kZoomScale, kZoomScale)
      }
      _snapshotView?.center = gestureRecognizer.locationInView(view)
      _lastDragging = (listIndexPath, taskIndexPath)
      
      debugPrint("BEGAN....")
    case .Changed:
      debugPrint("CHANGE....")
      
      if _snapshotView == nil {
        return
      }
      
      _collectionView.touchRectDidChanged((_snapshotView?.frame)!)
      
      guard let (listIndexPath, taskIndexPath) = _taskIndexPath(atPoint: gestureRecognizer.locationInView(_collectionView)) else { return }
      _snapshotView?.center = gestureRecognizer.locationInView(view)
      
      guard let tasksCell = _collectionView.cellForItemAtIndexPath(listIndexPath) as? TasksCollectionViewCell else { return }
      guard let tasksViewController = tasksCell.tasksViewController else { return }
      guard var tasksTableView = tasksViewController.tasksTableView else { return }
      
      let covertFrame = view.convertRect(_snapshotView!.frame, toView: tasksViewController.view)
      tasksTableView.touchRectDidChanged(covertFrame)
      
      if _lastDragging?.listIndexPath == listIndexPath && _lastDragging?.taskIndexPath == taskIndexPath {
        return
      }
      
      guard let _ = tasksTableView.cellForRowAtIndexPath(taskIndexPath) else { return }
      
      guard let oldListIndexPath = _lastDragging?.listIndexPath else { return }
      guard let oldTaskIndexPath = _lastDragging?.taskIndexPath else { return }
      
      if _lastDragging?.listIndexPath == listIndexPath { // 同一列表
        swap(&_taskLists[oldListIndexPath.item].tasks[oldTaskIndexPath.row], &_taskLists[listIndexPath.item].tasks[taskIndexPath.row])
        tasksViewController.moveTask(atIndexPath: taskIndexPath, toIndexPath: oldTaskIndexPath)
        
        debugPrint("moving....................")
      } else { // 跨列表
        
        guard let oldTasksCell = _collectionView.cellForItemAtIndexPath(oldListIndexPath) as? TasksCollectionViewCell else { return }
        guard let oldTasksVirewController = oldTasksCell.tasksViewController else { return }
        
        var draggingData = _taskLists[oldListIndexPath.item].tasks[oldTaskIndexPath.row]
        draggingData.hidden = true
        
        _taskLists[oldListIndexPath.item].tasks.removeAtIndex(oldTaskIndexPath.row)
        oldTasksVirewController.removeTask(atIndexPath: oldTaskIndexPath)
        oldTasksVirewController.updateTableViewHeight(true, additionHeight: -(_draggingTaskCell?.bounds.height ?? 0), maxHeight: _itemHeight, superViewHeight: _itemHeight)
        
        let tempTasksList: [Task] = _taskLists[listIndexPath.item].tasks
        if tempTasksList.count == 0 || (taskIndexPath.row >= tempTasksList.count) {
          _taskLists[listIndexPath.item].tasks.append(draggingData)
        } else {
          _taskLists[listIndexPath.item].tasks.insert(draggingData, atIndex: taskIndexPath.row)
        }
        
        tasksViewController.insertTask(draggingData, atIndexPath: taskIndexPath)
        tasksViewController.updateTableViewHeight(true, additionHeight: _draggingTaskCell?.bounds.height ?? 0, maxHeight: _itemHeight, superViewHeight: _itemHeight)
      }
      _lastDragging = (listIndexPath, taskIndexPath)
    case .Failed, .Cancelled, .Ended:
      debugPrint("END....")
      NSNotificationCenter.defaultCenter().postNotificationName("tableviewStopAutoScroll", object: self, userInfo: nil)
      _collectionView.stopAutoScroll()
      if _snapshotView == nil {
        return
      }
      
      _snapshotView?.removeFromSuperview()
      _snapshotView = nil
      
      _draggingTaskCell?.contentView.hidden = false
      _draggingTaskCell = nil
      
      guard let oldTasksCell = _collectionView.cellForItemAtIndexPath(_lastDragging!.listIndexPath) as? TasksCollectionViewCell else { return }
      guard let oldTasksVirewController = oldTasksCell.tasksViewController else { return }
      guard let reloadListIndexPath = _lastDragging?.listIndexPath else { return }
      guard let reloadTaskIndexPath = _lastDragging?.taskIndexPath else { return }
      _taskLists[reloadListIndexPath.item].tasks[reloadTaskIndexPath.row].hidden = false
      oldTasksVirewController.reloadTask(_taskLists[reloadListIndexPath.item].tasks[reloadTaskIndexPath.row], atIndexPath: reloadTaskIndexPath)
      
    case .Possible:
      debugPrint("POSSIBLE....")
    }
  }
  
  /**
   CollectionView tapGesture event
   
   - parameter gestureRecognizer:
   */
  @objc
  private func _collectionViewDidTap(gestureRecognizer: UITapGestureRecognizer) {
    var currentContentOffset = _collectionView.contentOffset
    let point = gestureRecognizer.locationInView(_collectionView)
    if _isZooming {
      let tapPoint = CGPointMake(point.x + (margin + lineSpacing) / 2, point.y)
      _currentIndexPath = self._collectionView.indexPathForItemAtPoint(tapPoint)
      if _currentIndexPath == nil {
        let lastPoint = CGPointMake(tapPoint.x - (self.margin + self.lineSpacing) / 2, tapPoint.y)
        _currentIndexPath = self._collectionView.indexPathForItemAtPoint(lastPoint)
      }
      if _currentIndexPath == nil {
        return
      }
      _zoomingCollectionView()
      
    } else {
      if currentContentOffset.x > 0 && currentContentOffset.x < _collectionView.contentSize.width {
        currentContentOffset = CGPointMake(currentContentOffset.x - _itemWidth / 2 - (margin + lineSpacing), 0)
      }
      _zoomingCollectionView(currentContentOffset)
    }
  }
  
  /**
   CollectionView Zooming event
   
   */
  
  private func _zoomingCollectionView(currentPoint: CGPoint = CGPointZero) {
    if _isZooming {
      self._isZooming = false
      UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
        
        self._collectionView.frame.origin.x += self._collectionView.frame.width * self.kZoomScale * self.kZoomScale
        self._collectionView.frame.origin.y += self._collectionView.frame.height * self.kZoomScale * self.kZoomScale
        
        self._collectionView.frame.size.width *= self.kZoomScale
        self._collectionView.frame.size.height *= self.kZoomScale
        
        self._collectionViewFlowLayout.itemSize.height = self._itemHeight
        self._collectionView.collectionViewLayout.invalidateLayout()
        self._collectionView.reloadData()
        
        self._collectionView.transform = CGAffineTransformIdentity
        
      }) { (finished:Bool) in
        self._setPageable(true)
        guard let indexpath = self._currentIndexPath else { return }
        let offsetPoint = CGPointMake(CGFloat(indexpath.row) * (self.lineSpacing + self._itemWidth), 0)
        self._collectionView.setContentOffset(offsetPoint, animated: false)
      }
    } else {
      self._isZooming = true
      UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
        
        self._collectionView.frame.origin.x -= self._collectionView.frame.width * self.kZoomScale
        self._collectionView.frame.origin.y -= self._collectionView.frame.height * self.kZoomScale
        
        self._collectionView.frame.size.width /= self.kZoomScale
        self._collectionView.frame.size.height /= self.kZoomScale
        
        self._collectionViewFlowLayout.itemSize.height = self._itemHeight
        self._collectionView.reloadData()
        
        self._collectionView.transform = CGAffineTransformMakeScale(self.kZoomScale, self.kZoomScale)
        self._collectionView.setContentOffset(currentPoint, animated: false)
      }) { (finished:Bool) in
        self._setPageable(false)
      }
    }
  }
  
  /**
   List indexPath and task indexPath for touch point
   
   - parameter point: touch point
   
   - returns: (list indexPath on collecitonView, task indexPath on tableView)
   */
  private func _taskIndexPath(atPoint point: CGPoint) -> (listIndexPath: NSIndexPath, taskIndexPath: NSIndexPath)? {
    guard let listIndexPath = _collectionView.indexPathForItemAtPoint(point) else { return nil }
    guard let tasksCell = _collectionView.cellForItemAtIndexPath(listIndexPath) as? TasksCollectionViewCell else { return nil }
    
    guard let tasksViewController = tasksCell.tasksViewController else { return nil }
    guard let tasksTableView = tasksCell.tasksViewController?.tasksTableView else { return nil }
    guard let listHeaderView = tasksCell.tasksViewController?._listHeaderView else { return nil}
    guard let listFooterView = tasksCell.tasksViewController?._listFooterView else { return nil}
    
    let tableViewPoint = _collectionView.convertPoint(point, toView: tasksTableView)
    let taskViewControllerPoint = _collectionView.convertPoint(point, toView: tasksViewController.view)
    
    if (CGRectContainsPoint(listHeaderView.frame, taskViewControllerPoint)) {
      return (listIndexPath, NSIndexPath(forRow: -1, inSection: 0))
    } else if (CGRectContainsPoint(listFooterView.frame, taskViewControllerPoint)) {
      let rows = tasksTableView.numberOfRowsInSection(0)
      return (listIndexPath, NSIndexPath(forRow: rows, inSection: 0))
    } else {
      guard let taskIndexPath = tasksTableView.indexPathForRowAtPoint(tableViewPoint) else {
        return (listIndexPath, NSIndexPath(forRow: -1, inSection: 0))
      }
      return (listIndexPath, taskIndexPath)
    }
  }
  
  private func _setPageable(pageable: Bool) {
    var pageable = pageable
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      pageable = false
    }
    
    if pageable {
      _collectionView.addGestureRecognizer(self._pageScrollView.panGestureRecognizer)
    } else {
      _collectionView.removeGestureRecognizer(self._pageScrollView.panGestureRecognizer)
    }
    _collectionView.panGestureRecognizer.enabled = !pageable
    
    _collectionView.showsHorizontalScrollIndicator = !pageable
  }
}