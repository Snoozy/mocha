//
//  ViewController.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let vRight = ViewRight(nibName: "ViewRight", bundle: nil)
    var vLeft: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AUTH TOKEN: " + (KeychainWrapper.authToken() ?? "NOT FOUND"))
        
        State.shared.authorizing = false

        scrollView.delegate = self
        
        vLeft = UIStoryboard.init(name: "Left", bundle: nil).instantiateInitialViewController()
        
        addChildViewController(vLeft!)
        scrollView.addSubview(vLeft!.view)
        vLeft!.didMove(toParentViewController: self)
        
        addChildViewController(vRight)
        scrollView.addSubview(vRight.view)
        vRight.didMove(toParentViewController: self)
        
        var vRightFrame = vRight.view.frame
        vRightFrame.origin.x = view.frame.width
        vRightFrame.size = CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        vRight.view.frame = vRightFrame
        
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: view.frame.height)
        
        State.shared.refreshUserGroups()
        
        NotificationCenter.default.addObserver(self, selector: #selector(clipUploadStarted), name: Constants.Notifications.ClipUploadStarted, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alertController = UIAlertController(title: nil, message: "Shake Actions", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            })
            alertController.addAction(cancelAction)
            
            let logoutAction = UIAlertAction(title: "Logout", style: .destructive, handler: { action in
                if KeychainWrapper.clearAuthToken() && KeychainWrapper.clearUserID() {
                    OperationQueue.main.addOperation {
                        UIApplication.topViewController()?.present(UIStoryboard(name:"Auth", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
                    }
                }
            })
            alertController.addAction(logoutAction)
            
            let clearCacheAction = UIAlertAction(title: "Clear Cache", style: .destructive, handler: { action in
                do {
                    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let paths = try FileManager.default.contentsOfDirectory(atPath: docDir.path)
                    for file in paths {
                        print("removing: " + file)
                        try FileManager.default.removeItem(atPath: docDir.path + "/" + file)
                    }
                } catch let error {
                    print("error clearing cache: \(error.localizedDescription)")
                }
            })
            alertController.addAction(clearCacheAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if vRight.photoTaken {
            scrollView.contentOffset.x = view.frame.width
        } else {
            if scrollView.bounds.intersects(vRight.view.frame) {
                self.view.window?.windowLevel = UIWindowLevelStatusBar
            } else {
                self.view.window?.windowLevel = UIWindowLevelNormal
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc func clipUploadStarted() {
        DispatchQueue.main.async {
            var style = ToastStyle()
            style.backgroundColor = Constants.Colors.InfoNotifColor
            style.verticalPadding = 10.0
            style.horizontalPadding = 15.0
            self.view.makeToast("Clip will continue uploading in the background", duration: 5.0, position: .top, style: style)
        }
        NotificationCenter.default.post(name: Constants.Notifications.RefreshMainGroupState, object: nil)
    }
    
}
