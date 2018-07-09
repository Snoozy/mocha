//
//  Story.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class Clip {
    
    let id: Int
    let mediaUrl: String
    let posterName: String
    let timestamp: Int64
    let userId: Int
    var isMemory: Bool
    var liked: Bool
    
    var videoFileUrl: URL?
    var mediaReady: Bool = false
    
    init(url: String, name: String, userId: Int, time: Int64, id: Int, mediaType: String, isMemory: Bool, liked: Bool = false) {
        self.id = id
        self.mediaUrl = url
        self.posterName = name
        self.timestamp = time
        self.userId = userId
        self.isMemory = isMemory
        self.liked = liked
    }
    
    init(json: JSON) {
        self.mediaUrl = json["media_url"].stringValue
        self.posterName = json["user_name"].stringValue
        self.userId = json["user_id"].int!
        self.timestamp = json["timestamp"].int64 ?? 0
        self.isMemory = json["is_memory"].bool ?? false
        self.id = json["id"].int!
        self.liked = json["liked"].bool ?? false
    }
    
    func loadMedia(completionHandler: ((Clip) -> Void)? = nil) {
        if !self.mediaReady {
            let mediaId = mediaUrl.components(separatedBy: "/").last
            let filename = String(mediaId!) + ".mp4"
            var fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            fileUrl.appendPathComponent(filename)
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                Networker.shared.downloadVideo(fileUrl: fileUrl, url: self.mediaUrl, completionHandler: { url, response in
                    print("video download done")
                    self.videoFileUrl = url
                    self.mediaReady = true
                    completionHandler?(self)
                })
            } else {
                print("cached video hit: \(fileUrl)")
                self.videoFileUrl = fileUrl
                self.mediaReady = true
                completionHandler?(self)
            }
        } else {
            completionHandler?(self)
        }
    }
    
}
