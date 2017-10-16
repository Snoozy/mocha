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
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var storyPreview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if GroupCollectionCell.reloadIcon == nil {
            GroupCollectionCell.reloadIcon = UIImage(named: "check")!.addShadow(blurSize: 35.0)
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
    
    func showMarbleInfo() {
        let appearance = SCLAlertView.SCLAppearance(
            kCircleIconHeight: 100,
            hideWhenBackgroundViewIsTapped: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let subTitle = String(format: "Marble Code: %d", (group?.groupId)!) + "\nMembers: " + String(describing:(group?.members)!)
        let qrCodeImg = createMarbleQRCode(content: String(format: "marble.group:%d", (group?.groupId)!), color: CIColor(color: Constants.Colors.MarbleBlue))
        let context = CIContext(options: nil)
        let img = UIImage(cgImage: context.createCGImage(qrCodeImg!, from: (qrCodeImg?.extent)!)!)
        alert.showInfo((group?.name)!, subTitle: subTitle, circleIconImage: img, iconHeightDeviation: 25)
    }
    
    func createMarbleQRCode(content: String, color: CIColor, backgroundColor: CIColor = CIColor(red: 1, green: 1, blue: 1)) -> CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        qrFilter.setDefaults()
        qrFilter.setValue(content.data(using: .isoLatin1), forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        
        let coloredQR = colorFilter.outputImage
        
        let scaleX = 100 / (coloredQR?.extent.size.width)!
        let scaleY = 100 / (coloredQR?.extent.size.height)!
        
        return coloredQR?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
    
    func refreshPreview() {
        self.title.text = group?.name
        if (State.shared.groupStories[(group?.groupId)!]?.count)! > 0 {
            self.title.textColor = UIColor.black
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
                    return seen ? seenOpaqueOverlay(image: blurImage(image: previewStory.media!)!) : previewStory.media!
                } else {
                    let img = videoPreviewImage(fileUrl: (previewStory.videoFileUrl)!)!
                    return seen ? seenOpaqueOverlay(image: blurImage(image: img)!) : img
                }
            }()
            let imgMasked = image.circleMasked
            storyPreview.image = seen ? seenReplayOverlay(image: imgMasked!) : imgMasked!
//            storyPreview.image = imgMasked!
            
            storyPreview.layer.cornerRadius = 0
            storyPreview.layer.borderWidth = 0
            
            self.clipsToBounds = false
            self.layer.masksToBounds = false
            
            self.storyPreview.layer.masksToBounds = false
            self.storyPreview.clipsToBounds = false
            self.storyPreview.layer.shadowOffset = CGSize(width: 0, height: 0)
            if !seen {
                self.storyPreview.layer.shadowOpacity = 1
                self.storyPreview.layer.shadowColor = Constants.Colors.UnseenHighlight.cgColor
                self.storyPreview.layer.shadowRadius = 5
                self.title.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
            } else {
                self.storyPreview.layer.shadowOpacity = 0.7
                self.storyPreview.layer.shadowColor = nil
                self.storyPreview.layer.shadowRadius = 3
                self.title.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        } else {
            storyPreview.image = nil
            loadingIcon.isHidden = true
            
            storyPreview.layer.cornerRadius = storyPreview.frame.width / 2
            storyPreview.layer.borderWidth = 1
            storyPreview.layer.borderColor = UIColor.gray.cgColor
            storyPreview.layer.shadowRadius = 0
            self.title.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            
            self.title.layer.shadowRadius = 0
        }
    }
    
    func blurImage(image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let originalOrientation = image.imageOrientation
        let originalScale = image.scale
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(15.0, forKey: kCIInputRadiusKey)
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

