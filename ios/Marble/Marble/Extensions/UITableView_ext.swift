//
//  UITableView_ext.swift
//  Marble
//
//  Created by Daniel Li on 9/24/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    var tableView: UITableView? {
        var view = self.superview
        while (view != nil && view!.isKind(of: UITableView.self) == false) {
            view = view!.superview
        }
        return view as? UITableView
    }
}
