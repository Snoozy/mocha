//
//  Vlogs.swift
//  Marble
//
//  Created by Daniel Li on 5/24/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func getVlogs(completionHandler: (() -> Void)? = nil) {
        Networker.shared.getVlogs { (resp) in
            switch resp.result {
            case .success(let val):
                let contentJson = JSON(val)
                for vlogJson in (contentJson["content"].array!) {
                    let vlogId = vlogJson["id"].intValue
                    let mediaUrl = vlogJson["media_url"].stringValue
                    let groupName = vlogJson["group_name"].stringValue
                    let description = vlogJson["description"].stringValue
                    let groupId = vlogJson["group_id"].intValue
                    let editorId = vlogJson["editor_id"].intValue
                    let timestamp = vlogJson["timestamp"].int64Value
                    
                    let newVlog = Vlog(id: vlogId, url: mediaUrl, description: description, groupName: groupName, groupId: groupId, userId: editorId, time: timestamp)
                    self.addVlog(vlogs: &self.vlogFeed, newVlog: newVlog)
                }
                completionHandler?()
            case .failure:
                print(resp.debugDescription)
            }
        }
    }
    
    func addVlog(vlogs: inout [Vlog], newVlog: Vlog) {
        if vlogs.count == 0 {
            vlogs.append(newVlog)
            return
        }
        for (idx, v) in vlogs.enumerated() {
            if v.id == newVlog.id {
                return
            } else if newVlog.timestamp < newVlog.timestamp {
                vlogs.insert(newVlog, at: idx)
                return
            }
        }
        vlogs.insert(newVlog, at: vlogs.count)
        return
    }
    
}
