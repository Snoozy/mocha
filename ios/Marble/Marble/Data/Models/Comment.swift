//
//  Comment.swift
//  Marble
//
//  Created by Daniel Li on 5/19/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation


class Comment {
    
    let id: Int
    let user: User
    let content: String
    
    init(id: Int, user: User, content: String) {
        self.id = id
        self.user = user
        self.content = content
    }
    
}
