//
//  MembersInfoTV.swift
//  Marble
//
//  Created by Daniel Li on 11/8/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class MembersInfoTV: UITableView, UITableViewDataSource, UITableViewDelegate {

    var groupMembers: [User] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(format: "Members (%d)", groupMembers.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberTVCell
        cell.memberName.text = groupMembers[indexPath.row].name
        
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }

}
