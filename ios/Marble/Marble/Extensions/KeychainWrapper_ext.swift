//
//  KeychainWrapperExt.swift
//  Marble
//
//  Created by Daniel Li on 1/23/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

private let authTokenString: String = "auth_token"
private let userString: String = "user_id"

extension KeychainWrapper {
    
    class func authToken() -> String? {
        return KeychainWrapper.standard.string(forKey: authTokenString)
    }
    
    class func userID() -> Int? {
        return KeychainWrapper.standard.integer(forKey: userString)
    }
    
    class func clearAuthToken() -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: authTokenString)
    }
    
    class func clearUserID() -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: userString)
    }
    
    class func setAuthToken(token: String) -> Bool {
        return KeychainWrapper.standard.set(token, forKey: authTokenString)
    }
    
    class func setUserID(id: Int) -> Bool {
        return KeychainWrapper.standard.set(id, forKey: userString)
    }
    
    class func hasAuthAndUser() -> Bool {
        return KeychainWrapper.authToken() != nil && KeychainWrapper.userID() != nil
    }
    
}
