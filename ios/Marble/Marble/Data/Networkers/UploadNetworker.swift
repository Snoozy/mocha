//
//  UploadNetworker.swift
//  Marble
//
//  Created by Daniel Li on 1/30/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

extension Networker {
    
    func uploadImage(image: UIImage, caption: UIImage? = nil, groupIds: Array<Int>, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let data = UIImageJPEGRepresentation(image, Constants.ImageJpegCompression)!
        
        var groupIds = groupIds
        
        if groupIds.count <= 0 {
            return
        }
        
        var groupStr = String(groupIds[0])
        groupIds.remove(at: 0)
        for id in groupIds {
            groupStr += "," + String(id)
        }
        
        self.backgroundSesionManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(groupStr.data(using: .utf8, allowLossyConversion: false)!, withName: "group_ids")
                multipartFormData.append(data, withName: "image", fileName: "media.jpg", mimeType: "image/jpeg")
                if let caption = caption {
                    print("captioning")
                    let captionData = UIImagePNGRepresentation(caption)!
                    multipartFormData.append(captionData, withName: "caption", fileName: "caption.png", mimeType: "image/png")
                }
            },
            usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
            to: Router.ImageUpload,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate().responseJSON(completionHandler: completionHandler)
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    func uploadVideo(videoUrl: URL, caption: UIImage? = nil, groupIds: Array<Int>, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        var groupIds = groupIds
        
        if groupIds.count <= 0 {
            return
        }
        
        var groupStr = String(groupIds[0])
        groupIds.remove(at: 0)
        for id in groupIds {
            groupStr += "," + String(id)
        }
        
        self.backgroundSesionManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(groupStr.data(using: .utf8, allowLossyConversion: false)!, withName: "group_ids")
                multipartFormData.append(videoUrl, withName: "video")
                if let caption = caption {
                    print("captioning")
                    let captionData = UIImagePNGRepresentation(caption)!
                    multipartFormData.append(captionData, withName: "caption", fileName: "caption.png", mimeType: "image/png")
                }
            },
            usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
            to: Router.VideoUpload,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate().responseJSON(completionHandler: completionHandler)
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    func uploadComment(image: UIImage, storyId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let imageData = UIImagePNGRepresentation(image)!
        
        let storyIdStr = String(describing: storyId)
        
        self.backgroundSesionManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(storyIdStr.data(using: .utf8, allowLossyConversion: false)!, withName: "story_id")
                multipartFormData.append(imageData, withName: "image", fileName: "image.png", mimeType: "image/png")
            },
            usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
            to: Router.CommentUpload,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate().responseJSON(completionHandler: completionHandler)
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )

    }
    
}
