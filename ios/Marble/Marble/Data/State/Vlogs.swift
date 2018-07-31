//
//  Vlogs.swift
//  Marble
//
//  Created by Daniel Li on 5/24/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func refreshVlogs(completionHandler: (() -> Void)? = nil) {
        Networker.shared.getVlogs { (resp) in
            switch resp.result {
            case .success(let val):
                let contentJson = JSON(val)
                self.newVlogsFromJson(contentJson: contentJson)
                completionHandler?()
            case .failure:
                print(resp.debugDescription)
            }
        }
    }
    
    func getVlogs(afterId: Int, completionHandler: ((Int) -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        Networker.shared.getVlogs(afterId: afterId) { (resp) in
            switch resp.result {
            case .success(let val):
                let contentJson = JSON(val)
                let newCount = self.appendVlogFromJson(contentJson: contentJson)
                completionHandler?(newCount)
            case .failure:
                print(resp.debugDescription)
                errorHandler?()
            }
        }
    }
    
    private func vlogsFromJson(contentJson: JSON) -> [Vlog] {
        var newVlogs = [Vlog]()
        for vlogJson in (contentJson["content"].array!) {
            let vlogId = vlogJson["id"].intValue
            let mediaUrl = vlogJson["media_url"].stringValue
            let groupName = vlogJson["group_name"].stringValue
            let description = vlogJson["description"].stringValue
            let groupId = vlogJson["group_id"].intValue
            let editorId = vlogJson["editor_id"].intValue
            let timestamp = vlogJson["timestamp"].int64Value
            let numComments = vlogJson["comments_count"].intValue
            let views = vlogJson["views"].intValue
            
            let newVlog = Vlog(id: vlogId, url: mediaUrl, description: description, groupName: groupName, groupId: groupId, userId: editorId, time: timestamp, numComments: numComments, views: views)
            newVlogs.append(newVlog)
        }
        return newVlogs
    }
    
    private func newVlogsFromJson(contentJson: JSON) {
        self.vlogFeed = vlogsFromJson(contentJson: contentJson)
    }
    
    private func appendVlogFromJson(contentJson: JSON) -> Int {
        let newVlogs = vlogsFromJson(contentJson: contentJson)
        self.vlogFeed.append(contentsOf: newVlogs)
        return newVlogs.count
    }
    
    func getVlogComments(vlogId: Int, completionHandler: @escaping ([Comment]) -> Void) {
        Networker.shared.getVlogComments(vlogId: vlogId) { (resp) in
            switch resp.result {
            case .success(let val):
                let contentJson = JSON(val)
                var comments = [Comment]()
                for comment in (contentJson["comments"].arrayValue) {
                    let commentId = comment["id"].intValue
                    let content = comment["content"].stringValue
                    let timestamp = comment["timestamp"].int64Value
                    
                    let userJson = comment["user"]
                    let user = User(id: userJson["user_id"].intValue, username: userJson["username"].stringValue, name: userJson["name"].stringValue)
                    let newComment = Comment(id: commentId, user: user, content: content, timestamp: timestamp)
                    comments.append(newComment)
                }
                completionHandler(comments)
            case .failure:
                print(resp.debugDescription)
            }
        }
    }
    
}
