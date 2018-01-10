//
//  Memories.swift
//  Marble
//
//  Created by Daniel Li on 12/23/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation


extension State {
    
    func getMemoriesForGroup(groupId: Int) -> [Story] {
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
                    let storiesJson = tuple.1["stories"].array
                    if self.groupMemories[groupId] == nil {
                        self.groupMemories[groupId] = [Story]()
                    }
                    var newStories = [Story]()
                    for story in storiesJson! {
                        let mediaUrl = story["media_url"].stringValue
                        let name = story["user_name"].stringValue
                        let userId = story["user_id"].int!
                        let time = story["timestamp"].int64 ?? 0
                        let id = story["id"].int!
                        let mediaType = story["media_type"].stringValue
                        
                        var comments = [Comment]()
                        
                        for commentJson in story["comments"].arrayValue {
                            let comment = Comment(id: commentJson["id"].intValue, mediaUrl: commentJson["media_url"].stringValue, posterName: commentJson["user_name"].stringValue, timestamp: commentJson["timestamp"].int64Value, userId: commentJson["user_id"].intValue)
                            comments.append(comment)
                        }
                        
                        self.addStory(stories: &newStories, cache: self.groupMemories[groupId]!,
                                      groupId: groupId, url: mediaUrl, name: name, userId: userId,
                                      time: time, id: id, mediaType: mediaType, isMemory: true, comments: comments)
                    }
                    self.groupMemories[groupId] = newStories
                }
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        }
    }
}
