//
//  Networker.swift
//  Marble
//
//  Created by Daniel Li on 1/26/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class Networker : NSObject {
    
    static let shared = Networker()
    
    let sessionManager = SessionManager()
    
    override init() {
        let authHandler = AuthorizationHandler()
        sessionManager.adapter = authHandler
        sessionManager.retrier = authHandler
    }
    
}

class AuthorizationHandler : RequestAdapter, RequestRetrier {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        urlRequest.setValue(KeychainWrapper.authToken(), forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            print("token:  " + KeychainWrapper.authToken()!)
            completion(false, 0.0)
            OperationQueue.main.addOperation {
                UIApplication.topViewController()?.present(UIStoryboard(name:"Auth", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
            }
        } else {
            completion(false, 0.0)
        }
    }
    
}
