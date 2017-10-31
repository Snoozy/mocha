//
//  DrawCaptionView.swift
//  Marble
//
//  Created by Daniel Li on 10/30/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit


class DrawCaptionView: UIView, UIGestureRecognizerDelegate {
    
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
    
    var drawView: SwiftyDrawView?
    
    func configure() {
        drawView = SwiftyDrawView(frame: self.frame)
        addSubview(drawView!)
        
        panRecognizer.delegate = self
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(panRecognizer)
        isUserInteractionEnabled = true
    }
    
    private lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    private lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    
    @objc internal func panned(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            drawView?.beginTouches(point: gesture.location(in: self))
        } else if gesture.state == .changed {
            drawView?.movedTouches(point: gesture.location(in: self))
        }
    }
    
    @objc internal func tapped(_ gesture: UIPanGestureRecognizer) {
        drawView?.beginTouches(point: gesture.location(in: self))
    }
    
}
