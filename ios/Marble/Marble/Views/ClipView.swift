//
//  ClipView.swift
//  Marble
//
//  Created by Daniel Li on 2/10/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ClipView: UIView, UIScrollViewDelegate {

    var delegate: ClipViewDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var innerView: UIView!
    
    var originalCenterYCord: CGFloat = 0.0
    var originalRect: CGRect = CGRect.zero
    var group: Group?
    var cell: GroupCollectionCell?
    var parentVC: UIViewController?
    var userId: Int?
    var clip: Clip?
    
    // OPTIONS
    var loopVideo: Bool = true
    var commentingEnabled: Bool = true
    var showOverlay: Bool = true
    
    @IBOutlet weak var saveClipBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var panning: Bool = false
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nameTapGest = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(nameTapGest)
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(clipTapped(tapGestureRecognizer:)))
        self.addGestureRecognizer(tapGest)

        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                
        styleLayer(layer: saveClipBtn.layer)
    }
    
    @IBAction func clipViewPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        
        let pointOfNoReturn: CGFloat = 70  // at what point the drag will cancel clip
        
        if sender.state == .ended {
            panning = false
            if translation.y > pointOfNoReturn {
                self.group?.clipViewIdx -= 1
                self.cell?.refreshPreview()
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                }, completion: { (_: Bool) in
                    self.exitClip()
                })
            } else if translation.y >= 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.innerView.center.y = self.originalCenterYCord
                    
                    let rect = CGRect(x: 0, y: 0, width: self.originalRect.width, height: self.originalRect.height)
                    
                    self.innerView.frame = self.originalRect
                    self.imageView.frame = rect
                    if let playerLayer = self.playerLayer {
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(0)
                        CATransaction.setDisableActions(true)
                        playerLayer.frame = rect
                        CATransaction.commit()
                    }
                })
            } else if translation.y > -pointOfNoReturn {
            }
        } else if (sender.state == .began) {
            panning = true
            self.backgroundColor = UIColor(white: 0, alpha: 1.0);
            
            imageView.image = nil
            if imageView.layer.sublayers != nil && (imageView.layer.sublayers?.count)! > 1 {
                imageView.layer.sublayers = [imageView.layer.sublayers!.last!]
            }
            let frame = self.innerView.frame
            originalRect = CGRect(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
            originalCenterYCord = self.innerView.center.y
        } else {
            if translation.y > 0 {
                if translation.y > pointOfNoReturn {
                    self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0 - ((translation.y - pointOfNoReturn)/self.frame.height))
                }
                let scale: CGFloat = 15  // lower means more photo shrinkage
                let rect = CGRect(x: 0, y: 0, width: originalRect.width - (translation.y/scale), height: originalRect.height - (translation.y/scale))
                
                self.innerView.center = CGPoint(x: innerView.center.x, y: originalCenterYCord + (translation.y/2))
                self.imageView.frame = rect
                if let playerLayer = self.playerLayer {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(0)
                    CATransaction.setDisableActions(true)
                    playerLayer.frame = rect
                    CATransaction.commit()
                }
                self.innerView.frame = CGRect(x: originalRect.x + (translation.y/(scale * 2)), y: innerView.frame.minY, width: originalRect.width - (translation.y/scale), height: originalRect.height - (translation.y/scale))
            } else {
                self.innerView.center.y = originalCenterYCord
            }
        }
    }
    
    func mediaStart() {
        self.group?.clipViewIdx = 0
        let stories = State.shared.groupClips[(group?.groupId)!]!
        if stories.count == 0 {
            return
        }
        
        let lastSeen = (self.group?.lastSeen)!
        for (idx, clip) in stories.enumerated() {
            if lastSeen < clip.timestamp {
                self.group?.clipViewIdx = idx
                break
            }
        }
        self.isHidden = false
        mediaNext()
    }
    
    func mediaStartClip(clip: Clip) {
        self.clip = clip
        showClip(clip: clip)
        self.isHidden = false
    }
    
    func mediaNext() {
        let clip = delegate?.nextClip(self)
        if let clip = clip {
            self.clip = clip
            showClip(clip: clip)
        } else {
            exitClip()
        }
    }
    
    func mediaBack() {
        let clip = delegate?.prevClip(self)
        if let clip = clip {
            self.clip = clip
            showClip(clip: clip)
        } else {
            exitClip()
        }
    }
    
    func showClip(clip: Clip) {
        player?.pause()
        if isIPhoneX() {
            let iphoneXMargin = Constants.IphoneXMargin
            let bounds = self.bounds
            self.innerView.translatesAutoresizingMaskIntoConstraints = true
            self.innerView.frame = CGRect(x: CGFloat(0), y: CGFloat(iphoneXMargin), width: bounds.width, height: bounds.height - CGFloat(2*iphoneXMargin))
        } else {
            self.innerView.frame.size = self.frame.size
        }
        let bounds = self.innerView.bounds
        let playerItem = AVPlayerItem(url: clip.videoFileUrl!)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer?.masksToBounds = true
        self.imageView.layer.addSublayer(playerLayer!)
        player?.play()
        player?.actionAtItemEnd = .none
        
        if showOverlay {
            if clip.isMemory {
                self.saveClipBtn.setImage(UIImage(named: "star_yellow"), for: .normal)
            } else {
                self.saveClipBtn.setImage(UIImage(named: "star"), for: .normal)
            }
            saveClipBtn.isHidden = false
            nameLabel.text = clip.posterName
            timeLabel.text = calcTime(time: clip.timestamp)
        } else {
            nameLabel.isHidden = true
            timeLabel.isHidden = true
            saveClipBtn.isHidden = true
        }
        
        layoutIfNeeded()
        
        self.userId = clip.userId
        
        self.group?.clipViewIdx += 1
    }
    
    private func exitClip() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        self.removeFromSuperview()
        showStatusBar()
        self.cell?.refreshPreview()
    }
    
    private func showStatusBar() {
        self.parentVC?.view.window?.windowLevel = UIWindowLevelNormal
    }
    
