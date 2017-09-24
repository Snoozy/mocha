//
//  SendGroupTV.swift
//  Marble
//
//  Created by Daniel Li on 2/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class SendGroupTV: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    static var checked: Array<(Bool, Int?)> = Array(repeating: (false, nil), count: State.shared.userGroups.count)

    var parent: ViewPickDest?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SendGroupTV.checked = Array(repeating: (false, nil), count: State.shared.userGroups.count)
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Marbles"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupTVCell
        let group = State.shared.userGroups[indexPath.row]
        cell.title.text = group.name
        SendGroupTV.checked[indexPath.row].1 = group.groupId
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return State.shared.userGroups.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if !SendGroupTV.checked[indexPath.row].0 {
                cell.accessoryType = .checkmark
                SendGroupTV.checked[indexPath.row].0 = true
                parent?.enableSendButton()
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                cell.accessoryType = .none
                SendGroupTV.checked[indexPath.row].0 = false
                tableView.deselectRow(at: indexPath, animated: true)
                if countSelected() <= 0 {
                    parent?.disableSendButton()
                }
            }
        }
    }
    
    func enableGroups(groups: [Group]) {
        for (idx, (_, groupId)) in SendGroupTV.checked.enumerated() {
            if let id = groupId, groups.contains(where: {id == $0.groupId}) {
                SendGroupTV.checked[idx].0 = true
                if let cell = self.cellForRow(at: IndexPath(item: idx, section: 0)) {
                    cell.accessoryType = .checkmark
                }
            }
        }
        parent?.enableSendButton()
    }
    
    func countSelected() -> Int {
        var count = 0
        for (selected, _) in SendGroupTV.checked {
            if selected {
                count += 1
            }
        }
        return count
    }

}
