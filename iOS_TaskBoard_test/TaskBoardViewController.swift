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
  private var _lastDragging: (listIndexPath: NSIndexPath, taskIndexPath: NSIndexPath)?
  
  private var _taskLists:[[String]] = []
  
  private var _keyboardMan: KeyboardMan!
  private var _isZooming: Bool = false
  
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
    _taskLists = [
      ["1", "2", "3", "4", "5", "6"],
      ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16", "13", "14", "15", "16"],
      ["1", "2", "3", "4", "5", "6", "7", "8"],
      ["1", "2", "3", "4", "5", "6", "7", "8", "4", "5", "6", "7", "8"],
      ["1", "2", "3", "4", "5", "6", "7"],
      ["1", "2", "3", "4", "5", "6", "7", "8", "4", "5", "6", "7", "8"],
      ["1", "2", "3", "4", "5", "6", "7", "8"]
    ]

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
    
    cell.tasksViewController?.setupData(_taskLists[indexPath.item], maxHeight: _itemHeight - _keyboardHeight, superViewHeight: _itemHeight)
    
    return cell
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
      _snapshotView?.center = gestureRecognizer.locationInView(view)

      _collectionView.touchRectDidChanged((_snapshotView?.frame)!)
      
      guard let (listIndexPath, taskIndexPath) = _taskIndexPath(atPoint: gestureRecognizer.locationInView(_collectionView)) else { return }
      
      if _lastDragging?.listIndexPath == listIndexPath && _lastDragging?.taskIndexPath == taskIndexPath {
        return
      }
      
      guard let tasksCell = _collectionView.cellForItemAtIndexPath(listIndexPath) as? TasksCollectionViewCell else { return }
      guard let tasksViewController = tasksCell.tasksViewController else { return }
      
      guard let oldListIndexPath = _lastDragging?.listIndexPath else { return }
      guard let oldTaskIndexPath = _lastDragging?.taskIndexPath else { return }
      
      
      if _lastDragging?.listIndexPath == listIndexPath { // 同一列表
        
        swap(&_taskLists[oldListIndexPath.item][oldTaskIndexPath.row], &_taskLists[listIndexPath.item][taskIndexPath.row])
        tasksViewController.moveTask(atIndexPath: taskIndexPath, toIndexPath: oldTaskIndexPath)
        
        debugPrint("moving....................")
      } else { // 跨列表
        
        guard let oldTasksCell = _collectionView.cellForItemAtIndexPath(oldListIndexPath) as? TasksCollectionViewCell else { return }
        guard let oldTasksVirewController = oldTasksCell.tasksViewController else { return }
        
        let draggingData = _taskLists[oldListIndexPath.item][oldTaskIndexPath.row]
        
        _taskLists[oldListIndexPath.item].removeAtIndex(oldTaskIndexPath.row)
        oldTasksVirewController.removeTask(atIndexPath: oldTaskIndexPath)
        oldTasksVirewController.updateTableViewHeight(true, additionHeight: -(_draggingTaskCell?.bounds.height ?? 0), maxHeight: _itemHeight, superViewHeight: _itemHeight)
        
        _taskLists[listIndexPath.item].insert(draggingData, atIndex: taskIndexPath.row)
        tasksViewController.insertTask(draggingData, atIndexPath: taskIndexPath)
        tasksViewController.updateTableViewHeight(true, additionHeight: _draggingTaskCell?.bounds.height ?? 0, maxHeight: _itemHeight, superViewHeight: _itemHeight)
      }
      
      _lastDragging = (listIndexPath, taskIndexPath)
    case .Failed, .Cancelled, .Ended:
      debugPrint("END....")
      _snapshotView?.removeFromSuperview()
      _snapshotView = nil
      
      _draggingTaskCell?.contentView.hidden = false
      _draggingTaskCell = nil
      
      _collectionView.stopAutoScroll()
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
    if _isZooming {
      self._isZooming = false
      UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
        
        self._collectionView.frame.origin.x += self._collectionView.frame.width * self.kZoomScale * self.kZoomScale
        self._collectionView.frame.origin.y += self._collectionView.frame.height * self.kZoomScale * self.kZoomScale
        
        self._collectionView.frame.size.width *= self.kZoomScale
        self._collectionView.frame.size.height *= self.kZoomScale
        
        self._collectionViewFlowLayout.itemSize.height = self._itemHeight
        self._collectionView.reloadData()
        
        self._collectionView.transform = CGAffineTransformIdentity

      }) { (finished:Bool) in
        self._setPageable(true)
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
    guard let tasksTableView = tasksCell.tasksViewController?.tasksTableView else { return nil }
    
    let point = _collectionView.convertPoint(point, toView: tasksTableView)
    guard let taskIndexPath = tasksTableView.indexPathForRowAtPoint(point) else {
      return (listIndexPath, NSIndexPath(forRow: 0, inSection: 0))
    }
    
    return (listIndexPath, taskIndexPath)
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