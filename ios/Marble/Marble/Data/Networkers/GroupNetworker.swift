//
//  GroupNetworker.swift
//  Marble
//
//  Created by Daniel Li on 2/2/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
        
    func joinGroup(code: String, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "code": code
        ]
        self.sessionManager.request(Router.JoinGroup, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func leaveGroup(id: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "group_id": id
        ]
        self.sessionManager.request(Router.LeaveGroup, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func groupInfo(id: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "group_id": id
        ]
        self.sessionManager.request(Router.GroupInfo, method: .get, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func createGroupWith(name: String, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "name": name
        ]
        self.sessionManager.request(Router.CreateGroup, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func listGroups(completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.sessionManager.request(Router.ListGroups).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func findGroupBy(code: String, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
        "code": code
        ]
        self.sessionManager.request(Router.FindGroup, method: .get, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
