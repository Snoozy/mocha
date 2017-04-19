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

class Story {
    
    let id: Int
    let mediaUrl: String
    let posterName: String
    let timestamp: Int64
    let userId: Int
    let mediaType: MediaType
    
    var media: UIImage?
    var videoFileUrl: URL?
    var mediaReady: Bool = false
    
    init(url: String, name: String, userId: Int, time: Int64, id: Int, mediaType: String) {
        self.id = id
        self.mediaUrl = url
        self.posterName = name
        self.timestamp = time
        self.userId = userId
        if mediaType == "video" {
            self.mediaType = .video
        } else {
            self.mediaType = .image
        }
    }
    
    func loadMedia(completionHandler: ((Story) -> Void)? = nil) {
        if !self.mediaReady {
            let urlReq = URLRequest(url: URL(string: self.mediaUrl)!)
            if self.mediaType == .image {
                Networker.shared.imageDownloader.download(urlReq) { response in
                    let screenBounds = UIScreen.main.bounds
                    self.media = response.result.value
                    self.media?.af_inflate()
                    self.media = self.media?.af_imageScaled(to: CGSize(width: screenBounds.width + 2, height: screenBounds.height + 2))
                    self.mediaReady = true
                    completionHandler?(self)
                }
            } else {
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
                    print("video cached")
                    self.videoFileUrl = fileUrl
                    self.mediaReady = true
                    completionHandler?(self)
                }
            }
        } else {
            completionHandler?(self)
        }
    }
    
}
