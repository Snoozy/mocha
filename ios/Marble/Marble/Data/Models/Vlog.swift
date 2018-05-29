//
//  Vlog.swift
//  Marble
//
//  Created by Daniel Li on 5/19/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation

class Vlog {
    
    let id: Int
    let mediaUrl: String
    let groupName: String
    let groupId: Int
    let timestamp: Int64
    let userId: Int
    
    var comments: [Comment]
    
    var videoFileUrl: URL?
        
    init(id: Int, url: String, groupName: String, groupId: Int, userId: Int, time: Int64, comments: [Comment] = [Comment]()) {
        self.id = id
        self.mediaUrl = url
        self.groupName = groupName
        self.groupId = groupId
        self.timestamp = time
        self.userId = userId
        self.comments = comments
    }

}
