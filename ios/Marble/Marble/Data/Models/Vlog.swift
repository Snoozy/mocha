//
//  Vlog.swift
//  Marble
//
//  Created by Daniel Li on 5/19/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Vlog {
    
    let id: Int
    let mediaUrl: String
    let groupName: String
    let groupId: Int
    let timestamp: Int64
    let userId: Int
    let description: String
    
    var comments: [Comment]
    
    var videoFileUrl: URL?
    var thumbnail: UIImage?
    
    init(id: Int, url: String, description: String, groupName: String, groupId: Int, userId: Int, time: Int64, comments: [Comment] = [Comment]()) {
        self.id = id
        self.mediaUrl = url
        self.groupName = groupName
        self.groupId = groupId
        self.timestamp = time
        self.userId = userId
        self.comments = comments
        self.description = description
    }
    
    func getThumbnailImage(completionHandler: ((UIImage?) -> Void)? = nil) {
        if let thumb = thumbnail {
            completionHandler?(thumb)
            return
        }
        DispatchQueue.global(qos: .background).async {
            let asset: AVAsset = AVURLAsset(url: URL(string: self.mediaUrl)!)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 60) , actualTime: nil)
                self.thumbnail = UIImage(cgImage: thumbnailImage)
                completionHandler?(self.thumbnail)
                return
            } catch let error {
                print("Error generating thumbnail: \(error)")
            }
            completionHandler?(nil)
        }
    }

}
