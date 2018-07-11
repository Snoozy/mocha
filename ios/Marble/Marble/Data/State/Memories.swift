//
//  Memories.swift
//  Marble
//
//  Created by Daniel Li on 12/23/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func getMemoriesForGroup(groupId: Int) -> [Clip] {
        return self.getClips(forGroup: groupId).filter({ (clip) -> Bool in
            clip.isMemory
        })
    }
    
}
