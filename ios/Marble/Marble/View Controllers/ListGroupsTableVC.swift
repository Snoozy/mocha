//
//  ListMemoriesTableVC.swift
//  Marble
//
//  Created by Daniel Li on 1/27/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class ListGroupsTableVC: UITableViewController {

    var vlogifyNavController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: .valueChanged)
        tableView?.addSubview(refreshControl!)
        tableView?.alwaysBounceVertical = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(pullDownRefresh), name: Constants.Notifications.RefreshMainGroupState, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    @objc func pullDownRefresh() {
        State.shared.refreshUserGroups {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        State.shared.refreshClips()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addMarbleBtnPress(_ sender: Any) {
        OperationQueue.main.addOperation {
            UIApplication.topViewController()?.present(UIStoryboard(name:"AddMarble", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
        }
    }
    
    @IBAction func gotoCameraBtnPress(_ sender: Any) {
        let parentVC = UIApplication.topViewController() as? ViewController
        let screenWidth = UIScreen.main.bounds.size.width
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: screenWidth, y: 0.0), animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return State.shared.userGroups.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    let NUDGE_OVERRIDE = false

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListMemoriesCell", for: indexPath) as! ListMemoriesTVCell

        let group = State.shared.userGroups[indexPath.row]
        cell.groupNameLabel.text = group.name
        cell.group = group
        
        if group.vlogNudgeClips.count > 0 || NUDGE_OVERRIDE {
            cell.vlogNudgeBtn.isHidden = false
            
            let superAttrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: UIFont.labelFontSize - 0, weight: UIFont.Weight.regular), .baselineOffset: 8]
            let superText = NSMutableAttributedString(string:"+", attributes: superAttrs)
            
            let attrText = NSMutableAttributedString()
            attrText
                .bold("Vlog", font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.semibold))
                .append(superText)
            cell.vlogNudgeBtn.setAttributedTitle(attrText, for: .normal)
        }
        
        cell.delegate = self

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard(name: "Memories", bundle: nil).instantiateInitialViewController() as! MemoriesVC
        let group = (tableView.cellForRow(at: indexPath) as! ListMemoriesTVCell).group
        vc.group = group
        vc.title = group!.name + "'s Clips"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ListGroupsTableVC: ListMemoriesTVCellDelegate {
    
    func processNudge(group: Group?) {
        let storyboard = UIStoryboard(name: "Vlogify", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditVlog") as! EditVlogVC
        vc.clips = group?.vlogNudgeClips ?? [Clip]()
        vc.group = group
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        
        let btn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.backAction(_:)))
        btn.tintColor = UIColor.black
        vc.navigationItem.setLeftBarButton(btn, animated: false)
        
        vlogifyNavController = navController
        
        self.present(navController, animated:true, completion: nil)
    }
    
    @objc func backAction(_ sender: UIButton) {
        vlogifyNavController?.dismiss(animated: true, completion: nil)
    }
    
}

extension ListGroupsTableVC: EditVlogDelegate {
    
    func videoExportDone(_ editVlogVC: EditVlogVC) {
        vlogifyNavController?.dismiss(animated: true, completion: nil)
        self.view.makeToast("Vlog will continue uploading in the background.", duration: 3.0, position: .top)
    }
    
}
