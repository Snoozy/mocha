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
    
    func getTrendingGroups(completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.sessionManager.request(Router.TrendingGroups, method: .get, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func searchGroups(query: String, completionHandler: @escaping ([Group]) -> ()) {
        let params: Parameters = [
            "query": query
        ]
        self.sessionManager.request(Router.Search, method: .get, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let val):
                let json = JSON(val)
                print(json)
                var groups = [Group]()
                if let gJson = json["results"].array {
                    for g in gJson {
                        groups.append(Group(name: g["name"].stringValue, id: g["group_id"].intValue, lastSeen: g["last_seen"].int64Value, members: g["members"].int ?? 1, code: String(g["code"].intValue)))
                    }
                    completionHandler(groups)
                }
            case .failure:
                print(response.debugDescription)
            }
        })
    }
    
}
