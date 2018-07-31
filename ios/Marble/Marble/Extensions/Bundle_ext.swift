//
//  Bundle_ext.swift
//  Marble
//
//  Created by Daniel Li on 7/18/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
