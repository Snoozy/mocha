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
    
    // MARK: - Lifecycle
    
    lazy var drawView: UIImageView = {
        return UIImageView()
    }()
    
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
    
    func configure() {
        clearCaption()
        caption.spellCheckingType = .no
        
        addSubview(caption)
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        pinchRecognizer.delegate = self
        rotatedRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(rotatedRecognizer)
        addGestureRecognizer(pinchRecognizer)
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        
        prevCaptionPoint.x = center.x
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func isEmpty() -> Bool {
        return caption.text == ""
    }
    
    private var lastPoint = CGPoint.zero
    private var brushWidth: CGFloat = 10.0
    private var opacity: CGFloat = 1.0
    private var swiped = false
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        drawView.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(.round)
        context!.setLineWidth(brushWidth)
        context?.setStrokeColor(Constants.Colors.MarbleBlue.cgColor)
        context?.setBlendMode(.normal)
        
        context?.strokePath()
        
        drawView.image = UIGraphicsGetImageFromCurrentImageContext()
        drawView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    
    private var prevCaptionPoint: CGPoint = CGPoint.zero
    
    @objc internal func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            prevCaptionPoint = caption.center
            keyboardLastHeight = keyboardHeight
            changeCaptionPoint(point: CGPoint(x: center.x, y: (bounds.height - keyboardHeight) - (caption.frame.height/2)))
            if prevCaptionPoint == .zero {
                self.prevCaptionPoint = captionCenter
            }
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
        
        styleLayer(layer: textField.layer)
        
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
        caption.bounds = CGRect(origin: CGPoint.zero, size: captionSize)
        caption.center = CGPoint(x: captionCenter.x, y: captionCenter.y)
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
        let size = CGSize(width: tightSize.width, height: tightSize.height + 15)
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
        changeCaptionPoint(point: prevCaptionPoint)
        caption.transform = CGAffineTransform(scaleX: lastScale, y: lastScale)
    }
    
    // MARK: - Gestures
    
    private lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    private lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    private lazy var rotatedRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotated(_:)))
    private lazy var pinchRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(captionPinched(_:)))
    
    @objc internal func tapped(_ sender: UIPanGestureRecognizer) {
        if caption.isFirstResponder {
            resignEditingCaption()
        } else {
            caption.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            caption.becomeFirstResponder()
            caption.isHidden = false
        }
    }
    
    private var lastFontSize: CGFloat = 30
    private var lastScale: CGFloat = 1.0
    
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
            if !caption.frame.contains(gesture.location(in: self)) {
                return
            }
            self.caption.transform = caption.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        }
    }
    
    @objc internal func rotated(_ sender: UIRotationGestureRecognizer) {
        if caption.isFirstResponder {
            return
        }
        if !caption.frame.contains(sender.location(in: self)) {
            return
        }
        
        if sender.state == .began || sender.state == .changed {
        let transform = caption.transform.rotated(by: sender.rotation)
            caption.transform = transform
            sender.rotation = 0.0
        }
    }
    
    @objc internal func panned(_ sender: UIPanGestureRecognizer) {
        if caption.isFirstResponder {
            return
        }
        let translation = sender.translation(in: self)
        let location = sender.location(in: self)
        if !caption.frame.contains(location) {
            return
        }
        changeCaptionPoint(point: CGPoint(x: captionCenter.x + translation.x, y: captionCenter.y + translation.y))
        sender.setTranslation(.zero, in: self)
    }
    
}
