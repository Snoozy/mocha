//
//  MemberTVCellTableViewCell.swift
//  Marble
//
//  Created by Daniel Li on 11/8/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class MemberTVCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var memberName: UILabel!
    
}
