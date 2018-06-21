//
//  HomeTVCell.swift
//  Marble
//
//  Created by Daniel Li on 5/21/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class HomeTVCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        vlogDescription.collapsed = true
        vlogDescription.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var vidPreviewImage: UIImageView!
    @IBOutlet weak var marbleName: UILabel!
    @IBOutlet weak var vlogDescription: mUILabel!
    
    var playIconBtn: UIButton?
    var vlog: Vlog?
    
}
