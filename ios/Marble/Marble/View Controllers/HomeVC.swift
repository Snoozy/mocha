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
    var updatingInfScroll: Bool = false
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(clipUploadStarted), name: Constants.Notifications.ClipUploadStarted, object: nil)
        
        pullDownRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    @objc func clipUploadStarted() {
        DispatchQueue.main.async {
            var style = ToastStyle()
            style.backgroundColor = Constants.Colors.InfoNotifColor
            style.verticalPadding = 10.0
            style.horizontalPadding = 15.0
            self.navigationController?.view.makeToast("Clip will continue uploading in the background", duration: 5.0, position: .top, style: style)
        }
        NotificationCenter.default.post(name: Constants.Notifications.RefreshMainGroupState, object: nil)
    }
    
    @objc func pullDownRefresh() {
        State.shared.homeTVInfiniteScrollingDone = false
        for vlog in State.shared.vlogFeed {
            vlog.thumbnailTried = false
        }
        if self.view.window?.windowLevel != UIWindowLevelStatusBar {
            refresh()
        }
    }
    
    func refresh() {
        if State.shared.me == nil {
            State.shared.ping(deviceToken: nil)
        }
        State.shared.refreshVlogs(completionHandler: {
            self.stopActivityIndicator()
            self.loading = false
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
        State.shared.refreshUserGroups()
        State.shared.refreshClips()
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
        loadingIndicator.backgroundColor = Constants.Colors.HomeBgColor
        self.tableView.backgroundView = loadingIndicator
    }
    
    func startActivityIndicator() {
        loadingIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        loadingIndicator.stopAnimating()
        let view = UIView(frame: self.view.frame)
        view.center = self.view.center
        view.backgroundColor = Constants.Colors.HomeBgColor
        if State.shared.vlogFeed.count == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: (self.tableView.frame.height/2)-100, width: self.tableView.frame.width, height: 25))
            label.textAlignment = .center
            label.alpha = 0.6
            label.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
            label.text = "No posts...yet"
            view.addSubview(label)
        }
        self.tableView.backgroundView = view
    }
    
    func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    let infScrollSemaphore = DispatchSemaphore(value: 1)
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  !State.shared.homeTVInfiniteScrollingDone
            && indexPath.section == State.shared.vlogFeed.count - InfiniteScrollLoadCutoff {
            print("infinite scroll load")
            let prevVlogCount = State.shared.vlogFeed.count
            State.shared.getVlogs(afterId: State.shared.vlogFeed.last!.id, completionHandler: { newCount in
                self.synced(self, closure: {
                    DispatchQueue.main.async {
                        if newCount <= 0 {
                            State.shared.homeTVInfiniteScrollingDone = true
                            return
                        }
                        if State.shared.vlogFeed.count < prevVlogCount {
                            return
                        }
                        let idxs = IndexSet(integersIn: State.shared.vlogFeed.count - newCount..<State.shared.vlogFeed.count)
                        print(idxs)
                        self.tableView.insertSections(idxs, with: .automatic)
                    }
                })
            }, errorHandler: {
            })
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
        return 350
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTVCell", for: indexPath) as! HomeTVCell
        
        let idx = indexPath.section
        
        print(idx)
        let vlog = State.shared.vlogFeed[idx]
        
        cell.marbleName.text = vlog.groupName
        cell.vidPreviewImage.backgroundColor = UIColor.lightGray
        cell.vlog = vlog
        
        vlog.getThumbnailImage { (img) in
            DispatchQueue.main.async {
                if let img = img {
                    let imageWidth = img.size.width
                    let imageHeight = img.size.height
                    let width = self.tableView.bounds.width
                    let height = cell.vidPreviewImage.bounds.height
                    let origin = CGPoint(x: (imageWidth - width)/2, y: (imageHeight - height)/2)
                    let size = CGSize(width: width, height: height)
                    
                    cell.vidPreviewImage.image = img.crop(rect: CGRect(origin: origin, size: size))
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
        
        playIconBtn.isUserInteractionEnabled = true
        playIconBtn.tag = idx
        playIconBtn.addTarget(self, action: #selector(playBtnTapped(_:)), for: .touchUpInside)
        
        let tapGestRecognizer = UITapGestureRecognizer(target: self, action: #selector(playTapped(gest:)))
        cell.vidPreviewImage.isUserInteractionEnabled = true
        cell.vidPreviewImage.addGestureRecognizer(tapGestRecognizer)
        
        cell.vlogDescription.textInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        cell.vlogDescription.delegate = self
        
        cell.vlogDescription.numberOfLines = 3
        let attributedStringColor = [NSAttributedStringKey.foregroundColor : Constants.Colors.MarbleBlue]
        cell.vlogDescription.collapsedAttributedLink = NSAttributedString(string: "More", attributes: attributedStringColor)
        cell.vlogDescription.ellipsis = NSAttributedString(string: "...")
        cell.vlogDescription.collapsed = true
        
        cell.commentBtn.setTitle(String(vlog.numComments) + (vlog.numComments == 1 ? " Comment" : " Comments"), for: .normal)
        
        cell.vlogDescription.text = vlog.description
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    @objc func playBtnTapped(_ sender: UIButton) {
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: sender.tag)) as? HomeTVCell else {
            return
        }
        playVideo(vlog: cell.vlog!)
    }
    
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
        let videoURL = { () -> URL? in
            if let fileUrl = vlog.videoFileUrl {
                print("play video file cached")
                return fileUrl
            } else {
                print("playing from remote url")
                return URL(string: vlog.mediaUrl)
            }
        }()
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
    
    @IBOutlet weak var addMarbleBtn: UIBarButtonItem!
    
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
