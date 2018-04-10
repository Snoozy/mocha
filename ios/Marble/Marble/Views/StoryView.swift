//
//  StoryImageView.swift
//  Marble
//
//  Created by Daniel Li on 2/10/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class StoryView: UIView, UIScrollViewDelegate {

    var delegate: StoryViewDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var innerView: UIView!
    
    var originalCenterYCord: CGFloat = 0.0
    var originalRect: CGRect = CGRect.zero
    var group: Group?
    var cell: GroupCollectionCell?
    var parentVC: UIViewController?
    var userId: Int?
    var story: Story?
    
    var commentingEnabled: Bool = true
    
    @IBOutlet weak var addCommentLabel: UILabel!
    
    @IBOutlet weak var captionScrollView: UIScrollView!
    var viewingComments: Bool = false
    
    @IBOutlet weak var sendCaptionBtn: UIButton!
    @IBOutlet weak var cancelCaptionBtn: UIButton!
    @IBOutlet weak var toTopBtn: UIButton!
    @IBOutlet weak var saveStoryBtn: UIButton!
    
    var panning: Bool = false
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nameTapGest = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(nameTapGest)
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(storyTapped(tapGestureRecognizer:)))
        self.addGestureRecognizer(tapGest)

        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        captionScrollView.delegate = self
        let margin: Int = {
            if isIPhoneX() {
                return Constants.IphoneXMargin
            }
            return 0
        }()
        captionScrollView.frame = CGRect(x: 0, y: CGFloat(margin), width: self.frame.width, height: self.frame.height)
        captionScrollView.isPagingEnabled = true
        
        styleLayer(layer: addCommentBtn.layer)
        
        sendCaptionBtn.layer.cornerRadius = 5
        styleLayer(layer: sendCaptionBtn.layer)
        
        cancelCaptionBtn.layer.borderWidth = 1
        cancelCaptionBtn.layer.cornerRadius = 5
        cancelCaptionBtn.layer.borderColor = UIColor.white.cgColor
        styleLayer(layer: cancelCaptionBtn.layer)
        
        styleLayer(layer: addCommentLabel.layer)
        
        styleLayer(layer: toTopBtn.layer)
        styleLayer(layer: saveStoryBtn.layer)
    }
    
    @IBAction func storyViewPan(_ sender: UIPanGestureRecognizer) {
        if viewingComments {
            return
        }
        let translation = sender.translation(in: self)
        
        let pointOfNoReturn: CGFloat = 70  // at what point the drag will cancel story
        
        if sender.state == .ended {
            panning = false
            if translation.y > pointOfNoReturn {
                self.group?.storyViewIdx -= 1
                self.cell?.refreshPreview()
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                }, completion: { (_: Bool) in
                    self.exitStory()
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
                captionScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            } else if story?.comments.count ?? 0 > 1 {
                captionScrollView.setContentOffset(CGPoint(x: 0, y: self.innerView.frame.height), animated: true)
                enableComments()
            }
        } else if (sender.state == .began) {
            panning = true
            self.backgroundColor = UIColor(white: 0, alpha: 1.0);
            
            if story?.mediaType == .video && imageView.image != nil {
                imageView.image = nil
            }
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
                self.captionScrollView.subviews.first?.frame = rect
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
                if story?.comments.count ?? 0 > 1  {
                    captionScrollView.contentOffset = CGPoint(x: 0, y: -translation.y)
                }
            }
        }
    }
    
    func enableComments() {
        self.viewingComments = true
        
        self.toTopBtn.isHidden = false
        self.saveStoryBtn.isHidden = true
        
        self.captionScrollView.isHidden = false
        
        self.sendCaptionBtn.isHidden = true
        self.cancelCaptionBtn.isHidden = true
        
        if commentingEnabled {
            self.addCommentBtn.isHidden = false
        }

        captionScrollView.isScrollEnabled = true

    }
    
    func disableComments() {
        captionScrollView.isScrollEnabled = false
        viewingComments = false
        toTopBtn.isHidden = true
        saveStoryBtn.isHidden = false
        
        self.sendCaptionBtn.isHidden = true
        self.cancelCaptionBtn.isHidden = true
    }
    
    @IBAction func toTopPress(_ sender: Any) {
        print("to top")
        captionScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        disableComments()
    }
    
    @IBOutlet weak var addCommentBtn: UIButton!
    
    var addCaptionView: MediaCaptionView!
    
    var captioning: Bool = false
    
    @IBAction func cancelCommentPress(_ sender: Any) {
        print("cancel comment")
        addCaptionView.removeFromSuperview()
        captionScrollView.isHidden = false
        
        sendCaptionBtn.isHidden = true
        cancelCaptionBtn.isHidden = true
        addCommentBtn.isHidden = false
        saveStoryBtn.isHidden = false
        
        addCommentLabel.isHidden = true
        
        captioning = false
        
        if captionScrollView.contentOffset.y <= 0 {
            toTopBtn.isHidden = true
            saveStoryBtn.isHidden = false
            captionScrollView.isScrollEnabled = true
            viewingComments = false
        } else {
            toTopBtn.isHidden = false
            saveStoryBtn.isHidden = true
            viewingComments = true
        }
    }
    
    @IBAction func addCommentPress(_ sender: Any) {
        print("add comment")
        captionScrollView.isHidden = true
        addCaptionView = MediaCaptionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        addCaptionView.configure()
        
        viewingComments = true
        
        self.innerView.insertSubview(addCaptionView, aboveSubview: imageView)
        
        sendCaptionBtn.isHidden = false
        cancelCaptionBtn.isHidden = false
        addCommentBtn.isHidden = true
        
        addCommentLabel.isHidden = false
        
        toTopBtn.isHidden = true
        saveStoryBtn.isHidden = true
        
        addCaptionView.isHidden = false
        addCaptionView.startEditingTextCaption()
        
        captioning = true
    }
    
    @IBAction func sendCaptionPress(_ sender: Any) {
        print("send caption")
        if addCaptionView.isEmpty() {
            let alert = UIAlertController(title: "Comment cannot be empty", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            return
        }
        addCommentLabel.isHidden = true
        let captionImg = addCaptionView.getCaptionImage()
        Networker.shared.uploadComment(image: captionImg, storyId: (story?.id)!, completionHandler: { response in
            switch response.result {
            case .success(let val):
                print("comment upload done")
                let json = JSON(val)
                let mediaId = json["media_url"].stringValue.components(separatedBy: "/").last
                var fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                fileUrl.appendPathComponent(mediaId! + ".png")
                let data = UIImagePNGRepresentation(captionImg)
                try? data?.write(to: fileUrl)
                State.shared.getMyStories(completionHandler: {
                    State.shared.loadStories()
                })
            case .failure:
                self.addCaptionView.removeFromSuperview()
                self.captionScrollView.isHidden = false
                print(response.debugDescription)
            }
        })
        
        self.addCaptionView.textResignFirstResponder()
        self.addCaptionView.removeFromSuperview()
        captioning = false

        let first = captionScrollView.subviews.first as! CaptionView
        first.commentLabel.isHidden = false
        
        enableComments()
        
        captionImg.af_inflate()
        let bounds = self.innerView.bounds
        let img = captionImg.af_imageScaled(to: CGSize(width: bounds.width, height: bounds.height))
        
        self.appendComment(posterName: (State.shared.me?.name)!, timestamp: Int64(NSDate().timeIntervalSince1970 * 1000), image: img)
        let count = captionScrollView.subviews.filter { (view) -> Bool in
            return view is CaptionView
        }.count
        let offset = CGFloat(count - 1) * bounds.height
        self.captionScrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            disableComments()
        }
    }
    
    func mediaStart() {
        captioning = false
        self.group?.storyViewIdx = 0
        let stories = State.shared.groupStories[(group?.groupId)!]!
        if stories.count == 0 {
            return
        }
        
        let lastSeen = (self.group?.lastSeen)!
        for (idx, story) in stories.enumerated() {
            if lastSeen < story.timestamp {
                self.group?.storyViewIdx = idx
                break
            }
        }
        self.isHidden = false
        mediaNext()
    }
    
    func mediaStartStory(story: Story) {
        captioning = false
        self.story = story
        showStory(story: story)
        self.isHidden = false
    }
    
    func mediaNext() {
        if captioning {
            return
        }
        let story = delegate?.nextStory(self)
        if let story = story {
            self.story = story
            showStory(story: story)
        } else {
            exitStory()
        }
    }
    
    func mediaBack() {
        let story = delegate?.prevStory(self)
        if let story = story {
            self.story = story
            showStory(story: story)
        } else {
            exitStory()
        }
    }
    
    func showStory(story: Story) {
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
        if story.mediaType == .image {
            let image = story.media
            self.imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            self.imageView.image = image
            self.imageView.layer.sublayers = nil
            player = nil
            playerLayer = nil
        } else if story.mediaType == .video {
            let playerItem = AVPlayerItem(url: story.videoFileUrl!)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            
            playerLayer?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.masksToBounds = true
            self.imageView.layer.addSublayer(playerLayer!)
            player?.play()
            player?.actionAtItemEnd = .none
        }
        
        if story.isMemory {
            self.saveStoryBtn.setImage(UIImage(named: "star_yellow"), for: .normal)
        } else {
            self.saveStoryBtn.setImage(UIImage(named: "star"), for: .normal)
        }
        
        if !commentingEnabled {
            addCommentBtn.isHidden = true
        }
        
        disableComments()
        
        let comments = story.comments
        
        captionScrollView.subviews.forEach({ $0.removeFromSuperview() })
        
        layoutIfNeeded()
        
        for comment in comments {
            if let commentImage = comment.image {
                appendComment(posterName: comment.posterName, timestamp: comment.timestamp, image: commentImage)
            } else {
                print("error adding comment")
            }
        }
        
        self.userId = story.userId
        
        self.group?.storyViewIdx += 1
    }
    
    private func exitStory() {
        if story?.mediaType == .video {
            player?.pause()
            player = nil
            playerLayer?.removeFromSuperlayer()
        }
        self.removeFromSuperview()
        showStatusBar()
        self.cell?.refreshPreview()
    }
    
    private func showStatusBar() {
        self.parentVC?.view.window?.windowLevel = UIWindowLevelNormal
    }
    
    func appendComment(posterName: String, timestamp: Int64, image: UIImage) {
        let captionView = UINib(nibName: "CaptionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CaptionView
        captionView.translatesAutoresizingMaskIntoConstraints = true
        styleLayer(layer: captionView.nameLabel.layer)
        styleLayer(layer: captionView.timeLabel.layer)
        
        captionView.nameLabel.text = posterName
        captionView.timeLabel.text = calcTime(time: timestamp)
        captionView.image = image
        captionView.storyViewDelegate = self
        
        let count = captionScrollView.subviews.filter { (view) -> Bool in
            return view is CaptionView
        }.count
        
        captionView.frame = CGRect(x: 0, y: (CGFloat(count) * self.innerView.frame.height), width: self.innerView.frame.width, height: self.innerView.frame.height)
        captionView.imageView.frame = self.innerView.frame
        
        if count > 0 || (story?.comments.count ?? 0) < 2 {
            captionView.commentLabel.isHidden = true
        }
        
        captionScrollView.addSubview(captionView)
        
        captionScrollView.contentSize = CGSize(width: self.frame.width, height: CGFloat(count + 1) * self.innerView.frame.height)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        if story?.mediaType == .video {
                player?.seek(to: kCMTimeZero)
                player?.play()
        } else {
            mediaNext()
        }
    }
    
    @objc func storyTapped(tapGestureRecognizer: UITapGestureRecognizer) {
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
                Networker.shared.flagStory(storyId: (self.story?.id)!, completionHandler: { resp in
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
                    self.exitStory()
                })
            })
            alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: Constants.Colors.MarbleBlue, action: {
                self.responder?.close()
            })
            responder = alert.showInfo("Post Actions", subTitle: "")
        }
    }
    
    @IBAction func saveStoryPressed(_ sender: UIButton) {
        story?.isMemory = !story!.isMemory
        if story!.isMemory {
            var prefs = EasyTipView.Preferences()
            prefs.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
            prefs.drawing.backgroundColor = UIColor.black
            prefs.drawing.arrowPosition = .bottom
            prefs.drawing.foregroundColor = UIColor.white
            
            sender.setImage(UIImage(named: "star_yellow"), for: .normal)
            let tipView = EasyTipView(text: "Saved to our Memories", preferences: prefs, delegate: nil)
            tipView.show(animated: true, forView: sender, withinSuperview: self)
            Networker.shared.saveMemory(storyId: story!.id, completionHandler: { _ in })
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                tipView.dismiss()
            })
        } else {
            Networker.shared.removeMemory(storyId: story!.id, completionHandler: { _ in })
            sender.setImage(UIImage(named: "star"), for: .normal)
        }
    }
    
}
