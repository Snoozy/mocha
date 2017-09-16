//
//  MainGroupTVCell.swift
//  Marble
//
//  Created by Daniel Li on 2/10/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class MainGroupTVCell: UITableViewCell {
    
    var group: Group?
    var storyLoadCount: Int?
    
    static var reloadIcon: UIImage?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if MainGroupTVCell.reloadIcon == nil {
            MainGroupTVCell.reloadIcon = UIImage(named: "reload")!.addShadow(blurSize: 35.0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func startLoading() {
        self.loadingIcon.isHidden = false
        self.loadingIcon.startAnimating()
        self.storyPreview.isHidden = true
    }
    
    func stopLoading() {
        self.loadingIcon.isHidden = true
        self.loadingIcon.stopAnimating()
        self.storyPreview.isHidden = false
    }
    
    func refreshPreview() {
        if (State.shared.groupStories[(group?.groupId)!]?.count)! > 0{
            let stories = State.shared.groupStories[(group?.groupId)!]!
            var previewStory: Story = stories.first!
            let lastSeen = group?.lastSeen
            for story in stories {
                previewStory = story
                if story.timestamp > lastSeen! {
                    break
                }
            }
            
            let seen: Bool = previewStory.timestamp <= lastSeen!
            
            let image: UIImage = {
                if previewStory.mediaType == .image {
                    return seen ? seenOpaqueOverlay(image: previewStory.media!) : previewStory.media!
                } else {
                    return seen ? seenOpaqueOverlay(image: videoPreviewImage(fileUrl: (previewStory.videoFileUrl)!)!) : videoPreviewImage(fileUrl: (previewStory.videoFileUrl)!)!
                }
            }()
            let imgMasked = image.maskRectangle(width: storyPreview.frame.width, height: storyPreview.frame.height)
            storyPreview.image = seen ? seenReplayOverlay(image: imgMasked!) : imgMasked!
            
            storyPreview.layer.shadowOffset = CGSize(width: 0, height: 0)
            storyPreview.layer.shadowOpacity = 1
            if !seen {
                title.font = UIFont.boldSystemFont(ofSize: title.font.pointSize)
                storyPreview.layer.shadowColor = Constants.Colors.MarbleBlue.cgColor
                storyPreview.layer.shadowRadius = 6
            } else {
                title.font = UIFont.systemFont(ofSize: title.font.pointSize)
                storyPreview.layer.shadowColor = nil
                storyPreview.layer.shadowRadius = 2
            }
        } else {
            storyPreview.image = nil
        }
    }
    
    func seenOpaqueOverlay(image: UIImage) -> UIImage {
        let whiteImg = UIImage(color: UIColor.white, size: image.size)
        
        UIGraphicsBeginImageContext(image.size)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: .zero)
        whiteImg?.draw(at: .zero, blendMode: .normal, alpha: 0.35)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func seenReplayOverlay(image: UIImage) -> UIImage {
        let reloadIconSize: CGFloat = 20
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: .zero)
        MainGroupTVCell.reloadIcon?.draw(in: CGRect(x: (image.size.width/2) - (reloadIconSize/2), y: (image.size.height/2) - (reloadIconSize/2), width: reloadIconSize, height: reloadIconSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var storyPreview: UIImageView!

}
