//
//  MemoriesCell.swift
//  Marble
//
//  Created by Daniel Li on 12/24/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class MemoriesCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var numberLabel: UILabel!
    
    var clip: Clip?
    
    func refreshPreview() {
        let image: UIImage = {
            let img = videoPreviewImage(fileUrl: (clip!.videoFileUrl)!)
            return img ?? UIImage(color: UIColor.lightGray, size: CGSize(width: self.bounds.width, height: self.bounds.width))!
        }()
        
        previewImage.image = image.maskRectangle(width: self.bounds.width, height: self.bounds.height)
        previewImage.isHidden = false
    }
    
}
