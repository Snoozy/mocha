//
//  CaptionView.swift
//  Marble
//
//  Created by Daniel Li on 4/25/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class CaptionView: UIImageView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commentLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        commentLabel.layer.shadowOpacity = 1
        commentLabel.layer.shadowRadius = 5
        
        commentLabel.font = UIFont.fontAwesome(ofSize: 11)
        commentLabel.text = String.fontAwesomeIcon(name: .chevronUp) + "\nCOMMENTS"
    }
    
}
