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
    
    var mediaUrl: String?
    var posterName: String?
    var media: UIImage?
    var mediaReady: Bool = false
    var timestamp: Int64
    
    init(url: String, name: String, time: Int64) {
        self.mediaUrl = url
        self.posterName = name
        self.timestamp = time
    }
    
    func loadMedia(completionHandler: ((Story) -> Void)? = nil) {
        if !self.mediaReady {
            let urlReq = URLRequest(url: URL(string: self.mediaUrl!)!)
            Networker.shared.imageDownloader.download(urlReq) { response in
                let screenBounds = UIScreen.main.bounds
                self.media = response.result.value
                self.media?.af_inflate()
                self.media = self.media?.af_imageScaled(to: CGSize(width: screenBounds.width + 2, height: screenBounds.height + 2))
                self.mediaReady = true
                completionHandler?(self)
            } 
        } else {
            completionHandler?(self)
        }
    }
    
}
