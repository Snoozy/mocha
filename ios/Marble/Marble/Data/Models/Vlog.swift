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
    var numComments: Int
    
    var comments: [Comment]
    
    var videoFileUrl: URL?
    var thumbnail: UIImage?
    var thumbnailTried: Bool = false
    
    init(id: Int, url: String, description: String, groupName: String, groupId: Int, userId: Int, time: Int64, numComments: Int, comments: [Comment] = [Comment]()) {
        self.id = id
        self.mediaUrl = url
        self.groupName = groupName
        self.groupId = groupId
        self.timestamp = time
        self.userId = userId
        self.comments = comments
        self.description = description
        self.numComments = numComments
    }
    
    func getThumbnailImage(completionHandler: ((UIImage?) -> Void)? = nil) {
        if thumbnailTried {
            completionHandler?(thumbnail)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let asset: AVAsset = {
                if let fileUrl = self.videoFileUrl{
                    return AVURLAsset(url: fileUrl)
                } else {
                    return AVURLAsset(url: URL(string: self.mediaUrl)!)
                }
            }()
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 60) , actualTime: nil)
                self.thumbnail = UIImage(cgImage: thumbnailImage)
                print(self.thumbnail?.size)
                self.thumbnailTried = true
                completionHandler?(self.thumbnail)
                return
            } catch {
                self.thumbnailTried = true
                print("Error generating thumbnail for vlog id: \(self.id)")
            }
            completionHandler?(nil)
        }
    }

}
