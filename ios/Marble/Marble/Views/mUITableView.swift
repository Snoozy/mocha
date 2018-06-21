//
//  mUITableView.swift
//  Marble
//
//  Created by Daniel Li on 6/20/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

class mUITableView : UITableView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
}
