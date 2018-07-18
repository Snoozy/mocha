//
//  SearchVC.swift
//  Marble
//
//  Created by Daniel Li on 1/30/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class SearchVC: UITableViewController {

    var searchBar: UISearchBar?
    let placeholderWidth = 220
    var offset = UIOffset()
    
    var searching: Bool = false
    var searchResults: [Group] = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar()
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for Marbles"
        searchBar?.setTextFieldColor(color: UIColor.lightGray.withAlphaComponent(0.4))
        searchBar?.delegate = self
        offset = UIOffset(horizontal: (searchBar!.frame.width - CGFloat(placeholderWidth)) / 2, vertical: 0)
        searchBar?.setPositionAdjustment(offset, for: .search)
        navigationItem.titleView = searchBar
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "SearchTVCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return searching ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching {
            return "Search Results"
        }
        return "Trending Marbles"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTVCell", for: indexPath) as! SearchTableViewCell
        cell.backgroundColor = UIColor.white
        
        let group = searching ? searchResults[indexPath.row] : State.shared.trendingGroups[indexPath.row]
        cell.textLabel?.text = group.name
        cell.group = group
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchResults.count
        }
        return State.shared.trendingGroups.count
    }
    
    var responder: SCLAlertViewResponder?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.searchBar?.resignFirstResponder()
        
        let cell = tableView.cellForRow(at: indexPath) as! SearchTableViewCell
        let group = cell.group!
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            hideWhenBackgroundViewIsTapped: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Join Marble", action: {
            Networker.shared.joinGroup(code: group.code, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    print("segue")
                    let json = JSON(value)
                    print(json)
                    let group = json["group"]
                    let groupId = group["group_id"].int!
                    State.shared.addGroup(name: group["name"].stringValue, id: groupId, lastSeen: group["last_seen"].int64 ?? 0, members: group["members"].int ?? 1, code: group["code"].string ?? String(groupId))
                    NotificationCenter.default.post(name: Constants.Notifications.RefreshMainGroupState, object: nil)
                    self.tabBarController?.selectedIndex = 0
                case .failure:
                    print(response.debugDescription)
                }
            })
        })
        alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: Constants.Colors.MarbleBlue, action: {
            self.responder?.close()
        })
        self.responder = alert.showInfo(group.name, subTitle: String(group.members) + (group.members > 1 ? " members" : " member"))
    }

}

extension SearchVC : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            Networker.shared.searchGroups(query: searchText, completionHandler: { (groups) in
                self.searching = true
                self.searchResults = groups
                self.tableView.reloadData()
            })
        } else {
            searching = false
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        let noOffset = UIOffset(horizontal: 0, vertical: 0)
        searchBar.setPositionAdjustment(noOffset, for: .search)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        if (searchBar.text?.isEmpty)! {
            searchBar.setPositionAdjustment(offset, for: .search)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searching = false
        self.tableView.reloadData()
    }
}
