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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var innerView: UIView!
    
    var originalCenterYCord: CGFloat = 0.0
    var originalWidth: CGFloat = 0.0
    var originalHeight: CGFloat = 0.0
    var originalMinX: CGFloat = 0.0
    var group: Group?
    var cell: MainGroupTVCell?
    var parentVC: UIViewController?
    var userId: Int?
    var story: Story?
    
    @IBOutlet weak var addCommentLabel: UILabel!
    
    @IBOutlet weak var captionScrollView: UIScrollView!
    var viewingComments: Bool = false
    
    @IBOutlet weak var sendCaptionBtn: UIButton!
    @IBOutlet weak var cancelCaptionBtn: UIButton!
    @IBOutlet weak var toTopBtn: UIButton!
    
    var panning: Bool = false
    
    //var numComments: Int = 0
    
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
        captionScrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        styleLayer(layer: addCommentBtn.layer)
        
        sendCaptionBtn.layer.cornerRadius = 5
        styleLayer(layer: sendCaptionBtn.layer)
        
        cancelCaptionBtn.layer.borderWidth = 1
        cancelCaptionBtn.layer.cornerRadius = 5
        cancelCaptionBtn.layer.borderColor = UIColor.white.cgColor
        styleLayer(layer: cancelCaptionBtn.layer)
        
        styleLayer(layer: addCommentLabel.layer)
        
        styleLayer(layer: toTopBtn.layer)
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
                    
                    let rect = CGRect(x: 0, y: 0, width: self.originalWidth, height: self.originalHeight)
                    
                    self.innerView.frame = CGRect(x: 0, y: 0, width: self.originalWidth, height: self.originalHeight)
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
                captionScrollView.setContentOffset(CGPoint(x: 0, y: UIScreen.main.bounds.height), animated: true)
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
            let bounds = UIScreen.main.bounds
            originalCenterYCord = self.innerView.center.y
            originalWidth = bounds.width
            originalHeight = bounds.height
            originalMinX = 0
        } else {
            if translation.y > 0 {
                if translation.y > pointOfNoReturn {
                    self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0 - ((translation.y - pointOfNoReturn)/UIScreen.main.bounds.height))
                }
                let scale: CGFloat = 15  // lower means more photo shrinkage
                let rect = CGRect(x: 0, y: 0, width: originalWidth - (translation.y/scale), height: originalHeight - (translation.y/scale))
                
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
                
                self.innerView.frame = CGRect(x: originalMinX + (translation.y/(scale * 2)), y: innerView.frame.minY, width: originalWidth - (translation.y/scale), height: originalHeight - (translation.y/scale))
            } else {
                self.innerView.center.y = originalCenterYCord
                if captionScrollView.subviews.count > 1 {
                    captionScrollView.contentOffset = CGPoint(x: 0, y: -translation.y)
                }
            }
        }
    }
    
    func enableComments() {
        self.viewingComments = true
        
        self.toTopBtn.isHidden = false
        
        self.captionScrollView.isHidden = false
        
        self.sendCaptionBtn.isHidden = true
        self.cancelCaptionBtn.isHidden = true
        
        self.addCommentBtn.isHidden = false

        captionScrollView.isScrollEnabled = true

    }
    
    func disableComments() {
        captionScrollView.isScrollEnabled = false
        viewingComments = false
        toTopBtn.isHidden = true
        
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
    
    @IBAction func cancelCommentPress(_ sender: Any) {
        print("cancel comment")
        addCaptionView.removeFromSuperview()
        captionScrollView.isHidden = false
        
        sendCaptionBtn.isHidden = true
        cancelCaptionBtn.isHidden = true
        addCommentBtn.isHidden = false
        
        addCommentLabel.isHidden = true
        
        if captionScrollView.contentOffset.y <= 0 {
            toTopBtn.isHidden = true
            captionScrollView.isScrollEnabled = true
            viewingComments = false
        } else {
            toTopBtn.isHidden = false
            viewingComments = true
        }
    }
    
    @IBAction func addCommentPress(_ sender: Any) {
        print("add comment")
        captionScrollView.isHidden = true
        addCaptionView = MediaCaptionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        addCaptionView.configure()
        
        viewingComments = true
        
        self.innerView.insertSubview(addCaptionView, aboveSubview: imageView)
        
        sendCaptionBtn.isHidden = false
        cancelCaptionBtn.isHidden = false
        addCommentBtn.isHidden = true
        
        addCommentLabel.isHidden = false
        
        toTopBtn.isHidden = true
        
        addCaptionView.caption.isHidden = false
        addCaptionView.caption.becomeFirstResponder()
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
        let captionImg = UIImage(view: addCaptionView)
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
        
        self.addCaptionView.caption.resignFirstResponder()
        self.addCaptionView.removeFromSuperview()

        let first = captionScrollView.subviews.first as! CaptionView
        first.commentLabel.isHidden = false
        
        enableComments()
        
        //numComments += 1
        
        captionImg.af_inflate()
        let bounds = UIScreen.main.bounds
        let img = captionImg.af_imageScaled(to: CGSize(width: bounds.width, height: bounds.height))
        print(img.size)
        
        self.appendComment(posterName: (State.shared.me?.name)!, timestamp: Int64(NSDate().timeIntervalSince1970 * 1000), image: img)
        let offset = CGFloat(self.captionScrollView.subviews.count - 1) * bounds.height
        self.captionScrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            disableComments()
        }
    }
    
    func mediaStart() {
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
        self.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.innerView.frame.size = self.frame.size
        mediaNext()
        self.isHidden = false
    }
    
    func mediaNext() {
        let stories = State.shared.groupStories[(group?.groupId)!]
        if (self.group?.storyIdxValid())! {  // next story
            let story: Story = (stories?[(group?.storyViewIdx)!])!
            self.story = story
            showStory(story: story)
        } else {
            exitStory()
        }
    }
    
    func mediaBack() {
        let stories = State.shared.groupStories[(group?.groupId)!]
        if (group?.storyViewIdx)! < 2 {
            exitStory()
        } else {
            group?.storyViewIdx -= 2
            let story: Story = (stories?[(group?.storyViewIdx)!])!
            self.story = story
            showStory(story: story)
        }
    }
    
    func showStory(story: Story) {
        player?.pause()
        let bounds = UIScreen.main.bounds
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
        
        disableComments()
        
        let comments = story.comments
        
        captionScrollView.subviews.forEach({ $0.removeFromSuperview() })
        
        for comment in comments {
            appendComment(posterName: comment.posterName, timestamp: comment.timestamp, image: comment.image!)
        }
        
        self.userId = story.userId
        
        self.group?.storyViewIdx += 1
    }
    
    private func exitStory() {
        self.removeFromSuperview()
        self.parentVC?.view.window?.windowLevel = UIWindowLevelNormal
        self.cell?.refreshPreview()
    }
    
    func appendComment(posterName: String, timestamp: Int64, image: UIImage) {
        let captionView = UINib(nibName: "CaptionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CaptionView
        
        styleLayer(layer: captionView.nameLabel.layer)
        styleLayer(layer: captionView.timeLabel.layer)
        
        captionView.nameLabel.text = posterName
        captionView.timeLabel.text = calcTime(time: timestamp)
        captionView.image = image
        
        let count = captionScrollView.subviews.count
        
        captionView.frame = CGRect(x: 0, y: (CGFloat(count) * UIScreen.main.bounds.height), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        if count > 0 || (story?.comments.count ?? 0) < 2 {
            captionView.commentLabel.isHidden = true
        }
        
        captionScrollView.addSubview(captionView)
        
        captionScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(count + 1) * UIScreen.main.bounds.height)
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
            let screenWidth = UIScreen.main.bounds.width
            let percentage = Double(x) / Double(screenWidth)

            if percentage > 0.33 {
                self.mediaNext()
            } else {
                mediaBack()
            }
        }
    }
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            
            let alertController = UIAlertController(title: nil, message: "User actions", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.imageView.becomeFirstResponder()
            })
            alertController.addAction(cancelAction)
            
            let blockAction = UIAlertAction(title: "Block User", style: .destructive, handler: { action in
                self.imageView.becomeFirstResponder()
                if KeychainWrapper.userID() == self.userId {
                    let alert = UIAlertController(title: "You cannot block yourself.", message: nil, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
                        self.imageView.becomeFirstResponder()
                    }
                    alert.addAction(cancel)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    return
                }
                State.shared.blockUser(userId: self.userId!, completionHandler: {
                    UIApplication.shared.isStatusBarHidden = false
                    self.removeFromSuperview()
                    self.cell?.refreshPreview()
                })
            })
            alertController.addAction(blockAction)
            
            let flagAction = UIAlertAction(title: "Flag Post", style: .destructive, handler: { action in
                self.imageView.becomeFirstResponder()
                Networker.shared.flagStory(storyId: (self.story?.id)!, completionHandler: { resp in
                    let alert = UIAlertController(title: "Thank You", message: "Thank you for making Marble a better place.", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
                        self.imageView.becomeFirstResponder()
                    }
                    alert.addAction(cancel)
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                    return

                })
            })
            alertController.addAction(flagAction)
            
            self.parentVC?.present(alertController, animated: true, completion: nil)
        }
    }
}
