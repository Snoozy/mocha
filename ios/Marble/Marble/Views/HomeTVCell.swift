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
        vlogDescription.collapsed = true
        vlogDescription.text = nil
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        vlogDescription.collapsed = true
        vlogDescription.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var vidPreviewImage: UIImageView!
    @IBOutlet weak var marbleName: UIButton!
    @IBOutlet weak var vlogDescription: mUILabel!
    @IBOutlet weak var commentBtn: UIButton!
    
    var playIconBtn: UIButton?
    var vlog: Vlog?
    
    @IBAction func commentBtnPressed(_ sender: Any) {
        let modal = VlogCommentsVC(nibName: "VlogComments", bundle: nil)
        modal.vlog = vlog
        let transitionDelegate = DeckTransitioningDelegate()
        modal.modalDelegate = transitionDelegate
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        UIApplication.topViewController()?.present(modal, animated: true, completion: nil)
    }
    
    @IBAction func marbleNamePressed(_ sender: Any) {
        if let group = State.shared.findGroupBy(id: vlog?.groupId ?? 0) {
            let modal = GroupInfoVC(nibName: "GroupInfo", bundle: nil)
            modal.setGroup(group: group)
            let transitionDelegate = DeckTransitioningDelegate()
            modal.transitioningDelegate = transitionDelegate
            modal.modalPresentationStyle = .custom
            UIApplication.topViewController()?.present(modal, animated: true, completion: nil)
        }
    }
    
}
