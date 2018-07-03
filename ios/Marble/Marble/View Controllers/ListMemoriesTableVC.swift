//
//  ListMemoriesTableVC.swift
//  Marble
//
//  Created by Daniel Li on 1/27/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class ListMemoriesTableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: .valueChanged)
        tableView?.addSubview(refreshControl!)
        tableView?.alwaysBounceVertical = true
    }
    
    @objc func pullDownRefresh() {
        State.shared.refreshUserGroups {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        State.shared.getMyMemories()
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
        State.shared.sortGroupsRecent()
        return State.shared.userGroups.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let group = State.shared.userGroups[indexPath.row]
//        if group.vlogNudgeClipIds.count == 0 {
//            return 100.0  // Larger to accomdate for nudge button
//        } else {
            return 70.0
//        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListMemoriesCell", for: indexPath) as! ListMemoriesTVCell

        let group = State.shared.userGroups[indexPath.row]
        cell.groupNameLabel.text = group.name
        cell.group = group
        
        if group.vlogNudgeClipIds.count == 0 {
//            let width = cell.frame.width
//            let sidePadding = CGFloat(width*(1/4))
//            let nudgeBtn = UIButton(frame: CGRect(x: sidePadding, y: cell.frame.height*(4/7), width: cell.frame.width - CGFloat(2*sidePadding), height: 30))
//
//            nudgeBtn.setTitle("+ Vlog", for: .normal)
//            nudgeBtn.setTitleColor(Constants.Colors.MarbleBlue, for: .normal)
//            nudgeBtn.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
//            nudgeBtn.layer.borderWidth = 1
//            nudgeBtn.layer.cornerRadius = 4
//
//            cell.addSubview(nudgeBtn)
            cell.vlogNudgeBtn.isHidden = false
            
            let attrText = NSMutableAttributedString()
            attrText
                .bold("+", font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize + 4))
                .bold("Vlog", font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.medium))
            cell.vlogNudgeBtn.setAttributedTitle(attrText, for: .normal)
//            cell.vlogNudgeBtn.layer.borderWidth = 2
//            cell.vlogNudgeBtn.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
//            cell.vlogNudgeBtn.layer.cornerRadius = 5
            
        }

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
