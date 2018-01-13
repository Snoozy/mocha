//
//  StoryViewDelegate.swift
//  Marble
//
//  Created by Daniel Li on 1/12/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import Foundation


protocol StoryViewDelegate {
    
    func nextStory(_ storyView: StoryView) -> Story?
    
    func prevStory(_ storyView: StoryView) -> Story?
    
}
