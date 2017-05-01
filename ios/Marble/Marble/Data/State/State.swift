//
//  State.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

class State {
    
    static let shared = State()
    
    var userGroups: Array<Group> = [Group]()
    
    var groupStories: [Int : [Story]] = [:]
    
    var authorizing: Bool = false
    
    var me: User?
}
