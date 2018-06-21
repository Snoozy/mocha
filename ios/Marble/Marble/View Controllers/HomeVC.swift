//
//  HomeVC.swift
//  Marble
//
//  Created by Daniel Li on 5/18/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class HomeVC: UITableViewController {
    
    let InfiniteScrollLoadCutoff: Int = 5
    var loading: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.allowsSelection = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: UIControlEvents.valueChanged)
        self.tableView.alwaysBounceVertical = true
        self.tableView.addSubview(refreshControl!)
        
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "HomeTVCell", bundle: nil), forCellReuseIdentifier: "HomeTVCell")
        
        loading = true
        initActivityIndicator()
        startActivityIndicator()
        
        self.tableView.canCancelContentTouches = true
        self.tableView.delaysContentTouches = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(pullDownRefresh), name: Constants.Notifications.RefreshMainGroupState, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    @objc func pullDownRefresh() {
        if self.view.window?.windowLevel != UIWindowLevelStatusBar {
            refresh()
        }
    }
    
    func refresh() {
        State.shared.getVlogs(completionHandler: {
            self.stopActivityIndicator()
            self.loading = false
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
        State.shared.refreshUserGroups()
        State.shared.getMyMemories()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var loadingIndicator = UIActivityIndicatorView()
    
    func initActivityIndicator() {
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = self.view.center
        loadingIndicator.backgroundColor = UIColor(red: 219/250, green: 219/250, blue: 219/250, alpha: 1.0)
        self.tableView.backgroundView = loadingIndicator
    }
    
    func startActivityIndicator() {
        loadingIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        loadingIndicator.stopAnimating()
        let view = UIView(frame: self.view.frame)
        view.center = self.view.center
        view.backgroundColor = UIColor(red: 219/250, green: 219/250, blue: 219/250, alpha: 1.0)
        self.tableView.backgroundView = view
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section >= State.shared.vlogFeed.count - InfiniteScrollLoadCutoff {
            print("inf scroll")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return loading ? 0 : State.shared.vlogFeed.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTVCell", for: indexPath) as! HomeTVCell
        
        let idx = indexPath.section
        let vlog = State.shared.vlogFeed[idx]
        
        cell.marbleName.text = vlog.groupName
        cell.vidPreviewImage.backgroundColor = UIColor.lightGray
        cell.vlog = vlog
        
        vlog.getThumbnailImage { (img) in
            DispatchQueue.main.async {
                if let img = img {
                    cell.vidPreviewImage.image = UIImage(cgImage: (img.cgImage?.cropping(to: cell.vidPreviewImage.frame))!)
                } else {
                    print("could not load img")
                }
            }
        }
        
        cell.layoutIfNeeded()
        
        let playIcon = UIImage(named: "play-icon")
        let playIconBtn = UIButton()
        playIconBtn.setImage(playIcon, for: .normal)
        let previewFrame = cell.vidPreviewImage.frame
        playIconBtn.frame = CGRect(x: (self.view.frame.width/2) - (((playIcon?.size.width)!)/2), y: (previewFrame.height/2) - (((playIcon?.size.height)!)/2), width: (playIcon?.size.width)!, height: (playIcon?.size.height)!)
        playIconBtn.alpha = 0.8
        cell.playIconBtn = playIconBtn
        cell.vidPreviewImage.addSubview(playIconBtn)
        
//        let holdGest = UILongPressGestureRecognizer(target: self, action: #selector(playIconTapped(gest:)))
//        holdGest.minimumPressDuration = 0
        playIconBtn.isUserInteractionEnabled = true
//        playIconView.addGestureRecognizer(holdGest)
        
        let tapGestRecognizer = UITapGestureRecognizer(target: self, action: #selector(playTapped(gest:)))
        cell.vidPreviewImage.isUserInteractionEnabled = true
        cell.vidPreviewImage.addGestureRecognizer(tapGestRecognizer)
        
        cell.vlogDescription.textInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        cell.vlogDescription.delegate = self
        
        cell.vlogDescription.numberOfLines = 3
        cell.vlogDescription.collapsedAttributedLink = NSAttributedString(string: "Read More")
        cell.vlogDescription.ellipsis = NSAttributedString(string: "...")
        cell.vlogDescription.collapsed = true
        
        cell.vlogDescription.text = vlog.description
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
//    @objc func playIconTapped(gest: UILongPressGestureRecognizer) {
//        guard let tappedView = gest.view else {
//            return
//        }
//        let touchPointInTableView = self.tableView.convert(tappedView.center, from: tappedView)
//        guard let indexPath = self.tableView.indexPathForRow(at: touchPointInTableView) else {
//            return
//        }
//        guard let cell = self.tableView.cellForRow(at: indexPath) as? HomeTVCell else {
//            return
//        }
//        if gest.state == .began {
//            cell.playIconView?.alpha = 0.4
//        } else if gest.state == .ended {
//            cell.playIconView?.alpha = 0.8
//            playVideo(vlog: cell.vlog!)
//        }
//    }
    
    @objc func playTapped(gest: UITapGestureRecognizer) {
        guard let tappedView = gest.view else {
            return
        }
        let touchPointInTableView = self.tableView.convert(tappedView.center, from: tappedView)
        guard let indexPath = self.tableView.indexPathForRow(at: touchPointInTableView) else {
            return
        }
        guard let cell = self.tableView.cellForRow(at: indexPath) as? HomeTVCell else {
            return
        }
        playVideo(vlog: cell.vlog!)
    }
    
    func playVideo(vlog: Vlog) {
        print("play video")
        let videoURL = URL(string: vlog.mediaUrl)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIApplication.shared.statusBarStyle = .lightContent
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func goToCameraBtnPress(_ sender: Any) {
        let parentVC = UIApplication.topViewController() as? ViewController
        let screenWidth = UIScreen.main.bounds.size.width
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: screenWidth, y: 0.0), animated: true)
    }
    
    @IBAction func AddMarbleBtnPress(_ sender: UIBarButtonItem) {
        OperationQueue.main.addOperation {
            UIApplication.topViewController()?.present(UIStoryboard(name:"AddMarble", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
        }
    }

}

extension HomeVC : ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel, touch: UITouch) {
        tableView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        tableView.endUpdates()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {}
    
    func didCollapseLabel(_ label: ExpandableLabel) {}
    
}
