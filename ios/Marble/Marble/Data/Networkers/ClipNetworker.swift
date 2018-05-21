//
//  ClipNetworker.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func getClips(completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.sessionManager.request(Router.GetClips).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func clipSeen(groupId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "group_id" : groupId
        ]
        self.sessionManager.request(Router.ClipSeen, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func flagClip(clipId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "clip_id" : clipId
        ]
        self.sessionManager.request(Router.FlagClip, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
