//
//  ViewController.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let vRight = ViewRight(nibName: "ViewRight", bundle: nil)
    
    override func viewDidLoad() {
        print("AUTH TOKEN: " + (KeychainWrapper.authToken() ?? "NONE"))
        super.viewDidLoad()

        scrollView.delegate = self
        
        let leftStory = UIStoryboard.init(name: "Left", bundle: nil).instantiateInitialViewController()
        
        addChildViewController(leftStory!)
        scrollView.addSubview((leftStory?.view)!)
        leftStory?.didMove(toParentViewController: self)
        
        addChildViewController(vRight)
        scrollView.addSubview(vRight.view)
        vRight.didMove(toParentViewController: self)
        
        var vRightFrame = vRight.view.frame
        vRightFrame.origin.x = view.frame.width
        vRight.view.frame = vRightFrame
        
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: view.frame.height)
        
        State.shared.refreshUserGroups()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if vRight.photoTaken {
            scrollView.contentOffset.x = view.frame.width
        } else {
            if scrollView.bounds.intersects(vRight.view.frame) {
                UIApplication.shared.statusBarStyle = .lightContent
            } else {
                UIApplication.shared.statusBarStyle = .default
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }

}
