//
//  GroupCollectionCell.swift
//  Marble
//
//  Created by Daniel Li on 10/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

class GroupCollectionCell: UICollectionViewCell {
    
    var group: Group?
    var storyLoadCount: Int?
    
    static var reloadIcon: UIImage?
    static var fallbackPreview: UIImage?
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var storyPreview: UIImageView!
    @IBOutlet weak var nameBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if GroupCollectionCell.reloadIcon == nil {
            GroupCollectionCell.reloadIcon = UIImage(named: "check")!.addShadow(blurSize: 35.0)
        }
        if GroupCollectionCell.fallbackPreview == nil {
            GroupCollectionCell.fallbackPreview = UIImage(color: UIColor.black, size: UIScreen.main.bounds.size)
        }
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
    
    @IBAction func titleBtnPressed(_ sender: Any) {
        showMarbleInfo()
    }
    
    @IBAction func moreInfoPressed(_ sender: Any) {
        showMarbleInfo()
    }
    
    func showMarbleInfo() {
        let modal = GroupInfoVC(nibName: "GroupInfo", bundle: nil)
        modal.setGroup(group: group!)
        let transitionDelegate = DeckTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        UIApplication.topViewController()?.present(modal, animated: true, completion: nil)
    }
    
    func refreshPreview() {
        self.nameBtn.setTitle(group!.name, for: .normal)
        if (State.shared.groupStories[(group?.groupId)!]?.count)! > 0 {
            self.nameBtn.titleLabel?.textColor = UIColor.black
            self.layer.borderWidth = 0
            
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
                    if let imgMedia = previewStory.media {
                        return seen ? seenOpaqueOverlay(image: blurImage(image: imgMedia)!) : imgMedia
                    } else {
                        return GroupCollectionCell.fallbackPreview!
                    }
                } else {
                    let img = videoPreviewImage(fileUrl: (previewStory.videoFileUrl)!)
                    if let img = img {
                        return seen ? seenOpaqueOverlay(image: blurImage(image: img)!) : img
                    } else {
                        return GroupCollectionCell.fallbackPreview!
                    }
                }
            }()
            let imgMasked = image.circleMasked
            storyPreview.image = imgMasked!.imageWithInsets(insets: UIEdgeInsetsMake(70, 70, 70, 70))
            
            storyPreview.layer.cornerRadius = 0
            storyPreview.layer.borderWidth = 0
            
            self.clipsToBounds = false
            self.layer.masksToBounds = false
            
            self.storyPreview.layer.masksToBounds = false
            self.storyPreview.clipsToBounds = false
            self.storyPreview.layer.cornerRadius = storyPreview.bounds.width / 2
            if !seen {
                self.storyPreview.layer.borderWidth = 2.2
                self.storyPreview.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
                self.nameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
            } else {
                self.storyPreview.layer.borderWidth = 2.2
                self.storyPreview.layer.borderColor = UIColor.lightGray.cgColor
                self.nameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        } else {
            storyPreview.image = nil
            loadingIcon.isHidden = true
            
            self.storyPreview.layer.masksToBounds = false
            self.storyPreview.clipsToBounds = false
            self.clipsToBounds = false
            self.layer.masksToBounds = false

            storyPreview.layer.cornerRadius = storyPreview.frame.width / 2
            storyPreview.layer.borderWidth = 2.2
            storyPreview.layer.borderColor = UIColor.lightGray.cgColor
            storyPreview.layer.shadowRadius = 0
            self.nameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            
            self.nameBtn.layer.shadowRadius = 0
        }
    }
    
    func blurImage(image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let originalOrientation = image.imageOrientation
        let originalScale = image.scale
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(10.0, forKey: kCIInputRadiusKey)
        let outputImage = filter?.outputImage
        
        var cgImage:CGImage?
        
        if let asd = outputImage {
            cgImage = context.createCGImage(asd, from: (inputImage?.extent)!)
        }
        
        if let cgImageA = cgImage {
            return UIImage(cgImage: cgImageA, scale: originalScale, orientation: originalOrientation)
        }
        
        return nil
    }
    
    func seenOpaqueOverlay(image: UIImage) -> UIImage {
        let whiteImg = UIImage(color: UIColor.white, size: image.size)
        
        UIGraphicsBeginImageContext(image.size)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: .zero)
        whiteImg?.draw(at: .zero, blendMode: .normal, alpha: 0.5)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func seenReplayOverlay(image: UIImage) -> UIImage {
        let reloadIconSize: CGFloat = image.size.width / 6

        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: .zero)
        GroupCollectionCell.reloadIcon?.draw(in: CGRect(x: (image.size.width/2) - (reloadIconSize/2), y: (image.size.height/2) - (reloadIconSize/2), width: reloadIconSize, height: reloadIconSize), blendMode: .normal, alpha: 0.6)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

}

