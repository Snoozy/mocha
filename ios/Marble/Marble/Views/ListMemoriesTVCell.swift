//
//  MemoriesTVCell.swift
//  Marble
//
//  Created by Daniel Li on 1/22/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class ListMemoriesTVCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    
    var group: Group?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func groupInfoPressed(_ sender: Any) {
        
    }
    
}
