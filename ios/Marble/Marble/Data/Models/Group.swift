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
    var lastSeen: Int64
    
    init(name: String, id: Int, lastSeen: Int64) {
        self.groupId = id
        self.name = name
        self.lastSeen = lastSeen
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
    
    func updateInfo(name: String, lastSeen: Int64) {
        self.name = name
        self.lastSeen = lastSeen
    }
}
