//
//  MediaView.swift
//  Marble
//
//  Created by Daniel Li on 2/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class MediaVideoView: UIView, UITextViewDelegate {
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //configure()
    }
    
    func configure() {
        addSubview(caption)
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(panRecognizer)
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    private var prevCaptionHeight: CGFloat?
    
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            prevCaptionHeight = captionCenterY
            keyboardLastHeight = keyboardHeight
            captionCenterY = (bounds.height - keyboardHeight) - (caption.frame.height/2)
            if prevCaptionHeight == CGFloat(0) {
                self.prevCaptionHeight = captionCenterY
            }
        }
    }
    
    private var keyboardLastHeight: CGFloat?
    
    func keyboardDidChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            keyboardLastHeight = keyboardHeight
            if caption.isFirstResponder {
                captionCenterY = (bounds.height - keyboardHeight) - (caption.frame.height/2)
            }
        }
    }
    
    // MARK: - Subviews
    
    private lazy var caption: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        textField.textAlignment = .center
        textField.textColor = .white
        textField.font = .boldSystemFont(ofSize: 30)
        textField.tintColor = .white
        textField.keyboardAppearance = .light
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.layer.shadowOpacity = 0.9
        textField.layer.shadowRadius = 2.0
        textField.returnKeyType = .done
        textField.isScrollEnabled = false
        textField.delegate = self
        textField.textContainer.lineBreakMode = .byWordWrapping
        
        let pinchGest = UIPinchGestureRecognizer(target: self, action: #selector(captionPinched(_:)))
        textField.addGestureRecognizer(pinchGest)
        textField.isUserInteractionEnabled = true
        
        return textField
    }()
    
    var lastFontSize: CGFloat = 30
    
    func captionPinched(_ gesture: UIPinchGestureRecognizer) {
        if caption.isFirstResponder {
            return
        }
        let scale = gesture.scale
        let size = min(max(lastFontSize * scale, 10), 80)
        caption.font = caption.font?.withSize(size)
        if gesture.state == .ended {
            lastFontSize = size
        }
        textViewDidChange(caption)
    }
    
    private var captionCenterY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    func clearCaption() {
        self.caption.isHidden = true
        caption.text = ""
    }
    
    var captionInternalHeight: CGFloat?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let captionSize = CGSize(width: bounds.size.width, height: captionInternalHeight ?? 50)
        caption.bounds = CGRect(origin: CGPoint.zero, size: captionSize)
        caption.center = CGPoint(x: center.x, y: captionCenterY)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: bounds.size.width, height: .infinity))
        textView.bounds.size = size
        if size.height != captionInternalHeight {
            captionCenterY = (bounds.height - (keyboardLastHeight ?? 0)) - (caption.frame.height/2)
        }
        captionInternalHeight = size.height
        layoutSubviews()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            captionCenterY = prevCaptionHeight!
            return false
        }
        return true
    }
    
    // MARK: - Gestures
    
    private lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    private lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    
    @objc private func tapped(_ sender: UIPanGestureRecognizer) {
        if caption.isFirstResponder {
            caption.resignFirstResponder()
            caption.isHidden = caption.text?.isEmpty ?? true
            captionCenterY = prevCaptionHeight!
        } else {
            caption.becomeFirstResponder()
            caption.isHidden = false
        }
    }
    
    @objc private func panned(_ sender: UIPanGestureRecognizer) {
        if caption.isFirstResponder {
            return
        }
        let location = sender.location(in: self)
        if !caption.frame.contains(location) {
            return
        }
        captionCenterY = location.y
    }
    
}
