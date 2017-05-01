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
                        
                        self.addStory(stories: &newStories, cache: self.groupStories[groupId]!,
                                      groupId: groupId, url: mediaUrl, name: name, userId: userId,
                                      time: time, id: id, mediaType: mediaType, comments: comments)
                    }
                    self.groupStories[groupId] = newStories
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
                    print(story.mediaUrl)
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func addStory(stories: inout [Story], cache: [Story], groupId: Int, url: String,
                  name: String, userId: Int, time: Int64, id: Int, mediaType: String, comments: [Comment]) {
        let storyCheck = findStory(mediaUrl: url, groupId: groupId, comments: comments)
        if let story = storyCheck {
            story.comments = comments
            stories.append(story)
        } else {
            stories.append(Story(url: url, name: name, userId: userId, time: time, id: id, mediaType: mediaType, comments: comments))
        }
    }
    
    private func findStory(mediaUrl: String, groupId: Int, comments: [Comment]) -> Story? {
        for story in self.groupStories[groupId]! {
            if story.mediaUrl == mediaUrl {
                return story
            }
        }
        return nil
    }
    
}
