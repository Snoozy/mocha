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
    
    var videoFileUrl: URL?
    var mediaReady: Bool = false
    
    init(url: String, name: String, userId: Int, time: Int64, id: Int, mediaType: String, isMemory: Bool) {
        self.id = id
        self.mediaUrl = url
        self.posterName = name
        self.timestamp = time
        self.userId = userId
        self.isMemory = isMemory
    }
    
    func loadMedia(completionHandler: ((Clip) -> Void)? = nil) {
        func lock(obj: AnyObject, blk:() -> ()) {
            objc_sync_enter(obj)
            blk()
            objc_sync_exit(obj)
        }
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
