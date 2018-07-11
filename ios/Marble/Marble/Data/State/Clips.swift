//
//  Clips.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
        
    func getClips(forGroup groupId: Int) -> [Clip] {
        return self.groupClips[groupId] ?? [Clip]()
    }
    
    func refreshClips(completionHandler: (() -> Void)? = nil) {
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
                    for clipJson in clipsJson! {
                        
                        let c = Clip(json: clipJson)
                        
                        self.addClip(clips: &newClips, cache: self.groupClips[groupId] ?? [Clip](), clip: c)
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
        self.refreshClips(completionHandler: {
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
    
    func addClip(clips: inout [Clip], cache: [Clip], clip: Clip) {
        let clipCheck = findClip(cache: cache, id: clip.id)
        if let c = clipCheck {
            c.isMemory = clip.isMemory
            c.liked = clip.liked
            clips.append(c)
        } else {
            clips.append(clip)
        }
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
