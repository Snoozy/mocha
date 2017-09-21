//
//  ViewController.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let vRight = ViewRight(nibName: "ViewRight", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AUTH TOKEN: " + (KeychainWrapper.authToken() ?? "NONE"))
        
        State.shared.authorizing = false

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
        vRightFrame.size = CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        vRight.view.frame = vRightFrame
        
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: view.frame.height)
        
        State.shared.refreshUserGroups()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if vRight.photoTaken {
            scrollView.contentOffset.x = view.frame.width
        } else {
            if scrollView.bounds.intersects(vRight.view.frame) {
                UIApplication.shared.isStatusBarHidden = true
            } else {
                UIApplication.shared.isStatusBarHidden = false
                UIApplication.shared.statusBarStyle = .default
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.frame = CGRect(x: 0, y: 0, width: (self.view.frame.width), height: self.view.frame.height + 20)
    }

}
