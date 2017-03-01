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
    var groupId: Int?
    var name: String?
    var storyViewIdx: Int = 0
    
    init(name: String, id: Int) {
        self.groupId = id
        self.name = name
    }
    
    init(json: JSON) {
        self.name = json["name"].string
        self.groupId = json["group_id"].int
        print("init with id: " + String(self.groupId!))
    }
}
