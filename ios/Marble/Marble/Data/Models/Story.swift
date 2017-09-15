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
    
    var comments: [Comment]
    
    var media: UIImage?
    var videoFileUrl: URL?
    var mediaReady: Bool = false
    
    var commentLoadCount: Int?
    
    init(url: String, name: String, userId: Int, time: Int64, id: Int, mediaType: String, comments: [Comment] = [Comment]()) {
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
        self.comments = comments
    }
    
    func loadMedia(completionHandler: ((Story) -> Void)? = nil) {
        func lock(obj: AnyObject, blk:() -> ()) {
            objc_sync_enter(obj)
            blk()
            objc_sync_exit(obj)
        }
        self.commentLoadCount = self.comments.count
        if !self.mediaReady {
            let urlReq = URLRequest(url: URL(string: self.mediaUrl)!)
            let mediaId = mediaUrl.components(separatedBy: "/").last
            if self.mediaType == .image {
                let filename = String(mediaId!) + ".jpg"
                var fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                fileUrl.appendPathComponent(filename)
                if !FileManager.default.fileExists(atPath: fileUrl.path) {
                    Networker.shared.imageDownloader.download(urlReq) { response in
                        let screenBounds = UIScreen.main.bounds
                        self.media = response.result.value
                        self.media?.af_inflate()
                        self.media = self.media?.af_imageScaled(to: CGSize(width: screenBounds.width + 2, height: screenBounds.height + 2))
                        self.mediaReady = true
                        if let img = self.media {
                            let data = UIImageJPEGRepresentation(img, 1.0)
                            try? data?.write(to: fileUrl)
                        }
                        if self.comments.count > 0 {
                            for comment in self.comments {
                                comment.loadMedia(completionHandler: { comment in
                                    lock(obj: self.commentLoadCount! as AnyObject, blk: {
                                        self.commentLoadCount! -= 1
                                    })
                                    if self.commentLoadCount ?? 0 <= 0 {
                                        completionHandler?(self)
                                    }
                                })
                            }
                        } else {
                            completionHandler?(self)
                        }
                    }
                } else {
                    let image = try? UIImage(data: Data(contentsOf: fileUrl))
                    self.media = image!
                    self.mediaReady = true
                    if self.comments.count > 0 {
                        for comment in self.comments {
                            comment.loadMedia(completionHandler: { comment in
                                lock(obj: self.commentLoadCount! as AnyObject, blk: {
                                    self.commentLoadCount! -= 1
                                })
                                if self.commentLoadCount ?? 0 <= 0 {
                                    completionHandler?(self)
                                }
                            })
                        }
                    } else {
                        completionHandler?(self)
                    }
                }
            } else {
                let filename = String(mediaId!) + ".mp4"
                var fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                fileUrl.appendPathComponent(filename)
                if !FileManager.default.fileExists(atPath: fileUrl.path) {
                    Networker.shared.downloadVideo(fileUrl: fileUrl, url: self.mediaUrl, completionHandler: { url, response in
                        print("video download done")
                        self.videoFileUrl = url
                        self.mediaReady = true
                        if self.comments.count > 0 {
                            for comment in self.comments {
                                comment.loadMedia(completionHandler: { comment in
                                    lock(obj: self.commentLoadCount! as AnyObject, blk: {
                                        self.commentLoadCount! -= 1
                                    })
                                    if self.commentLoadCount ?? 0 <= 0 {
                                        completionHandler?(self)
                                    }
                                })
                            }
                        } else {
                            completionHandler?(self)
                        }
                    })
                } else {
                    self.videoFileUrl = fileUrl
                    self.mediaReady = true
                    if self.comments.count > 0 {
                        for comment in self.comments {
                            comment.loadMedia(completionHandler: { comment in
                                lock(obj: self.commentLoadCount! as AnyObject, blk: {
                                    self.commentLoadCount! -= 1
                                })
                                if self.commentLoadCount ?? 0 <= 0 {
                                    completionHandler?(self)
                                }
                            })
                        }
                    } else {
                        completionHandler?(self)
                    }
                }
            }
        } else {
            if self.comments.count > 0 {
                for comment in self.comments {
                    comment.loadMedia(completionHandler: { comment in
                        lock(obj: self.commentLoadCount! as AnyObject, blk: {
                            self.commentLoadCount! -= 1
                        })
                        if self.commentLoadCount ?? 0 <= 0 {
                            completionHandler?(self)
                        }
                    })
                }
            } else {
                completionHandler?(self)
            }
        }
    }
    
}
