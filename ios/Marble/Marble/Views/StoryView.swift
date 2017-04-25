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

class StoryView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var originalCenterYCord: CGFloat = 0.0
    var originalWidth: CGFloat = 0.0
    var originalHeight: CGFloat = 0.0
    var originalMinX: CGFloat = 0.0
    var group: Group?
    var cell: MainGroupTVCell?
    var parentVC: UIViewController?
    var userId: Int?
    var story: Story?
    
    
    
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
    }
    
    @IBAction func storyViewPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        if sender.state == .ended {
            panning = false
            if translation.y > 90 {
                self.group?.storyViewIdx -= 1
                self.cell?.refreshPreview()
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                }, completion: { (_: Bool) in
                    UIApplication.shared.isStatusBarHidden = false
                    self.removeFromSuperview()
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.innerView.center.y = self.originalCenterYCord
                    let rect = CGRect(x: 0, y: 0, width: self.originalWidth, height: self.originalHeight)
                    self.innerView.frame = CGRect(x: 0, y: 0, width: self.originalWidth, height: self.originalHeight)
                    self.imageView.frame = rect
                    if let playerLayer = self.playerLayer {
                        playerLayer.frame = rect
                    }
                })
            }
        } else if (sender.state == .began) {
            panning = true
            self.backgroundColor = UIColor(white: 1, alpha: 1.0);
            
            if story?.mediaType == .video && imageView.image != nil {
                imageView.image = nil
            }
            if imageView.layer.sublayers != nil && (imageView.layer.sublayers?.count)! > 1 {
                imageView.layer.sublayers = [imageView.layer.sublayers!.last!]
            }
            originalCenterYCord = self.innerView.center.y
            originalWidth = self.innerView.frame.width
            originalHeight = self.innerView.frame.height
            originalMinX = self.innerView.frame.minX
        } else {
            if translation.y > 0 {
                if translation.y > 90 {
                    UIApplication.shared.isStatusBarHidden = false
                    self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0 - ((translation.y - 90.0)/UIScreen.main.bounds.height))
                } else {
                    UIApplication.shared.isStatusBarHidden = true
                }
                let scale: CGFloat = 15
                let rect = CGRect(x: 0, y: 0, width: originalWidth - (translation.y/scale), height: originalHeight - (translation.y/scale))
                self.innerView.center = CGPoint(x: innerView.center.x, y: originalCenterYCord + (translation.y/2))
                self.imageView.frame = rect
                if let playerLayer = self.playerLayer {
                    playerLayer.frame = rect
                }
                self.innerView.frame = CGRect(x: originalMinX + (translation.y/(scale * 2)), y: innerView.frame.minY, width: originalWidth - (translation.y/scale), height: originalHeight - (translation.y/scale))
            } else {
                self.innerView.center.y = originalCenterYCord
            }
        }
    }
    
    func mediaStart() {
        UIApplication.shared.isStatusBarHidden = true
        if (self.group?.storyViewIdx)! >= (State.shared.groupStories[(group?.groupId)!]?.count)! {
            self.group?.storyViewIdx = 0
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
            UIApplication.shared.isStatusBarHidden = false
            self.removeFromSuperview()
            self.cell?.refreshPreview()
        }
    }
    
    func mediaBack() {
        let stories = State.shared.groupStories[(group?.groupId)!]
        if (group?.storyViewIdx)! < 2 {
            UIApplication.shared.isStatusBarHidden = false
            self.removeFromSuperview()
            self.cell?.refreshPreview()
        } else {
            group?.storyViewIdx -= 2
            let story: Story = (stories?[(group?.storyViewIdx)!])!
            self.story = story
            showStory(story: story)
        }
    }
    
    func showStory(story: Story) {
        player?.pause()
        if story.mediaType == .image {
            let image = story.media
            
            self.imageView.frame = self.innerView.frame
            self.imageView.image = image
            self.imageView.layer.sublayers = nil
            player = nil
            playerLayer = nil
        } else if story.mediaType == .video {
            let playerItem = AVPlayerItem(url: story.videoFileUrl!)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = self.imageView.frame
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            playerLayer?.masksToBounds = true
            self.imageView.layer.addSublayer(playerLayer!)
            player?.play()
            player?.actionAtItemEnd = .none
        }
        
        styleLabel(label: self.nameLabel)
        styleLabel(label: self.timeLabel)
        
        self.userId = story.userId
        self.nameLabel.text = story.posterName
        self.timeLabel.text = calcTime(time: story.timestamp)
        
        self.group?.storyViewIdx += 1
    }
    
    func styleLabel(label: UILabel) {
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        if panning {
            if story?.mediaType == .video {
                player?.seek(to: kCMTimeZero)
                player?.play()
            }
        } else {
            mediaNext()
        }
    }
    
    func storyTapped(tapGestureRecognizer: UITapGestureRecognizer) {
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
    
    func longPressed(_ sender: UILongPressGestureRecognizer) {
        
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
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                    return
                }
                State.shared.blockUser(userId: self.userId!, completionHandler: { response in
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
            
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
}
