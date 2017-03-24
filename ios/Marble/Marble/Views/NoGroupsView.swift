//
//  NoGroupsView.swift
//  Marble
//
//  Created by Daniel Li on 3/23/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class NoGroupsView: UIView {

    @IBOutlet weak var joinBtn: UIButton!

    @IBAction func joinBtnPress(_ sender: UIButton) {
        OperationQueue.main.addOperation {
            UIApplication.topViewController()?.present(UIStoryboard(name:"AddMarble", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
        }
    }
    
    override func didMoveToWindow() {
        joinBtn.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
        joinBtn.layer.borderWidth = 1
        joinBtn.layer.cornerRadius = 10
        joinBtn.setTitleColor(Constants.Colors.MarbleBlue, for: .normal)
    }
}
