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
    
    var story: Story?
    
    func refreshPreview() {
        let image: UIImage = {
            if story!.mediaType == .image {
                return story!.media!
            } else {
                let img = videoPreviewImage(fileUrl: (story!.videoFileUrl)!)
                return img!
            }
        }()
        
        previewImage.image = image
    }
    
}
