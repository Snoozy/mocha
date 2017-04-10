//
//  StoryImageView.swift
//  Marble
//
//  Created by Daniel Li on 2/10/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class StoryImageView: UIView {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nameTapGest = UITapGestureRecognizer(target: self, action: #selector(nameTouched(_:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(nameTapGest)
    }
    
    @IBAction func storyViewPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        if sender.state == .ended {
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
                    self.innerView.frame = CGRect(x: 0, y: 0, width: self.originalWidth, height: self.originalHeight)
                    self.imageView.frame = CGRect(x: 0, y: 0, width: self.originalWidth, height: self.originalHeight)
                })
            }
        } else if (sender.state == .began) {
            self.backgroundColor = UIColor(white: 1, alpha: 1.0);
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
                self.innerView.center = CGPoint(x: innerView.center.x, y: originalCenterYCord + (translation.y/2))
                self.imageView.frame = CGRect(x: 0, y: 0, width: originalWidth - (translation.y/5), height: originalHeight - (translation.y/5))
                self.innerView.frame = CGRect(x: originalMinX + (translation.y/10), y: innerView.frame.minY, width: originalWidth - (translation.y/5), height: originalHeight - (translation.y/5))
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
    }
    
    func mediaNext() {
        let stories = State.shared.groupStories[(group?.groupId)!]
        if (self.group?.storyIdxValid())! {  // next story
            let story: Story = (stories?[(group?.storyViewIdx)!])!
            let image = story.media
            
            self.imageView.frame = self.innerView.frame
            self.imageView.image = image
            
            styleLabel(label: self.nameLabel)
            styleLabel(label: self.timeLabel)
            
            self.userId = story.userId
            self.nameLabel.text = story.posterName
            self.timeLabel.text = calcTime(time: story.timestamp)
            
            //self.imageView.frame = CGRect.init(x: 0.0, y: 0.0, width: (image?.size.width)!, height: (image?.size.height)!)
            self.group?.storyViewIdx += 1
        } else {
            UIApplication.shared.isStatusBarHidden = false
            self.removeFromSuperview()
            self.cell?.refreshPreview()
        }
    }
    
    func styleLabel(label: UILabel) {
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
    }
    
    // Converts milliseconds delta to hours string
    func calcTime(time: Int64) -> String {
        let start: Int64 = Int64(NSDate().timeIntervalSince1970 * 1000)
        let delta = start - time
        if delta < 3600000 {  // less than 1 hr ago
            let temp = delta/60000
            if temp <= 0 {  // less than 1 min ago
                return "Just now"
            }
            return String(temp) + "m ago"
        }
        return String(delta/3600000) + "h ago"
    }
    
    let overlayVC = UIViewController()  // kinda hacky way to get action sheet to display correctly
    
    func nameTouched(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: nil, message: "User actions", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.imageView.becomeFirstResponder()
            self.overlayVC.dismiss(animated: false, completion: nil)
        })
        alertController.addAction(cancelAction)
        
        let blockAction = UIAlertAction(title: "Block", style: .destructive, handler: { action in
            self.imageView.becomeFirstResponder()
            self.overlayVC.dismiss(animated: false, completion: nil)
            State.shared.blockUser(userId: self.userId!, completionHandler: { response in
                UIApplication.shared.isStatusBarHidden = false
                self.removeFromSuperview()
                self.cell?.refreshPreview()
            })
        })
        alertController.addAction(blockAction)
        
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        
        topVC?.present(overlayVC, animated: false, completion: {
            self.overlayVC.present(alertController, animated: true, completion: nil)
        })
    }
}
