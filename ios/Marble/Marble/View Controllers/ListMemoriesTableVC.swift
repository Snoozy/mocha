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
        
        self.tableView.rowHeight = 70
        self.tableView.tableFooterView = UIView()
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListMemoriesCell", for: indexPath) as! ListMemoriesTVCell

        let group = State.shared.userGroups[indexPath.row]
        cell.groupNameLabel.text = group.name
        cell.group = group

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