//    func appendComment(posterName: String, timestamp: Int64, image: UIImage) {
//        let captionView = UINib(nibName: "CaptionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CaptionView
//        captionView.translatesAutoresizingMaskIntoConstraints = true
//        styleLayer(layer: captionView.nameLabel.layer)
//        styleLayer(layer: captionView.timeLabel.layer)
//
//        captionView.nameLabel.text = posterName
//        captionView.timeLabel.text = calcTime(time: timestamp)
//        captionView.image = image
//        captionView.clipViewDelegate = self
//
//        captionView.frame = CGRect(x: 0, y: (CGFloat(count) * self.innerView.frame.height), width: self.innerView.frame.width, height: self.innerView.frame.height)
//        captionView.imageView.frame = self.innerView.frame
//
//        if count > 0 || (clip?.comments.count ?? 0) < 2 {
//            captionView.commentLabel.isHidden = true
//        }
//
//        captionScrollView.addSubview(captionView)
//
//        captionScrollView.contentSize = CGSize(width: self.frame.width, height: CGFloat(count + 1) * self.innerView.frame.height)
//    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        if loopVideo {
            player?.seek(to: kCMTimeZero)
            player?.play()
        } else {
            mediaNext()
        }
    }
    
    @objc func clipTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.state == .ended {
            let touchLocation = tapGestureRecognizer.location(in: self)
            let x = touchLocation.x
            let screenWidth = self.frame.width
            let percentage = Double(x) / Double(screenWidth)

            if percentage > 0.33 {
                self.mediaNext()
            } else {
                mediaBack()
            }
        }
    }
    
    var responder: SCLAlertViewResponder?
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleTop: 45.0,
                kWindowHeight: 10.0,
                kWindowHeightDeviation: -24.0,
                kTextFieldHeight: 0.0,
                kTextViewdHeight: 0.0,
                showCloseButton: false,
                showCircularIcon: false,
                hideWhenBackgroundViewIsTapped: true
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Flag Post", action: {
                self.imageView.becomeFirstResponder()
                Networker.shared.flagClip(clipId: (self.clip?.id)!, completionHandler: { resp in
                    let appearance = SCLAlertView.SCLAppearance(
                        hideWhenBackgroundViewIsTapped: true
                    )
                    let alert = SCLAlertView(appearance: appearance)
                    alert.showInfo("Post Flagged", subTitle: "Thank you for making Marble a better place.")
                })
            })
            alert.addButton("Block User", action: {
                self.imageView.becomeFirstResponder()
                if KeychainWrapper.userID() == self.userId {
                    return
                }
                State.shared.blockUser(userId: self.userId!, completionHandler: {
                    self.exitClip()
                })
            })
            alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: Constants.Colors.MarbleBlue, action: {
                self.responder?.close()
            })
            responder = alert.showInfo("Post Actions", subTitle: "")
        }
    }
    
    @IBAction func saveClipPressed(_ sender: UIButton) {
        clip?.isMemory = !clip!.isMemory
        if clip!.isMemory {
            var prefs = EasyTipView.Preferences()
            prefs.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
            prefs.drawing.backgroundColor = UIColor.black
            prefs.drawing.arrowPosition = .bottom
            prefs.drawing.foregroundColor = UIColor.white
            
            sender.setImage(UIImage(named: "star_yellow"), for: .normal)
            let tipView = EasyTipView(text: "Saved to our Memories", preferences: prefs, delegate: nil)
            tipView.show(animated: true, forView: sender, withinSuperview: self)
            Networker.shared.likeClip(clipId: clip!.id, completionHandler: { _ in })
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                tipView.dismiss()
            })
        } else {
            Networker.shared.unlikeClip(clipId: clip!.id, completionHandler: { _ in })
            sender.setImage(UIImage(named: "star"), for: .normal)
        }
    }
    
}
