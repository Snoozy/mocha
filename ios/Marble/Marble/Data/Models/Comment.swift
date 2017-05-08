//
//  Comment.swift
//  Marble
//
//  Created by Daniel Li on 4/25/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class Comment: Equatable {
    let id: Int
    let mediaUrl: String
    let posterName: String
    let timestamp: Int64
    let userId: Int
    
    var image: UIImage?
    var mediaReady: Bool = false
    
    init(id: Int, mediaUrl: String, posterName: String, timestamp: Int64, userId: Int) {
        self.id = id
        self.mediaUrl = mediaUrl
        self.posterName = posterName
        self.timestamp = timestamp
        self.userId = userId
    }
    
    func loadMedia(completionHandler: ((Comment) -> Void)? = nil) {
        if !self.mediaReady {
            let urlReq = URLRequest(url: URL(string: self.mediaUrl)!)
            let mediaId = mediaUrl.components(separatedBy: "/").last
            let filename = String(mediaId!) + ".png"
            var fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            fileUrl.appendPathComponent(filename)
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                Networker.shared.imageDownloader.download(urlReq) { response in
                    let screenBounds = UIScreen.main.bounds
                    self.image = response.result.value
                    self.image?.af_inflate()
                    self.image = self.image?.af_imageScaled(to: CGSize(width: screenBounds.width, height: screenBounds.height))
                    self.mediaReady = true
                    if let img = self.image {
                        let data = UIImagePNGRepresentation(img)
                        try? data?.write(to: fileUrl)
                    }
                    completionHandler?(self)
                }
            } else {
                print("image cached")
                let image = try? UIImage(data: Data(contentsOf: fileUrl))
                self.image = image!
                self.mediaReady = true
                completionHandler?(self)
            }
        } else {
            completionHandler?(self)
        }
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id && lhs.mediaUrl == rhs.mediaUrl
    }
    
}
