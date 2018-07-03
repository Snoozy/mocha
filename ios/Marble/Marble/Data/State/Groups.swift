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
            case .success(let val):
                let json = JSON(val)
                let groupsJson = json["groups"].arrayValue
                var newGroups = [Group]()
                for group in groupsJson {
                    let groupId = group["group_id"].int!
                    self.addGroup(groups: &newGroups,
                                  cache: self.userGroups,
                                  name: group["name"].stringValue,
                                  id: groupId,
                                  lastSeen: group["last_seen"].int64 ?? 0,
                                  members: group["members"].int ?? 1,
                                  code: String(group["code"].int ?? groupId),
                                  vlogNudgeClipIds: group["vlog_nudge"].stringValue.split(separator: ",").map { Int($0)! }
                    )
                }
                self.userGroups = newGroups
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        })
    }
    
    func refreshTrendingGroups(completionHandler: (() -> Void)? = nil) {
        Networker.shared.getTrendingGroups { (response) in
            switch response.result {
            case .success(let val):
                let json = JSON(val)
                var groups = [Group]()
                if let gJson = json["results"].array {
                    for g in gJson {
                        groups.append(Group(name: g["name"].stringValue,
                                            id: g["group_id"].intValue,
                                            lastSeen: g["last_seen"].int64Value,
                                            members: g["members"].int ?? 1,
                                            code: String(g["code"].intValue)))
                    }
                    self.trendingGroups = groups
                }
            case .failure:
                print(response.debugDescription)
            }
        }
    }
    
    func sortGroupsRecent() {
        self.userGroups.sort(by: groupsRecentSort)
    }
    
    func addGroup(name: String, id: Int, lastSeen: Int64, members: Int, code: String) {
        print(code)
        self.addGroup(groups: &self.userGroups, cache: self.userGroups, name: name, id: id, lastSeen: lastSeen, members: members, code: code)
    }
    
    func findGroupBy(id: Int) -> Group? {
        return findGroupBy(groups: self.userGroups, id: id)
    }
    
    private func groupsRecentSort(this: Group, that: Group) -> Bool {
        let thisLastClip = self.groupClips[this.groupId]?.last?.timestamp ?? 0
        let thatLastClip = self.groupClips[that.groupId]?.last?.timestamp ?? 0
        return thisLastClip > thatLastClip
    }
    
    private func addGroup(groups: inout [Group], cache: [Group], name: String, id: Int, lastSeen: Int64, members: Int, code: String, vlogNudgeClipIds: [Int] = [Int]()) {
        let groupCheck: Group? = self.findGroupBy(groups: cache, id: id)
        if groupCheck == nil {
            groups.append(Group(name: name, id: id, lastSeen: lastSeen, members: members, code: code, vlogNudgeClipIds: vlogNudgeClipIds))
        } else {
            groupCheck?.updateInfo(name: name, lastSeen: lastSeen, members: members, vlogNudgeClipIds: vlogNudgeClipIds)
            groups.append(groupCheck!)
        }
    }
    
    private func findGroupBy(groups: [Group], id: Int) -> Group? {
        for g in groups {
            if g.groupId == id {
                return g
            }
        }
        return nil
    }
    
    private func checkGroupExists(groups: [Group], id: Int) -> Bool {
        for group in groups {
            if group.groupId == id {
                return true
            }
        }
        return false
    }
    
}
