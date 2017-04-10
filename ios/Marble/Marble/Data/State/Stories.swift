//
//  Stories.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func getMyStories(completionHandler: (() -> Void)? = nil) {
        Networker.shared.getStories(completionHandler: { response in
            switch response.result {
            case .success(let val):
                let contentJson = JSON(val)
                for tuple in (contentJson["content"]) {
                    let groupId = tuple.1["group_id"].int!
                    let storiesJson = tuple.1["stories"].array
                    if self.groupStories[groupId] == nil {
                        self.groupStories[groupId] = [Story]()
                    }
                    for story in storiesJson! {
                        let mediaUrl = story["media_url"].stringValue
                        if !self.storyExists(mediaUrl: mediaUrl, groupId: groupId) {
                            self.groupStories[groupId]!.append(Story(url: mediaUrl, name: story["user_name"].stringValue, userId: story["user_id"].int!, time: story["timestamp"].int64 ?? 0))
                        }
                    }
                }
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        })
    }
        
    func checkGroupStoriesReady(groupId: Int) -> Bool {
        let stories = self.groupStories[groupId]
        if let stories = stories {
            for story in stories {
                if !story.mediaReady {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func storyExists(mediaUrl: String, groupId: Int) -> Bool {
        for story in self.groupStories[groupId]! {
            if story.mediaUrl == mediaUrl {
                return true
            }
        }
        return false
    }
    
}
