//
//  ViewLeft.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import UserNotifications

class ViewLeft: UICollectionViewController {
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 14.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    var refreshControl: UIRefreshControl?
    
    static var shared: ViewLeft?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewLeft.shared = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl!)
        collectionView?.alwaysBounceVertical = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaPosted(notification:)), name: Constants.Notifications.ClipPosted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaUploadFinished(notificaion:)), name: Constants.Notifications.ClipUploadFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pullDownRefresh), name: Constants.Notifications.RefreshMainGroupState, object: nil)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            
            guard error == nil else {
                print("error")
                return
            }
            
            if granted {
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
        
        collectionView?.register(UINib(nibName: "GroupCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GroupCollectionCell")
        
        collectionView?.reloadData()
        
        pullDownRefresh()
        
        State.shared.refreshTrendingGroups()
        
        becomeFirstResponder()
        
        ViewLeft.startRefreshTimer()
    }
    
    static var refreshTimer: Timer?
    
    static func startRefreshTimer() {
        if let target = self.shared {
            ViewLeft.refreshTimer = Timer.scheduledTimer(timeInterval: 20, target: target, selector: #selector(pullDownRefresh), userInfo: nil, repeats: true)
        }
    }
    
    static func killRefreshTimer() {
        ViewLeft.refreshTimer?.invalidate()
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
        if self.view.window?.windowLevel != UIWindowLevelStatusBar {
            refresh()
        }
    }
    
    func refresh() {
        State.shared.refreshUserGroups(completionHandler: {
            self.refreshControl?.endRefreshing()
            self.refreshClips()
            UIApplication.shared.applicationIconBadgeNumber = State.shared.getUnseenMarblesCount()
            State.shared.getMyMemories()
        })
    }
    
    let noGroupsView = UINib(nibName: "NoGroupsView", bundle: nil)
    
    private func refreshClips() {
        State.shared.getMyClips(completionHandler: {
            if State.shared.userGroups.count > 0 {
                State.shared.sortGroupsRecent()
                self.collectionView?.reloadData()
                self.collectionView?.backgroundView = nil
                self.collectionView?.layoutIfNeeded()
                for (groupId, stories) in State.shared.groupClips {
                    var groupCell: GroupCollectionCell?
                    for cell in (self.collectionView?.visibleCells)! {
                        if (cell as! GroupCollectionCell).group?.groupId == groupId {
                            groupCell = cell as? GroupCollectionCell
                        }
                    }
                    if groupCell == nil {
                        continue
                    }
//                    groupCell?.clipLoadCount = stories.count
//                    if stories.count > 0 {
//                        func lock(obj: AnyObject, blk:() -> ()) {
//                            objc_sync_enter(obj)
//                            blk()
//                            objc_sync_exit(obj)
//                        }
//                        if !State.shared.checkGroupClipsReady(groupId: groupId) {
//                            groupCell?.startLoading()
//                        }
//                        for clip in stories {
//                            clip.loadMedia(completionHandler: { clip in
//                                lock(obj: groupCell?.clipLoadCount! as AnyObject, blk: {
//                                    groupCell?.clipLoadCount! -= 1
//                                })
//                                if groupCell?.clipLoadCount ?? 0 <= 0 {
//                                    groupCell?.stopLoading()
//                                    groupCell?.refreshPreview()
//                                }
//                            })
//                        }
//                    } else {
//                        groupCell?.refreshPreview()
//                    }
                }
            } else {
                let noGroupsView = self.noGroupsView.instantiate(withOwner: nil, options: nil)[0] as? UIView
                noGroupsView?.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.collectionView?.backgroundView = noGroupsView
            }
        })
    }
    
    let clipViewNib = UINib(nibName: "ClipView", bundle: nil)
    var lastClick: TimeInterval = 0.0
    var lastIndexPath: IndexPath?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let now: TimeInterval = Date().timeIntervalSince1970
        if (now - lastClick < (Double(Constants.DoubleTapDelay)/1000.0)) && (lastIndexPath?.row == indexPath.row ) {
            postToGroup(group: (collectionView.cellForItem(at: indexPath) as! GroupCollectionCell).group!)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(Constants.DoubleTapDelay)), execute: {
                let now: TimeInterval = Date().timeIntervalSince1970
                if (now - self.lastClick >= (Double(Constants.DoubleTapDelay)/1000.0)) && (self.lastIndexPath?.row == indexPath.row) {
                    self.cellSingleTap(cell: collectionView.cellForItem(at: indexPath) as! GroupCollectionCell)
                }
            })
        }
        lastClick = now
        lastIndexPath = indexPath
    }
    
    private func cellSingleTap(cell: GroupCollectionCell) {
        if !State.shared.checkGroupClipsReady(groupId: (cell.group?.groupId)!) {
            print("stories not ready")
            return
        }
        
        let group = State.shared.findGroupBy(id: (cell.group?.groupId)!)
        
        if State.shared.groupClips[(group?.groupId)!]?.count == 0 {
            let alert = UIAlertController(title: "There aren't any posts here...", message: "Swipe left to add something", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancel)
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            return
        }
        
        let imageViewer = clipViewNib.instantiate(withOwner: nil, options: nil)[0] as! ClipView
        imageViewer.isHidden = true
        
        imageViewer.group = group
        imageViewer.cell = cell
        
        imageViewer.delegate = self
        
        imageViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        imageViewer.parentVC = self
        
        imageViewer.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.addSubview(imageViewer)
        
        imageViewer.mediaStart()
        
        Networker.shared.clipSeen(groupId: (group?.groupId)! ,completionHandler: { _ in })  // empty completion handler
        group?.lastSeen = Int64(Date().timeIntervalSince1970 * 1000)
        cell.refreshPreview()
        UIApplication.shared.applicationIconBadgeNumber = State.shared.getUnseenMarblesCount()
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
        for cell in (self.collectionView?.visibleCells)! {
            let groupCell = (cell as? GroupCollectionCell)
            if groups.contains((groupCell?.group?.groupId)!) {
                groupCell?.group?.lastSeen = Int64(Date().timeIntervalSince1970 * 1000) + 100
                groupCell?.startLoading()
                let indexPath = collectionView?.indexPath(for: groupCell!)
                collectionView?.moveItem(at: indexPath!, to: IndexPath(item: 0, section: 0))
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
            if let indexPath = collectionView?.indexPathForItem(at: touchPoint) {
                if let cell = collectionView?.cellForItem(at: indexPath) as? GroupCollectionCell {
                    cell.showMarbleInfo()
                }
            }
        }
    }

    func postToGroup(group: Group) {
        let parentVC = UIApplication.topViewController() as? ViewController
        parentVC?.vRight.postToGroup(group: group)
        let screenWidth = UIScreen.main.bounds.size.width
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: screenWidth, y: 0.0), animated: true)
    }
    
}


