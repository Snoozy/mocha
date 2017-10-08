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
        // Initialization code
        if MainGroupTVCell.reloadIcon == nil {
            MainGroupTVCell.reloadIcon = UIImage(named: "reload")!.addShadow(blurSize: 35.0)
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
        qrFilter.setValue("Q", forKey: "inputCorrectionLevel")
        
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
        if (State.shared.groupStories[(group?.groupId)!]?.count)! > 0 {
            self.title.textColor = UIColor.white
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
                    return seen ? blurImage(image: previewStory.media!)! : previewStory.media!
                } else {
                    let img = videoPreviewImage(fileUrl: (previewStory.videoFileUrl)!)!
                    return seen ? blurImage(image: img)! : img
                }
            }()
            let imgMasked = image.maskRectangle(width: storyPreview.frame.width, height: storyPreview.frame.height)
            
            storyPreview.image = imgMasked!
            
            self.clipsToBounds = false
            self.layer.masksToBounds = false
            
            self.title.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.title.layer.shadowOpacity = 1
            self.title.layer.shadowColor = UIColor.black.cgColor
            self.title.layer.shadowRadius = 2

            self.layer.cornerRadius = 3
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            if !seen {
                self.layer.shadowOpacity = 1
                self.layer.shadowColor = Constants.Colors.MarbleBlue.cgColor
                self.layer.shadowRadius = 2
            } else {
                self.layer.shadowOpacity = 0.4
                self.layer.shadowColor = nil
                self.layer.shadowRadius = 2
            }
        } else {
            storyPreview.image = nil
            loadingIcon.isHidden = true
            
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 3
            
            self.layer.shadowRadius = 0
            
            self.title.layer.shadowRadius = 0
            self.title.textColor = UIColor.gray
        }
    }
    
    func blurImage(image:UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let originalOrientation = image.imageOrientation
        let originalScale = image.scale
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(30.0, forKey: kCIInputRadiusKey)
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
        whiteImg?.draw(at: .zero, blendMode: .normal, alpha: 0.75)
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

}

