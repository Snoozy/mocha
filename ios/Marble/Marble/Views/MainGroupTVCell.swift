//
//  MainGroupTVCell.swift
//  Marble
//
//  Created by Daniel Li on 2/10/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class MainGroupTVCell: UITableViewCell {
    
    var group: Group?
    var storyLoadCount: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    func refreshPreview() {
        if (group?.storyIdxValid())! {
            let image = State.shared.groupStories[(group?.groupId)!]?[(group?.storyViewIdx)!].media
            storyPreview.image = image?.circleMasked
        }
    }
    
    func refreshSeen() {
        let lastSeen = group?.lastSeen
        let lastStory = State.shared.groupStories[(group?.groupId)!]?.last
        print(lastStory?.timestamp)
        if lastSeen! < (lastStory?.timestamp)! {
            print("bolding")
            title.font = UIFont.boldSystemFont(ofSize: title.font.pointSize)
        } else {
            title.font = UIFont.systemFont(ofSize: title.font.pointSize)
        }
    }
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var storyPreview: UIImageView!

}
