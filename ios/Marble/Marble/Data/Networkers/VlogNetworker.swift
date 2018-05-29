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
        self.sessionManager.request(Router.GetVlogs).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
