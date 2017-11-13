//
//  MediaView.swift
//  Marble
//
//  Created by Daniel Li on 2/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class MediaCaptionView: UIView, TextCaptionViewDelegate {
    
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
    
    lazy var undoButton: UIButton = {
        let undoButton = UIButton(type: .system)
        undoButton.setImage(UIImage(named: "reload"), for: .normal)
        undoButton.addTarget(self, action: #selector(undoButtonTouch(btn:)), for: .touchUpInside)
        undoButton.isHidden = true
        self.addSubview(undoButton)
        
        undoButton.tintColor = .white
        styleLayer(layer: undoButton.layer)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        return undoButton
    }()
    
    lazy var drawButton: UIButton = {
        let drawButton = UIButton(type: .system)
        drawButton.setImage(UIImage(named: "pencil"), for: .normal)
        drawButton.addTarget(self, action: #selector(drawButtonTouch(btn:)), for: .touchUpInside)
        
        drawButton.tintColor = .white
        drawButton.layer.cornerRadius = 4
        drawButton.layer.borderWidth = 2
        drawButton.layer.borderColor = UIColor.white.cgColor
        drawButton.backgroundColor = .clear
        styleLayer(layer: drawButton.layer)
        
        drawButton.translatesAutoresizingMaskIntoConstraints = false
        return drawButton
    }()
    var colorSlider: ColorSlider = {
        let colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        colorSlider.color = .white
        colorSlider.isHidden = true
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
        return colorSlider
    }()
    
    var configured: Bool = false
    
    func configure() {
        drawCaptionView.drawView?.clearCanvas()
        textCaptionView.clearCaption()
        
        textCaptionView.frame = self.frame
        textCaptionView.bounds = self.bounds
        drawCaptionView.frame = self.frame
        drawCaptionView.bounds = self.bounds
        
        if configured {
            colorSlider.color = .white
            stopDrawing()
            return
        }
        
        configured = true
        
        textCaptionView.delegate = self
        
        textCaptionView.configure()
        drawCaptionView.configure()
        
        textCaptionView.isUserInteractionEnabled = true
        drawCaptionView.isUserInteractionEnabled = false
        isUserInteractionEnabled = true
        addSubview(drawCaptionView)
        addSubview(textCaptionView)

        self.addSubview(drawButton)
        self.addSubview(undoButton)
        self.addSubview(colorSlider)
        
        NSLayoutConstraint.activate([
            undoButton.centerXAnchor.constraint(equalTo: drawButton.centerXAnchor),
            undoButton.topAnchor.constraint(equalTo: drawButton.bottomAnchor, constant: 15),
            undoButton.widthAnchor.constraint(equalToConstant: 25),
            undoButton.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        NSLayoutConstraint.activate([
            drawButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            drawButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 85),
            drawButton.widthAnchor.constraint(equalToConstant: 35),
            drawButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            colorSlider.centerXAnchor.constraint(equalTo: drawButton.centerXAnchor),
            colorSlider.topAnchor.constraint(equalTo: undoButton.bottomAnchor, constant: 25),
            colorSlider.widthAnchor.constraint(equalToConstant: 12),
            colorSlider.heightAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        drawCaptionView.changeLineColor(slider.color)
    }
    
    @objc func undoButtonTouch(btn: UIButton!) {
        if drawing {
            drawCaptionView.undoLine()
        }
    }
    
    func startDrawing() {
        drawing = true
        drawButton.tintColor = .black
        drawButton.backgroundColor = .white
        textCaptionView.isUserInteractionEnabled = false
        drawCaptionView.isUserInteractionEnabled = true
        undoButton.isHidden = false
        colorSlider.isHidden = false
    }
    
    func stopDrawing() {
        drawing = false
        drawButton.tintColor = .white
        drawButton.backgroundColor = .clear
        textCaptionView.isUserInteractionEnabled = true
        drawCaptionView.isUserInteractionEnabled = false
        undoButton.isHidden = true
        colorSlider.isHidden = true
    }
    
    var drawing: Bool = false
    
    @objc func drawButtonTouch(btn: UIButton!) {
        if !drawing && !textCaptionView.caption.isFirstResponder {
            startDrawing()
        } else {
            stopDrawing()
        }
    }
    
    func clearCaption() {
        textCaptionView.clearCaption()
    }
    
    func isEmpty() -> Bool {
        return textCaptionView.isEmpty() && drawCaptionView.isEmpty()
    }
    
    func textBecomeFirstResponder() {
        textCaptionView.caption.becomeFirstResponder()
    }
    
    func textResignFirstResponder() {
        textCaptionView.caption.resignFirstResponder()
    }
    
    func editingStarted(_ textCaptionView: TextCaptionView) {
        drawButton.isHidden = true
    }
    
    func editingStopped(_ textCaptionView: TextCaptionView) {
        drawButton.isHidden = false
    }
    
    func startEditingTextCaption() {
        textCaptionView.startEditingCaption()
    }
    
    func getCaptionImage() -> UIImage {
        let textCaption = UIImage(view: textCaptionView)
        let drawCaption = UIImage(view: drawCaptionView)
        
        let size = textCaption.size
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        drawCaption.draw(in: areaSize)
        
        textCaption.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        
        let captionImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return captionImage
    }
    
}
