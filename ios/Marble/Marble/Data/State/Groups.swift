//
//  Groups.swift
//  Marble
//
//  Created by Daniel Li on 2/9/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation

extension State {
    
    func refreshUserGroups(completionHandler: (() -> Void)? = nil) {
        Networker.shared.listGroups(completionHandler: { response in
            switch response.result {
            case .success:
                let json = response.result.value as! [String : Any]
                let groupsJson = JSON.init(parseJSON: json["groups"] as! String)
                for group in groupsJson {
                    State.shared.addGroup(group: Group(name: group.1["name"].stringValue, id: group.1["group_id"].int!))
                }
                completionHandler?()
            case .failure:
                print(response.debugDescription)
            }
        })
    }
    
    func addGroup(group: Group) {
        if !checkGroupExists(id: group.groupId!) {
            self.userGroups.append(group)
        }
    }
    
    func findGroupBy(id: Int) -> Group? {
        for g in userGroups {
            if g.groupId == id {
                return g
            }
        }
        return nil
    }
    
    private func checkGroupExists(id: Int) -> Bool {
        for group in self.userGroups {
            if group.groupId! == id {
                return true
            }
        }
        return false
    }
    
}
