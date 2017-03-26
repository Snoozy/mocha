//
//  Groups.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func refreshUserGroups(completionHandler: (() -> Void)? = nil) {
        Networker.shared.listGroups(completionHandler: { response in
            switch response.result {
            case .success:
                let json = response.result.value as! [String : Any]
                print(json)
                let groupsJson = JSON.init(parseJSON: json["groups"] as! String)
                for group in groupsJson {
                    let groupId = group.1["group_id"].int!
                    self.addGroup(name: group.1["name"].stringValue, id: groupId, lastSeen: group.1["last_seen"].int64 ?? 0)
                }
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        })
    }
    
    func sortGroupsRecent() {
        self.userGroups.sort(by: groupsRecentSort)
    }
    
    private func groupsRecentSort(this: Group, that: Group) -> Bool {
        return this.lastSeen > that.lastSeen
    }
    
    func addGroup(name: String, id: Int, lastSeen: Int64) {
        let groupCheck: Group? = self.findGroupBy(id: id)
        if groupCheck == nil {
            self.userGroups.append(Group(name: name, id: id, lastSeen: lastSeen))
        } else {
            groupCheck?.updateInfo(name: name, lastSeen: lastSeen)
        }
    }
    
    func findGroupBy(id: Int) -> Group? {
        for g in userGroups {
            if g.groupId == id {
                return g
            }
        }
        return nil
    }
    
    private func checkGroupExists(id: Int) -> Bool {
        for group in self.userGroups {
            if group.groupId == id {
                return true
            }
        }
        return false
    }
    
}
