//
//  NumPlaceholderButton.swift
//  Marble
//
//  Created by Daniel Li on 2/2/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class NumPlaceholderButton: UIButton {

    @IBInspectable
    open var emptyColor: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }
    
    open var value: Int?
    
    open func changeValue(to value: Int) {
        self.value = value
        self.setTitle(String(value), for: .normal)
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.clear
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50.0)
        self.frame = frame.offsetBy(dx: -5, dy: 0)
        self.frame.size = CGSize.init(width: 30, height: 20)
    }
    
    open func revertChange() {
        self.value = nil
        self.setTitle(" ", for: .normal)
        layer.borderColor = UIColor.black.cgColor
        backgroundColor = emptyColor
        self.frame = frame.offsetBy(dx: 5, dy: 0)
        self.frame.size = CGSize.init(width: 20, height: 20)
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        layer.cornerRadius = 10
        layer.borderWidth = 1
        backgroundColor = emptyColor
        layer.borderColor = UIColor.black.cgColor
    }

}
