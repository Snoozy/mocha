//
//  MediaView.swift
//  Marble
//
//  Created by Daniel Li on 2/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class MediaCaptionView: UIView, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    lazy var textCaptionView: TextCaptionView = {
        return TextCaptionView()
    }()
    
    lazy var drawCaptionView: DrawCaptionView = {
        return DrawCaptionView()
    }()
    
    func configure() {
        textCaptionView.frame = self.frame
        textCaptionView.bounds = self.bounds
        drawCaptionView.frame = self.frame
        drawCaptionView.bounds = self.bounds
        
        textCaptionView.configure()
        drawCaptionView.configure()
        
        textCaptionView.isUserInteractionEnabled = true
        drawCaptionView.isUserInteractionEnabled = false
        isUserInteractionEnabled = true
        addSubview(textCaptionView)
        addSubview(drawCaptionView)
    }
    
    func clearCaption() {
        textCaptionView.clearCaption()
    }
    
    func isEmpty() -> Bool {
        return textCaptionView.isEmpty()
    }
    
    func textBecomeFirstResponder() {
        textCaptionView.caption.becomeFirstResponder()
    }
    
    func textResignFirstResponder() {
        textCaptionView.caption.resignFirstResponder()
    }
    
}
