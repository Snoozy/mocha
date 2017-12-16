//
//  MemoriesTVCell.swift
//  Marble
//
//  Created by Daniel Li on 12/8/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class MemoriesTVCell: UITableViewCell {

    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        photoCollectionView.delegate = dataSourceDelegate
        photoCollectionView.dataSource = dataSourceDelegate
        photoCollectionView.tag = row
        photoCollectionView.setContentOffset(photoCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        photoCollectionView.reloadData()
    }

}
