//
//  ViewPickDest.swift
//  Marble
//
//  Created by Daniel Li on 10/16/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import Alamofire

class ViewPickDest: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var navBar: UIView!
    
    weak var delegate : ViewRight?
    
    var active = Bool()
    
    var originalCenterCord: CGFloat = 0.0
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    @IBOutlet weak var tableView: SendGroupTV!
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "GroupTVCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
        
        tableView.dataSource = tableView
        tableView.delegate = tableView
        
        tableView.parent = self
        
        tableView.tableFooterView = UIView()
        
        disableSendButton()
        
        panGesture.delegate = self
        
        originalCenterCord = view.center.x
        
        navBar.addBottomBorderWithColor(color: UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0), width: 1.0)
    }
    
    @IBAction func sendButtonTouchDown(_ sender: Any) {
        sendButton.backgroundColor = Constants.Colors.MarbleBlue.withAlphaComponent(CGFloat(0.8))
    }
    
    @IBAction func sendButtonDragExit(_ sender: Any) {
        sendButton.backgroundColor = Constants.Colors.MarbleBlue
    }
    
    @IBAction func sendButtonDragEnter(_ sender: Any) {
        sendButton.backgroundColor = Constants.Colors.MarbleBlue.withAlphaComponent(CGFloat(0.8))
    }
    
    @IBAction func sendButtonTouchUp(_ sender: Any) {
        sendButton.backgroundColor = Constants.Colors.MarbleBlue
        sendMedia()
    }
    
    func disableSendButton() {
        sendButton.backgroundColor = Constants.Colors.DisabledGray
        sendButton.isEnabled = false
    }
    
    func enableSendButton() {
        sendButton.backgroundColor = Constants.Colors.MarbleBlue
        sendButton.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func backButton(_ sender: Any) {
        active = false
        UIApplication.shared.isStatusBarHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: self.screenWidth, dy: 0)
        }, completion: { (value: Bool) in
            self.view.removeFromSuperview()
        })
    }
    @IBOutlet weak var sendButton: UIButton!

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        UIApplication.shared.isStatusBarHidden = true
        if sender.state == UIGestureRecognizerState.ended {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = self.view.frame.offsetBy(dx: self.screenWidth, dy: 0)
            }, completion: { (value: Bool) in
                self.view.removeFromSuperview()
            })
        }
        let translation = sender.translation(in: self.view)
        if let view = sender.view {
            if view.center.x + translation.x > originalCenterCord {
                view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y)
            }
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isKind(of: UIButton.classForCoder()))!
    }
    
    func sendMedia() {
        let image: UIImage? = delegate?.media
        let groups = getSelectedGroupIds()
        if groups.count <= 0 {
            return
        }
        if let image = image {
            Networker.shared.uploadImage(image: image, groupIds: groups, completionHandler: { response in
                print("UPLOAD DONE")
                NotificationCenter.default.post(name: Constants.Notifications.StoryUploadFinished, object: self)
            })
        }
        self.view.frame = self.view.frame.offsetBy(dx: self.screenWidth, dy: 0)
        UIApplication.shared.statusBarStyle = .default
        self.view.removeFromSuperview()
        active = false
        self.delegate?.mediaSent(groupIds: groups)
    }
    
    func getSelectedGroupIds() -> [Int] {
        var ret = [Int]()
        for (selected, groupId) in SendGroupTV.checked {
            if selected {
                ret.append(groupId!)
            }
        }
        return ret
    }
        

}
