//
//  Router.swift
//  Marble
//
//  Created by Daniel Li on 1/25/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire


enum Router : URLConvertible {
    
    // GET requests
    case Ping
    
    // POST requests
    case SignUp
    case Login
    case Upload
    case JoinGroup
    case CreateGroup
    case ListGroups
    case FindGroup
    case GetStories
    case StorySeen
    case Block
    
    func asURL() throws -> URL {
        let versionNum = "v1"
        
        let path: String = {
            switch self {
            case .Ping:
                return "/ping"
            case .SignUp:
                return "/signup"
            case .Login:
                return "/login"
            case .Upload:
                return "/upload"
            case .JoinGroup:
                return "/groups/join"
            case .CreateGroup:
                return "/groups/create"
            case .ListGroups:
                return "/groups/list"
            case .FindGroup:
                return "/groups/find"
            case .GetStories:
                return "/stories"
            case .StorySeen:
                return "/stories/seen"
            case .Block:
                return "/users/block"
            }
        }()
        
        return URL(string: Constants.ApiUrl + "/\(versionNum)" + path)!
    }
    
}
