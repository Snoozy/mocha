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
    var storyViewIdx: Int = 0
    var members: Int
    var lastSeen: Int64
    var code: String
    
    private var membersInfo: [User]
    
    init(name: String, id: Int, lastSeen: Int64, members: Int, code: String) {
        self.groupId = id
        self.name = name
        self.lastSeen = lastSeen
        self.members = members
        self.membersInfo = []
        self.code = code
        if State.shared.groupStories[groupId] != nil {
            for (idx, story) in State.shared.groupStories[groupId]!.enumerated() {
                if lastSeen < story.timestamp {
                    storyViewIdx = idx
                    return
                }
            }
        }
    }
    
    func storyIdxValid() -> Bool {
        return storyViewIdx < (State.shared.groupStories[groupId]?.count)!
    }
    
    func updateInfo(name: String, lastSeen: Int64, members: Int) {
        self.name = name
        self.lastSeen = lastSeen
        self.members = members
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
