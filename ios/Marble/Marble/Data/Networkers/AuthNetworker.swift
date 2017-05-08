//
//  AuthNetworker.swift
//  Marble
//
//  Created by Daniel Li on 1/26/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func ping(deviceToken: String, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "device_token": deviceToken
        ]
        self.sessionManager.request(Router.Ping, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func signup(name: String, username: String, password: String, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "name" : name,
            "username" : username,
            "password" : password
        ]
        self.sessionManager.request(Router.SignUp, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func login(username: String, password: String, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "username" : username,
            "password" : password
        ]
        
        self.sessionManager.request(Router.Login, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
