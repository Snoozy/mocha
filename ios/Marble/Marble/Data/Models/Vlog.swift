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
    let posterName: String
    let timestamp: Int64
    let userId: Int
    
    var comments: [Comment]
    
    var videoFileUrl: URL?
        
    init(url: String, name: String, userId: Int, time: Int64, id: Int, comments: [Comment] = [Comment]()) {
        self.id = id
        self.mediaUrl = url
        self.posterName = name
        self.timestamp = time
        self.userId = userId
        self.comments = comments
    }

}
