//
//  ViewLeft.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit

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
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func pullDownRefresh() {
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
                    groupCell?.startLoading()
                    groupCell?.storyLoadCount = stories.count
                    if stories.count == 0 {
                        groupCell?.stopLoading()
                    } else {
                        func lock(obj: AnyObject, blk:() -> ()) {
                            objc_sync_enter(obj)
                            blk()
                            objc_sync_exit(obj)
                        }
                        
                        for story in stories {
                            story.loadMedia(completionHandler: { story in
                                lock(obj: groupCell?.storyLoadCount! as AnyObject, blk: {
                                    groupCell?.storyLoadCount! -= 1
                                })
                                print("story load count: " + String(describing: groupCell?.storyLoadCount))
                                if groupCell?.storyLoadCount ?? 0 <= 0 {
                                    groupCell?.stopLoading()
                                    var storyIdx = State.shared.findGroupBy(id: (groupCell?.group?.groupId)!)?.storyViewIdx
                                    if storyIdx! >= stories.count {
                                        storyIdx = 0
                                    }
                                    groupCell?.refreshPreview()
                                    groupCell?.refreshSeen()
                                }
                            })
                        }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! MainGroupTVCell
        
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
        
        UIApplication.topViewController()?.view.addSubview(imageViewer)
        
        imageViewer.mediaStart()
        
        Networker.shared.storySeen(groupId: (group?.groupId)! ,completionHandler: { _ in })  // empty completion handler
        group?.lastSeen = Int64(Date().timeIntervalSince1970 * 1000)
        cell.refreshSeen()
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
    
    func mediaPosted(notification: Notification) {
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
    
    func mediaUploadFinished(notificaion: Notification) {
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
    
    func longPress(_ gest: UILongPressGestureRecognizer) {
        if gest.state == .began {
            let touchPoint = gest.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath) as? MainGroupTVCell
                if cell == nil {
                    return
                }
                let group = cell?.group
                let appearance = SCLAlertView.SCLAppearance(
                    hideWhenBackgroundViewIsTapped: true
                )
                let alert = SCLAlertView(appearance: appearance)
                let subTitle = String(format: "Code: %05d", (group?.groupId)!)
                alert.showInfo((group?.name)!, subTitle: subTitle)
            }
        }
    }
    
}
