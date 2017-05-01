//
//  User.swift
//  Marble
//
//  Created by Daniel Li on 4/30/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

class User {
    let id: Int
    let username: String
    let name: String
    
    init(id: Int, username: String, name: String) {
        self.id = id
        self.username = username
        self.name = name
    }
}
