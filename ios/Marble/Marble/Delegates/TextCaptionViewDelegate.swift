//
//  TextCaptionViewDelegate.swift
//  Marble
//
//  Created by Daniel Li on 11/12/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation


protocol TextCaptionViewDelegate {
    
    func editingStarted(_ textCaptionView: TextCaptionView)
    
    func editingStopped(_ textCaptionView: TextCaptionView)
    
}
