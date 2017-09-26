//
//  ViewLeft.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import UserNotifications

class ViewLeft: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: UIControlEvents.valueChanged)
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaPosted(notification:)), name: Constants.Notifications.StoryPosted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaUploadFinished(notificaion:)), name: Constants.Notifications.StoryUploadFinished, object: nil)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            
            guard error == nil else {
                print("error")
                return
            }
            
            if granted {
                //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                print("user granted notifications")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else {
                print("User denied notifications")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        pullDownRefresh()
        
        becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alertController = UIAlertController(title: nil, message: "Shake Actions", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            })
            alertController.addAction(cancelAction)
            
            let logoutAction = UIAlertAction(title: "Logout", style: .destructive, handler: { action in
                if KeychainWrapper.clearAuthToken() && KeychainWrapper.clearUserID() {
                    OperationQueue.main.addOperation {
                        UIApplication.topViewController()?.present(UIStoryboard(name:"Auth", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
                    }
                }
            })
            alertController.addAction(logoutAction)
            
            let clearCacheAction = UIAlertAction(title: "Clear Cache", style: .destructive, handler: { action in
                do {
                    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let paths = try FileManager.default.contentsOfDirectory(atPath: docDir.path)
                    for file in paths {
                        print("removing: " + file)
                        try FileManager.default.removeItem(atPath: docDir.path + "/" + file)
                    }
                    self.pullDownRefresh()
                } catch let error {
                    print("error clearing cache: \(error.localizedDescription)")
                }
            })
            alertController.addAction(clearCacheAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func pullDownRefresh() {
        refresh()
    }
    
    func refresh() {
        State.shared.refreshUserGroups(completionHandler: {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.refreshStories()
        })
    }
    
    let noGroupsView = UINib(nibName: "NoGroupsView", bundle: nil)
    
    private func refreshStories() {
        State.shared.getMyStories(completionHandler: {
            if State.shared.userGroups.count > 0 {
                State.shared.sortGroupsRecent()
                self.tableView.reloadData()
                self.tableView.backgroundView = nil
                for (groupId, stories) in State.shared.groupStories {
                    var groupCell: MainGroupTVCell?
                    for cell in self.tableView.visibleCells {
                        if (cell as! MainGroupTVCell).group?.groupId == groupId {
                            groupCell = cell as? MainGroupTVCell
                        }
                    }
                    if groupCell == nil {
                        continue
                    }
                    groupCell?.storyLoadCount = stories.count
                    if stories.count > 0 {
                        func lock(obj: AnyObject, blk:() -> ()) {
                            objc_sync_enter(obj)
                            blk()
                            objc_sync_exit(obj)
                        }
                        if !State.shared.checkGroupStoriesReady(groupId: groupId) {
                            groupCell?.startLoading()
                        }
                        for story in stories {
                            story.loadMedia(completionHandler: { story in
                                lock(obj: groupCell?.storyLoadCount! as AnyObject, blk: {
                                    groupCell?.storyLoadCount! -= 1
                                })
                                if groupCell?.storyLoadCount ?? 0 <= 0 {
                                    groupCell?.stopLoading()
                                    var storyIdx = State.shared.findGroupBy(id: (groupCell?.group?.groupId)!)?.storyViewIdx
                                    if storyIdx! >= stories.count {
                                        storyIdx = 0
                                    }
                                    groupCell?.refreshPreview()
                                }
                            })
                        }
                    } else {
                        groupCell?.refreshPreview()
                    }
                }
            } else {
                let noGroupsView = self.noGroupsView.instantiate(withOwner: nil, options: nil)[0] as? UIView
                noGroupsView?.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.tableView.backgroundView = noGroupsView
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainGroupCell", for: indexPath) as! MainGroupTVCell
        let group = State.shared.userGroups[indexPath.row]
        cell.title.text = group.name
        cell.group = group
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        State.shared.sortGroupsRecent()
        return State.shared.userGroups.count
    }
    
    let storyViewNib = UINib(nibName: "StoryView", bundle: nil)
    var lastClick: TimeInterval = 0.0
    var lastIndexPath: IndexPath?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let now: TimeInterval = Date().timeIntervalSince1970
        if (now - lastClick < (Double(Constants.DoubleTapDelay)/1000.0)) && (lastIndexPath?.row == indexPath.row ) {
            self.tableView.deselectRow(at: indexPath, animated: true)
            postToGroup(group: (self.tableView.cellForRow(at: indexPath) as! MainGroupTVCell).group!)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(Constants.DoubleTapDelay)), execute: {
                let now: TimeInterval = Date().timeIntervalSince1970
                if (now - self.lastClick >= (Double(Constants.DoubleTapDelay)/1000.0)) && (self.lastIndexPath?.row == indexPath.row) {
                    self.cellSingleTap(cell: self.tableView.cellForRow(at: indexPath) as! MainGroupTVCell)
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
        }
        lastClick = now
        lastIndexPath = indexPath
    }
    
    private func cellSingleTap(cell: MainGroupTVCell) {
        if !State.shared.checkGroupStoriesReady(groupId: (cell.group?.groupId)!) {
            print("stories not ready")
            return
        }
        
        let group = State.shared.findGroupBy(id: (cell.group?.groupId)!)
        
        let imageViewer = storyViewNib.instantiate(withOwner: nil, options: nil)[0] as! StoryView
        imageViewer.isHidden = true
        
        imageViewer.group = group
        imageViewer.cell = cell
        
        imageViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        imageViewer.parentVC = self
        imageViewer.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.addSubview(imageViewer)
        
        imageViewer.mediaStart()
        
        if State.shared.groupStories[(group?.groupId)!]?.count == 0 {
            let alert = UIAlertController(title: "Doesn't seem to be anything there..", message: "Swipe left to add something", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancel)
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            return
        }
        
        if (group?.lastSeen ?? 1) < (State.shared.groupStories[(group?.groupId)!]?.last?.timestamp ??  0) {
            //UIApplication.shared.applicationIconBadgeNumber = max(0, UIApplication.shared.applicationIconBadgeNumber - 1)
        }
        
        Networker.shared.storySeen(groupId: (group?.groupId)! ,completionHandler: { _ in })  // empty completion handler
        group?.lastSeen = Int64(Date().timeIntervalSince1970 * 1000)
        cell.refreshPreview()
    }
    
    @IBAction func cancelToViewLeft(_ segue:UIStoryboardSegue) {
        self.becomeFirstResponder()
    }
    
    @IBAction func createGroupSegue(_ segue: UIStoryboardSegue) {
        self.becomeFirstResponder()
        refresh()
    }
    
    @IBAction func joinGroupToMainSegue(_ segue: UIStoryboardSegue) {
        self.becomeFirstResponder()
        refresh()
    }
    
    @objc func mediaPosted(notification: Notification) {
        self.becomeFirstResponder()
        let userInfo = notification.userInfo as! [String:AnyObject]
        let groups = userInfo["group_ids"] as! [Int]
        for cell in self.tableView.visibleCells {
            let groupCell = (cell as? MainGroupTVCell)
            if groups.contains((groupCell?.group?.groupId)!) {
                groupCell?.group?.lastSeen = Int64(Date().timeIntervalSince1970 * 1000) + 100
                groupCell?.startLoading()
                let indexPath = tableView.indexPath(for: groupCell!)
                tableView.moveRow(at: indexPath!, to: IndexPath.init(row: 0, section: 0))
            }
        }
        State.shared.sortGroupsRecent()
    }
    
    @objc func mediaUploadFinished(notificaion: Notification) {
        refresh()
    }
    
    @IBAction func AddMarbleBtnPress(_ sender: UIBarButtonItem) {
        OperationQueue.main.addOperation {
            UIApplication.topViewController()?.present(UIStoryboard(name:"AddMarble", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
        }
    }
    
    @IBAction func goToCameraBtnPress(_ sender: Any) {
        let parentVC = UIApplication.topViewController() as? ViewController
        let screenWidth = UIScreen.main.bounds.size.width
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: screenWidth, y: 0.0), animated: true)
    }
    
    @objc func longPress(_ gest: UILongPressGestureRecognizer) {
        if gest.state == .began {
            let touchPoint = gest.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath) as? MainGroupTVCell
                if cell == nil {
                    return
                }
                cell?.showMarbleInfo()
            }
        }
    }

    func postToGroup(group: Group) {
        let parentVC = UIApplication.topViewController() as? ViewController
        parentVC?.vRight.postToGroup(group: group)
        let screenWidth = UIScreen.main.bounds.size.width
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: screenWidth, y: 0.0), animated: true)
    }
    
    // code for overlaying icon on QR code. not in use.
    func overlayIcon(image: UIImage) -> UIImage {
        let logo = UIImage.init(named: "marble-logo-full")
        let size = image.size
        let logoSideLen = CGFloat(28)
        let padding = CGFloat(3)
        
        UIGraphicsBeginImageContext(CGSize(width: logoSideLen, height: logoSideLen))
        var whiteImg: UIImage?
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            let rect = CGRect(origin: CGPoint.zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: 3).addClip()
            context.addRect(rect)
            context.drawPath(using: .fill)
            whiteImg = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: size))
        whiteImg?.draw(in: CGRect(x: (size.width/2) - (logoSideLen/2), y: (size.height/2) - (logoSideLen/2), width: logoSideLen, height: logoSideLen))
        logo?.draw(in: CGRect(x: (size.width/2) - (logoSideLen/2), y: (size.height/2) - (logoSideLen/2), width: logoSideLen, height: logoSideLen))
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
}
