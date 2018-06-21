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
        if let val = self.groupMemories[groupId] {
            return val
        } else {
            return []
        }
    }
    
    func getMyMemories(completionHandler: (() -> Void)? = nil) {
        Networker.shared.getMemories { (response) in
            switch response.result {
            case .success(let val):
                let contentJson = JSON(val)
//                print(contentJson)
                for tuple in (contentJson["content"]) {
                    let groupId = tuple.1["group_id"].int!
                    let clipsJson = tuple.1["clips"].array
                    if self.groupMemories[groupId] == nil {
                        self.groupMemories[groupId] = [Clip]()
                    }
                    var newClips = [Clip]()
                    for clip in clipsJson! {
                        let mediaUrl = clip["media_url"].stringValue
                        let name = clip["user_name"].stringValue
                        let userId = clip["user_id"].int!
                        let time = clip["timestamp"].int64 ?? 0
                        let id = clip["id"].int!
                        let mediaType = clip["media_type"].stringValue
                        let liked = clip["liked"].bool ?? false
                        
                        self.addClip(clips: &newClips, cache: self.groupMemories[groupId] ?? [Clip](),
                                      groupId: groupId, url: mediaUrl, name: name, userId: userId,
                                      time: time, id: id, mediaType: mediaType, isMemory: true, liked: liked)
                    }
                    self.groupMemories[groupId] = newClips
                }
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        }
    }
}
