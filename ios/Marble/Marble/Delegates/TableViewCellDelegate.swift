//
//  TableViewCellDelegate.swift
//  Marble
//
//  Created by Daniel Li on 9/16/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewCellDelegate {
    func tableViewCell(singleTapActionDelegatedFrom cell: UITableViewCell)
    func tableViewCell(doubleTapActionDelegatedFrom cell: UITableViewCell)
}
