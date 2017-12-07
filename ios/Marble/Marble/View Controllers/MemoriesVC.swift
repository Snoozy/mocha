//
//  MemoriesVC.swift
//  Marble
//
//  Created by Daniel Li on 12/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit


class MemoriesVC: UITableViewController {
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func goToCameraBtnPress(_ sender: Any) {
        let parentVC = UIApplication.topViewController() as? ViewController
        let screenWidth = UIScreen.main.bounds.size.width
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: screenWidth, y: 0.0), animated: true)
    }
    
}
