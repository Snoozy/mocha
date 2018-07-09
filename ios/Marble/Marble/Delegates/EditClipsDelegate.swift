//
//  EditClipDelegate.swift
//  Marble
//
//  Created by Daniel Li on 7/6/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

protocol EditClipsDelegate {
    
    func videoExportDone(_ editClipsVC: EditClipsVC)
    
    func videoUploadDone(_ editClipsVC: EditClipsVC)
    
}

extension EditClipsDelegate {
    
    func videoExportDone(_ editClipsVC: EditClipsVC) {}
    
    func videoUploadDone(_ editClipsVC: EditClipsVC) {}
    
}
