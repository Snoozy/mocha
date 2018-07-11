//
//  EditClipDelegate.swift
//  Marble
//
//  Created by Daniel Li on 7/6/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

protocol EditVlogDelegate {
    
    func videoExportDone(_ editVlogVC: EditVlogVC)
    
    func videoUploadDone(_ editVlogVC: EditVlogVC)
    
}

extension EditVlogDelegate {
    
    func videoExportDone(_ editVlogVC: EditVlogVC) {}
    
    func videoUploadDone(_ editVlogVC: EditVlogVC) {}
    
}
