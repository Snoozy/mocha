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
    
    func uploadClip(videoUrl: URL, groupIds: Array<Int>, completionHandler: @escaping (DataResponse<Any>) -> ()) {
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
            },
            usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
            to: Router.ClipUpload,
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
    
    func uploadVlog(videoUrl: URL, description: String, clipIds: [Int], groupId: Int, completionHandler: @escaping(DataResponse<Any>) -> ()) {
        let clipIdsStr = clipIds.map { String($0) }.joined(separator: ",")
        self.backgroundSesionManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(String(groupId).data(using: .utf8, allowLossyConversion: false)!, withName: "group_id")
                multipartFormData.append(clipIdsStr.data(using: .utf8, allowLossyConversion: false)!, withName: "clip_ids")
                multipartFormData.append(description.data(using: .utf8, allowLossyConversion: false)!, withName: "description")
                multipartFormData.append(videoUrl, withName: "video")
        },
            usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
            to: Router.VlogUpload,
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
