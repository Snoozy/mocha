//
//  Users.swift
//  Marble
//
//  Created by Daniel Li on 4/10/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func blockUser(userId: Int, completionHandler: (() -> Void)? = nil) {
        Networker.shared.blockUser(blockeeId: userId, completionHandler: { response in
            switch response.result {
            case .success(let val):
                let json = JSON(val)
                if json["status"].int ?? 1 == 0 {
                    for (id, stories) in self.groupStories {
                        self.groupStories[id] = stories.filter({
                            print("asdfasdf")
                            return $0.userId != userId
                        })
                        print(self.groupStories[id])
                    }
                }
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        })
    }
    
}
