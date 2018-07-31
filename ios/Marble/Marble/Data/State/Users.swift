//
//  Users.swift
//  Marble
//
//  Created by Daniel Li on 4/10/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK

extension State {
    
    func blockUser(userId: Int, completionHandler: (() -> Void)? = nil) {
        Networker.shared.blockUser(blockeeId: userId, completionHandler: { response in
            switch response.result {
            case .success(let val):
                let json = JSON(val)
                if json["status"].int ?? 1 == 0 {
                    for (id, stories) in self.groupClips {
                        self.groupClips[id] = stories.filter({
                            print("asdfasdf")
                            return $0.userId != userId
                        })
                        print(self.groupClips[id] ?? "error")
                    }
                }
                completionHandler?()
            case .failure(let val):
                print(response.debugDescription)
                Flurry.logError("Failed_Api_Request", message: response.debugDescription, error: val)
            }
        })
    }
    
    func ping(deviceToken: String?) {
        Networker.shared.ping(deviceToken: deviceToken, completionHandler: { response in
            switch response.result {
            case .success(let val):
                let json = JSON(val)
                print(json)
                self.me = User(id: json["user_id"].intValue, username: json["username"].stringValue, name: json["name"].stringValue)
            case .failure(let val):
                let json = JSON(response.data!)
                if let msg = json["error"].string {
                    let alertController = UIAlertController(title: msg, message: "", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        
                    }
                    alertController.addAction(OKAction)
                    UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
                } else {
                    print(response.debugDescription)
                    Flurry.logError("Failed_Api_Request", message: response.debugDescription, error: val)
                }
            }
        })
    }
    
}
