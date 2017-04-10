//
//  UserNetworker.swift
//  Marble
//
//  Created by Daniel Li on 4/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func blockUser(blockeeId: Int, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        let params: Parameters = [
            "blockee_id": blockeeId
        ]
        self.sessionManager.request(Router.Block, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
