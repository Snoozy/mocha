//
//  Clips.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func getMyClips(completionHandler: (() -> Void)? = nil) {
        Networker.shared.getClips(completionHandler: { response in
            switch response.result {
            case .success(let val):
                let contentJson = JSON(val)
                for tuple in (contentJson["content"]) {
                    let groupId = tuple.1["group_id"].int!
                    let clipsJson = tuple.1["clips"].array
                    if self.groupClips[groupId] == nil {
                        self.groupClips[groupId] = [Clip]()
                    }
                    var newClips = [Clip]()
                    for clip in clipsJson! {
                        let mediaUrl = clip["media_url"].stringValue
                        let name = clip["user_name"].stringValue
                        let userId = clip["user_id"].int!
                        let time = clip["timestamp"].int64 ?? 0
                        let isMemory = clip["is_memory"].bool ?? false
                        let id = clip["id"].int!
                        let mediaType = clip["media_type"].stringValue
                        let liked = clip["liked"].bool ?? false
                        
                        self.addClip(clips: &newClips, cache: self.groupMemories[groupId] ?? [Clip](),
                                     groupId: groupId, url: mediaUrl, name: name, userId: userId,
                                     time: time, id: id, mediaType: mediaType, isMemory: isMemory, liked: liked)
                    }
                    self.groupClips[groupId] = newClips
                }
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        })
    }
    
    func loadClips() {
        for (_, clips) in State.shared.groupClips {
            for clip in clips {
                clip.loadMedia()
            }
        }
    }
    
    func getAndLoadClips() {
        self.getMyClips(completionHandler: {
            self.loadClips()
        })
    }

    func checkGroupClipsReady(groupId: Int) -> Bool {
        let clips = self.groupClips[groupId]
        if let clips = clips {
            for clip in clips {
                if !clip.mediaReady {
                    print(clip.mediaUrl + " not ready")
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func addClip(clips: inout [Clip], cache: [Clip], groupId: Int, url: String,
                 name: String, userId: Int, time: Int64, id: Int, mediaType: String, isMemory: Bool, liked: Bool) {
        let clipCheck = findClip(cache: cache, id: id)
        if let clip = clipCheck {
            clip.isMemory = isMemory
            clips.append(clip)
        } else {
            clips.append(Clip(url: url, name: name, userId: userId, time: time, id: id, mediaType: mediaType, isMemory: isMemory, liked: liked))
        }
    }
    
    func getUnseenMarblesCount() -> Int {
        var count = 0
        for group in self.userGroups {
            let clips = self.groupClips[group.groupId]
            if let clips = clips, clips.count > 0 {
                for clip in clips {
                    if clip.timestamp > group.lastSeen && clip.userId != self.me?.id {
                        count += 1
                        break
                    }
                }
            }
        }
        return count
    }
    
    private func findClip(cache: [Clip], id: Int) -> Clip? {
        for clip in cache {
            if clip.id == id {
                return clip
            }
        }
        return nil
    }
    
}
