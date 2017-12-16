//
//  UIDevice_ext.swift
//  Marble
//
//  Created by Daniel Li on 12/16/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    var isSimulator: Bool {
        #if IOS_SIMULATOR
            return true
        #else
            return false
        #endif
    }
}
