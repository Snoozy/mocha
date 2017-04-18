//
//  Downloader.swift
//  Marble
//
//  Created by Daniel Li on 4/18/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func downloadVideo(fileUrl: URL, url: String, completionHandler: @escaping (URL ,DefaultDownloadResponse) -> ()) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileUrl, [.removePreviousFile])
        }
        self.sessionManager.download(url, to: destination).response(completionHandler: { response in
            print(response)
            if let fileUrl = response.destinationURL {
                completionHandler(fileUrl, response)
            }
        })
    }
    
}
