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
    
    func uploadImage(image: UIImage, groupIds: Array<Int>, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let data = UIImagePNGRepresentation(image)!
        
        var groupIds = groupIds
        
        if groupIds.count <= 0 {
            return
        }
        
        var groupStr = String(groupIds[0])
        groupIds.remove(at: 0)
        for id in groupIds {
            groupStr += "," + String(id)
        }
        
        self.sessionManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(groupStr.data(using: .utf8, allowLossyConversion: false)!, withName: "group_ids")
                multipartFormData.append(data, withName: "media", fileName: "media.png", mimeType: "image/png")
            },
            to: Router.Upload,
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
