//
//  CommentTVCell.swift
//  Marble
//
//  Created by Daniel Li on 6/21/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class CommentTVCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func setTime(timestamp: Int64) {
        timeLabel.text = calcTime(time: timestamp, verbose: false)
    }
    
}
