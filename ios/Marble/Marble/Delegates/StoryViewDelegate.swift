//
//  ClipViewDelegate.swift
//  Marble
//
//  Created by Daniel Li on 1/12/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation

protocol ClipViewDelegate {
    
    func nextClip(_ storyView: ClipView) -> Clip?
    
    func prevClip(_ storyView: ClipView) -> Clip?
    
}
