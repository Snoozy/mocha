//
//  StoryNetworker.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension Networker {
    
    func getStories(completionHandler: @escaping (DataResponse<Any>) -> ()) {
        print("network get stories")
        self.sessionManager.request(Router.GetStories).validate().responseJSON(completionHandler: completionHandler)
    }
    
}
