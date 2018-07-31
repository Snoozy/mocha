//
//  VlogNetworker.swift
//  Marble
//
//  Created by Daniel Li on 5/24/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func getVlogs(completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.sessionManager.request(Router.GetVlogs).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func getVlogs(afterId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "after_id": afterId
        ]
        self.sessionManager.request(Router.GetVlogs, method: .get, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func getVlogComments(vlogId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "vlog_id": vlogId
        ]
        self.sessionManager.request(Router.VlogComments, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func postComment(vlogId: Int, content: String, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "vlog_id": vlogId,
            "comment_content": content
        ]
        self.sessionManager.request(Router.VlogNewComment, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func vlogViewed(vlogId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "vlog_id": vlogId
        ]
        self.sessionManager.request(Router.VlogViewed, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
