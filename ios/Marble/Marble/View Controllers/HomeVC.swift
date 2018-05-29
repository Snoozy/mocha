//
//  HomeVC.swift
//  Marble
//
//  Created by Daniel Li on 5/18/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class HomeVC: UITableViewController {
    
    let InfiniteScrollLoadCutoff: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.allowsSelection = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: UIControlEvents.valueChanged)
        self.tableView.alwaysBounceVertical = true
        self.tableView.addSubview(refreshControl!)
        
        initActivityIndicator()
        loadingIndicator.startAnimating()
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "HomeTVCell", bundle: nil), forCellReuseIdentifier: "HomeTVCell")
    }
    
    @objc func pullDownRefresh() {
        if self.view.window?.windowLevel != UIWindowLevelStatusBar {
            refresh()
        }
    }
    
    func refresh() {
        State.shared.refreshUserGroups(completionHandler: {
            self.loadingIndicator.stopAnimating()
            self.refreshControl?.endRefreshing()
        })
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
        loadingIndicator.backgroundColor = UIColor.lightGray
        self.tableView.backgroundView = loadingIndicator
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section >= State.shared.vlogFeed.count - InfiniteScrollLoadCutoff {
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTVCell", for: indexPath) as! HomeTVCell
        
        cell.marbleName.text = "ASDASD"
        cell.vidPreviewImage.backgroundColor = UIColor.gray

        return cell
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
