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
    case ImageUpload
    case VideoUpload
    case CommentUpload
    case JoinGroup
    case LeaveGroup
    case CreateGroup
    case GroupInfo
    case ListGroups
    case FindGroup
    case GetStories
    case StorySeen
    case Block
    case FlagStory
    case GetMemories
    case SaveMemory
    case RemoveMemory
    case Search
    case TrendingGroups
    
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
            case .ImageUpload:
                return "/image/upload"
            case .VideoUpload:
                return "/video/upload"
            case .CommentUpload:
                return "/comment/upload"
            case .JoinGroup:
                return "/groups/join"
            case .LeaveGroup:
                return "/groups/leave"
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
            case .FlagStory:
                return "/stories/flag"
            case .GroupInfo:
                return "/groups/info"
            case .GetMemories:
                return "/memories"
            case .SaveMemory:
                return "/memories/save"
            case .RemoveMemory:
                return "/memories/remove"
            case .Search:
                return "/search"
            case .TrendingGroups:
                return "/groups/trending"
            }
        }()
        
        return URL(string: Constants.ApiUrl + "/\(versionNum)" + path)!
    }
    
}
