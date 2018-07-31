//
//  JoinGroupDeepLink.swift
//  Marble
//
//  Created by Daniel Li on 7/23/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation

struct JoinGroupDeepLink: DeepLink {
    
    // Format: marble://groups/join?code=<x>
    
    static let template = DeepLinkTemplate()
        .term("groups")
        .term("join")
        .queryStringParameters([
            .requiredString(named: "code")
            ])
    
    let groupCode: String
    
    init(values: DeepLinkValues) {
        groupCode = values.query["code"] as! String
    }
    
}
