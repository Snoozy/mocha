//
//  TextCaptionView.swift
//  Marble
//
//  Created by Daniel Li on 10/30/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

class TextCaptionView: UIView, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Lifecycle
    
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

    var mediaCaptionScrollView: UIScrollView!
    
    var delegate: TextCaptionViewDelegate?
    
    lazy var captionWrapperView: UIView = {
        return UIView()
    }()
    
    func configure() {
        clearCaption()
        caption.spellCheckingType = .no
        
        captionWrapperView.frame = caption.frame
        captionWrapperView.bounds = caption.bounds
        captionWrapperView.addSubview(caption)
        
        panRecognizer.delegate = self
        pinchRecognizer.delegate = self
        rotatedRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(rotatedRecognizer)
        addGestureRecognizer(pinchRecognizer)
        captionWrapperView.isUserInteractionEnabled = true
        
        addSubview(captionWrapperView)
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func isEmpty() -> Bool {
        return caption.text == ""
    }
    
    private var prevCaptionPoint: CGPoint?
    
    @objc internal func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let point = CGPoint(x: center.x, y: (bounds.height - keyboardHeight) - (caption.frame.height/2))
            if prevCaptionPoint != nil {
                prevCaptionPoint = captionWrapperView.center
            }
            keyboardLastHeight = keyboardHeight
            changeCaptionPoint(point: point)
        }
    }
    
    private var keyboardLastHeight: CGFloat?
    
    @objc internal func keyboardDidChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            keyboardLastHeight = keyboardHeight
            if caption.isFirstResponder {
                changeCaptionPoint(point: CGPoint(x: center.x, y: (bounds.height - keyboardHeight) - (caption.frame.height/2)))
            }
        }
    }
    
    // MARK: - Subviews
    
    lazy var caption: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        textField.textAlignment = .center
        textField.textColor = .white
        textField.font = .boldSystemFont(ofSize: 30)
        textField.tintColor = .white
        textField.keyboardAppearance = .light
        textField.isScrollEnabled = false
        
        styleLayer(layer: textField.layer)
        
        textField.textContainer.size = UIScreen.main.bounds.size
        
        textField.returnKeyType = .done
        textField.isScrollEnabled = false
        textField.delegate = self
        textField.textContainer.lineBreakMode = .byWordWrapping
        textField.clipsToBounds = false
        textField.layer.masksToBounds = false
        
        return textField
    }()
    
    private var captionCenter: CGPoint = CGPoint.zero
    
    private func changeCaptionPoint(point: CGPoint) {
        captionCenter = point
        setNeedsLayout()
    }
    
    func clearCaption() {
        self.caption.isHidden = true
        caption.text = ""
    }
    
    var captionInternalHeight: CGFloat?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let captionSize = CGSize(width: bounds.size.width, height: captionInternalHeight ?? 50)
        captionWrapperView.bounds = CGRect(origin: CGPoint.zero, size: captionSize)
        caption.bounds = CGRect(origin: CGPoint.zero, size: captionSize)
        caption.center = CGPoint(x: bounds.size.width/2, y: captionSize.height/2)
        captionWrapperView.center = CGPoint(x: captionCenter.x, y: captionCenter.y)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        layoutCaption()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.backgroundColor = UIColor.clear
    }
    
    internal func textViewDidChange(_ textView: UITextView) {
        layoutCaption()
    }
    
    private func layoutCaption() {
        let tightSize = caption.sizeThatFits(CGSize(width: bounds.size.width, height: .infinity))
        let size = CGSize(width: tightSize.width, height: tightSize.height + 10)
        captionWrapperView.bounds.size = size
        caption.bounds.size = size
        if size.height != captionInternalHeight {
            changeCaptionPoint(point: CGPoint(x: captionCenter.x, y: (bounds.height - (keyboardLastHeight ?? 0)) - (caption.frame.height/2)))
        }
        captionInternalHeight = size.height
        layoutSubviews()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            resignEditingCaption()
            return false
        }
        return true
    }
    
    func resignEditingCaption() {
        caption.resignFirstResponder()
        caption.isHidden = caption.text?.isEmpty ?? true
        if prevCaptionPoint == nil {
            prevCaptionPoint = CGPoint(x: center.x, y: bounds.height - ( keyboardLastHeight ?? center.y))
        }
        changeCaptionPoint(point: prevCaptionPoint!)
        captionWrapperView.transform = lastTransform
        delegate?.editingStopped(self)
    }
    
    func startEditingCaption() {
        lastTransform = captionWrapperView.transform
        captionWrapperView.transform = CGAffineTransform.identity
        caption.becomeFirstResponder()
        caption.isHidden = false
        delegate?.editingStarted(self)
    }
    
    // MARK: - Gestures
    
    private lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    private lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    private lazy var rotatedRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotated(_:)))
    private lazy var pinchRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(captionPinched(_:)))
    
    @objc internal func tapped(_ gesture: UIPanGestureRecognizer) {
        if caption.isFirstResponder {
            resignEditingCaption()
        } else {
            startEditingCaption()
        }
    }
    
    private var lastFontSize: CGFloat = 30
    private var lastTransform: CGAffineTransform = CGAffineTransform.identity
    
    @objc internal func captionPinched(_ gesture: UIPinchGestureRecognizer) {
        if caption.isFirstResponder {
            let scale = gesture.scale
            let size = min(max(lastFontSize * scale, 10), 250)
            caption.font = caption.font?.withSize(size)
            if gesture.state == .ended {
                lastFontSize = size
            }
            textViewDidChange(caption)
        } else {
            if !captionWrapperView.frame.contains(gesture.location(in: self)) {
                return
            }
            if gesture.state == .began || gesture.state == .changed {
                captionWrapperView.transform = captionWrapperView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
                gesture.scale = 1.0
            }
        }
    }
    
    @objc internal func rotated(_ gesture: UIRotationGestureRecognizer) {
        if caption.isFirstResponder {
            return
        }
        if !captionWrapperView.frame.contains(gesture.location(in: self)) {
            return
        }
        if gesture.state == .began || gesture.state == .changed {
            captionWrapperView.transform = captionWrapperView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0.0
        }
    }
    
    @objc internal func panned(_ gesture: UIPanGestureRecognizer) {
        if caption.isFirstResponder {
            return
        }
        if !captionWrapperView.frame.contains(gesture.location(in: self)) {
            return
        }
        let translation = gesture.translation(in: self)
        changeCaptionPoint(point: CGPoint(x: captionCenter.x + translation.x, y: captionCenter.y + translation.y))
        gesture.setTranslation(.zero, in: self)
    }
    
}

