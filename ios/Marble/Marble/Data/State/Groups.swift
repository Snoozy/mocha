//
//  Groups.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK

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
                    
                    var nudgeClips = [Clip]()
                    for clip in group["vlog_nudge_clips"].arrayValue {
                        let c = Clip(json: clip)
                        nudgeClips.append(c)
                        c.loadMedia()
                    }
                    
                    self.addGroup(groups: &newGroups,
                                  cache: self.userGroups,
                                  name: group["name"].stringValue,
                                  id: groupId,
                                  lastSeen: group["last_seen"].int64 ?? 0,
                                  members: group["members"].int ?? 1,
                                  code: String(group["code"].string ?? "-1"),
                                  vlogNudgeClips: nudgeClips
                    )
                }
                self.userGroups = newGroups
                completionHandler?()
            case .failure(let val):
                print(response.debugDescription)
                Flurry.logError("Failed_Api_Request", message: response.debugDescription, error: val)
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
                        groups.append(Group(json: g))
                    }
                    self.trendingGroups = groups
                }
            case .failure(let val):
                print(response.debugDescription)
                Flurry.logError("Failed_Api_Request", message: response.debugDescription, error: val)
            }
        }
    }
    
    func addGroup(group: Group, groups: inout [Group], cache: [Group]) {
        let groupCheck: Group? = self.findGroupBy(groups: cache, id: group.groupId)
        if groupCheck == nil {
            groups.append(group)
        } else {
            groupCheck?.updateInfo(name: group.name, lastSeen: group.lastSeen, members: group.members, vlogNudgeClips: group.vlogNudgeClips)
            groups.append(groupCheck!)
        }
    }
    
    func addGroup(group: Group) {
        self.addGroup(group: group, groups: &self.userGroups, cache: self.userGroups)
    }
    
    func addGroup(name: String, id: Int, lastSeen: Int64, members: Int, code: String) {
        self.addGroup(groups: &self.userGroups, cache: self.userGroups, name: name, id: id, lastSeen: lastSeen, members: members, code: code)
    }
    
    func findGroupBy(id: Int) -> Group? {
        return findGroupBy(groups: self.userGroups, id: id)
    }
    
    private func addGroup(groups: inout [Group], cache: [Group], name: String, id: Int, lastSeen: Int64, members: Int, code: String, vlogNudgeClips: [Clip] = [Clip]()) {
        self.addGroup(group: Group(name: name, id: id, lastSeen: lastSeen, members: members, code: code, vlogNudgeClips: vlogNudgeClips), groups: &groups, cache: cache)
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
