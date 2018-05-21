//
//  MemoriesNetworker.swift
//  Marble
//
//  Created by Daniel Li on 12/8/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func getMemories(completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.sessionManager.request(Router.GetMemories).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func saveMemory(clipId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "clip_id" : clipId
        ]
        self.sessionManager.request(Router.SaveMemory, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func removeMemory(clipId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "clip_id" : clipId
        ]
        self.sessionManager.request(Router.RemoveMemory, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