// MARK: - UICollectionViewDataSource
extension ViewLeft {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        State.shared.sortGroupsRecent()
        return State.shared.userGroups.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCollectionCell", for: indexPath) as! GroupCollectionCell
        let group = State.shared.userGroups[indexPath.row]
        cell.group = group

        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}

extension ViewLeft : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = (sectionInsets.left) * (itemsPerRow + 1)
        let availableWidth = UIScreen.main.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem * 1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.bottom
    }
}

extension ViewLeft : ClipViewDelegate {
    
    func nextClip(_ clipView: ClipView) -> Clip? {
        let stories = State.shared.groupClips[(clipView.group?.groupId)!]
        if (clipView.group?.clipIdxValid())! {  // next clip
            let clip: Clip = (stories?[(clipView.group?.clipViewIdx)!])!
            return clip
        } else {
            return nil
        }
    }
    
    func prevClip(_ clipView: ClipView) -> Clip? {
        let stories = State.shared.groupClips[(clipView.group?.groupId)!]
        if (clipView.group?.clipViewIdx)! < 2 {
            return nil
        } else {
            clipView.group?.clipViewIdx -= 2
            let clip: Clip = (stories?[(clipView.group?.clipViewIdx)!])!
            return clip
        }
    }
    
}

extension ViewLeft : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            processSelectedImage(img: possibleImage)
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            processSelectedImage(img: possibleImage)
        } else if let possibleVideo = info["UIImagePickerControllerMediaURL"] as? NSURL {
            processSelectedVideo(vid: possibleVideo)
        } else {
            return
        }
        
        dismiss(animated: true)
        
    }
    
    func processSelectedImage(img: UIImage) {
        print(img.size)
    }
    
    func processSelectedVideo(vid: NSURL) {
        print(vid)
    }
}


