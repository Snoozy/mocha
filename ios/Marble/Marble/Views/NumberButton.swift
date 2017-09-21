//
//  NumberButton.swift
//  Marble
//
//  Created by Daniel Li on 2/2/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class NumberButton: UIButton {

    @IBInspectable
    open var numValue: String = "1"
    
    @IBInspectable
    open var borderColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    open var borderRadius: CGFloat = 40 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    open var highlightBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
        setupActions()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setupActions()
    }
    
    open override var intrinsicContentSize : CGSize {
        
        return CGSize(width: 80, height: 80)
    }
    
    fileprivate var defaultBackgroundColor = UIColor.clear
    
    fileprivate func setupView() {
        
        layer.borderWidth = 1.5
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.cgColor
        
        if let backgroundColor = backgroundColor {
            
            defaultBackgroundColor = backgroundColor
        }
    }
    
    fileprivate func setupActions() {
        
        addTarget(self, action: #selector(NumberButton.handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(NumberButton.handleTouchUp), for: [.touchUpInside, .touchDragOutside, .touchCancel])
    }
    
    @objc func handleTouchDown() {
        
        animateBackgroundColor(highlightBackgroundColor)
    }
    
    @objc func handleTouchUp() {
        
        animateBackgroundColor(defaultBackgroundColor)
    }
    
    fileprivate func animateBackgroundColor(_ color: UIColor) {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                
                self.backgroundColor = color
        },
            completion: nil
        )
    }
    

}
