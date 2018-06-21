//
//  MemoriesNetworker.swift
//  Marble
//
//  Created by Daniel Li on 12/8/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func getMemories(completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.sessionManager.request(Router.GetMemories).validate().responseJSON(completionHandler: completionHandler)
    }
        
}
