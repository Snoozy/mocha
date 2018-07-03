//
//  Group.swift
//  Marble
//
//  Created by Daniel Li on 2/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//
 
import Foundation
import UIKit

class Group {
    var groupId: Int
    var name: String
    var clipViewIdx: Int = 0
    var members: Int
    var lastSeen: Int64
    var code: String
    var vlogNudgeClipIds: [Int]
    
    private var membersInfo: [User]
    
    init(name: String, id: Int, lastSeen: Int64, members: Int, code: String, vlogNudgeClipIds: [Int] = [Int]()) {
        self.groupId = id
        self.name = name
        self.lastSeen = lastSeen
        self.members = members
        self.membersInfo = []
        self.code = code
        self.vlogNudgeClipIds = vlogNudgeClipIds
        if State.shared.groupClips[groupId] != nil {
            for (idx, clip) in State.shared.groupClips[groupId]!.enumerated() {
                if lastSeen < clip.timestamp {
                    clipViewIdx = idx
                    return
                }
            }
        }
    }
    
    func clipIdxValid() -> Bool {
        return clipViewIdx < (State.shared.groupClips[groupId]?.count)!
    }
    
    func updateInfo(name: String, lastSeen: Int64, members: Int, vlogNudgeClipIds: [Int]?) {
        self.name = name
        self.lastSeen = lastSeen
        self.members = members
        if let v = vlogNudgeClipIds {
            self.vlogNudgeClipIds = v
        }
    }
    
    func getMembers(completionHandler: @escaping ([User]) -> Void) {
        if membersInfo.isEmpty {
            Networker.shared.groupInfo(id: self.groupId, completionHandler: { response in
                switch response.result {
                case .success(let val):
                    let contentJson = JSON(val)
                    var users: [User] = []
                    for tuple in (contentJson["members"]) {
                        let userId = tuple.1["id"].int!
                        let name = tuple.1["name"].stringValue
                        let username = tuple.1["username"].stringValue
                        users.append(User(id: userId, username: username, name: name))
                    }
                    self.membersInfo = users
                    completionHandler(self.membersInfo)
                case .failure:
                    print(response.debugDescription)
                }
            })
        } else {
            completionHandler(membersInfo)
        }
    }
    
}
