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
    case ClipUpload
    case ClipLike
    case ClipUnlike
    case VlogUpload
    case CommentUpload
    case JoinGroup
    case LeaveGroup
    case CreateGroup
    case GroupInfo
    case ListGroups
    case FindGroup
    case GetClips
    case ClipSeen
    case Block
    case FlagClip
    case GetMemories
    case Search
    case TrendingGroups
    case GetVlogs
    case VlogNewComment
    case VlogComments
    
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
            case .ClipUpload:
                return "/clip/upload"
            case .ClipLike:
                return "/clip/like"
            case .ClipUnlike:
                return "/clip/unlike"
            case .VlogUpload:
                return "/vlog/upload"
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
            case .GetClips:
                return "/clips"
            case .ClipSeen:
                return "/clips/seen"
            case .Block:
                return "/users/block"
            case .FlagClip:
                return "/clips/flag"
            case .GroupInfo:
                return "/groups/info"
            case .GetMemories:
                return "/memories"
            case .Search:
                return "/search"
            case .TrendingGroups:
                return "/groups/trending"
            case .GetVlogs:
                return "/vlogs"
            case .VlogNewComment:
                return "/vlog/new_comment"
            case .VlogComments:
                return "/vlog/comments"
            }
        }()
        
        return URL(string: Constants.ApiUrl + "/\(versionNum)" + path)!
    }
    
}
