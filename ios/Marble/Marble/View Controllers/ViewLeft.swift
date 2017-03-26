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
        
        refresh(refreshGroups: true)
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaPosted(notification:)), name: Constants.Notifications.StoryPosted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaUploadFinished(notificaion:)), name: Constants.Notifications.StoryUploadFinished, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pullDownRefresh() {
        refresh(refreshGroups: true)
    }
    
    func refresh(refreshGroups: Bool = false) {
        if refreshGroups {
            State.shared.refreshUserGroups(completionHandler: {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.refreshStories()
            })
        } else {
            self.tableView.reloadData()
            refreshStories()
        }
    }
    
    private func refreshStories() {
        State.shared.getMyStories(completionHandler: {
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
                for story in stories {
                    story.loadMedia(completionHandler: { story in
                        groupCell?.storyLoadCount! -= 1
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
        let count = State.shared.userGroups.count
        if count == 0 {
            let noGroupsView = UINib(nibName: "NoGroupsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
            tableView.backgroundView = noGroupsView
        } else {
            tableView.backgroundView = nil
            State.shared.sortGroupsRecent()
        }
        return count
    }
    
    let imageViewNib = UINib(nibName: "StoryImage", bundle: nil)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! MainGroupTVCell
        
        if !State.shared.checkGroupStoriesReady(groupId: (cell.group?.groupId)!) {
            return
        }

        let group = State.shared.findGroupBy(id: (cell.group?.groupId)!)

        let imageViewer = imageViewNib.instantiate(withOwner: nil, options: nil)[0] as! StoryImageView
        
        imageViewer.group = group
        imageViewer.cell = cell
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageViewer.isUserInteractionEnabled = true
        imageViewer.addGestureRecognizer(tapGest)
        
        UIApplication.shared.keyWindow?.addSubview(imageViewer)
        imageViewer.mediaStart()
        Networker.shared.storySeen(groupId: (group?.groupId)! ,completionHandler: { _ in })  // empty completion handler
        group?.lastSeen = Int64(Date().timeIntervalSince1970 * 1000)
        cell.refreshSeen()
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedIV = tapGestureRecognizer.view as! StoryImageView
        tappedIV.mediaNext()
    }

    
    @IBAction func cancelToViewLeft(_ segue:UIStoryboardSegue) {
    }
    
    @IBAction func createGroupSegue(_ segue: UIStoryboardSegue) {
        refresh(refreshGroups: true)
    }
    
    @IBAction func joinGroupToMainSegue(_ segue: UIStoryboardSegue) {
        refresh(refreshGroups: false)
    }
    
    func mediaPosted(notification: Notification) {
        let userInfo = notification.userInfo as! [String:AnyObject]
        let groups = userInfo["group_ids"] as! [Int]
        for cell in self.tableView.visibleCells {
            let groupCell = (cell as? MainGroupTVCell)
            if groups.contains((groupCell?.group?.groupId)!) {
                groupCell?.startLoading()
            }
        }
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
}
