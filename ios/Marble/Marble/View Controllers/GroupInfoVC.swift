//
//  GroupInfoVC.swift
//  Marble
//
//  Created by Daniel Li on 11/7/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class GroupInfoVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    
    private var group: Group?
    
    @IBOutlet weak var memoriesBtn: UIButton!
    @IBOutlet weak var shareGroupBtn: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var membersTable: MembersInfoTV!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareGroupBtn.layer.borderWidth = 1
        shareGroupBtn.layer.cornerRadius = 4
        shareGroupBtn.layer.borderColor = UIColor.darkGray.cgColor
        shareGroupBtn.setTitleColor(UIColor.darkGray, for: .normal)
        
        UIApplication.shared.statusBarStyle = .lightContent
        groupName.text = group?.name
        
        scrollView.delegate = self
        
        membersTable.register(UINib(nibName: "MemberTVCell", bundle: nil), forCellReuseIdentifier: "MemberCell")
        membersTable.dataSource = membersTable
        membersTable.delegate = membersTable
        membersTable.allowsSelection = false
        
        group?.getMembers(completionHandler: { members in
            self.membersTable.groupMembers = members
            self.membersTable.reloadData()
            self.tableViewHeight.constant = self.membersTable.contentSize.height
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = transitioningDelegate as? DeckTransitioningDelegate {
            if scrollView.contentOffset.y > 0 {
                // Normal behaviour if the `scrollView` isn't scrolled to the top
                scrollView.bounces = true
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    // If the `scrollView` is scrolled to the top but is decelerating
                    // that means a swipe has been performed. The view and
                    // scrollviewʼs subviews are both translated in response to this.
                    view.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.subviews.forEach {
                        $0.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
                    }
                } else {
                    // If the user has panned to the top, the scrollview doesnʼt bounce and
                    // the dismiss gesture is enabled.
                    scrollView.bounces = false
                    delegate.isDismissEnabled = true
                }
            }
        }
    }
    
    @IBAction func donePress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareGroupBtnPress(_ sender: Any) {
        let text = "Join my group on Marble! "
        let webUrl = URL(string: "http://amarbleapp.com/groups/join?g=" + String(group!.code))!
        
        let stuffToShare = [ text, webUrl ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: stuffToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        membersTable.frame.size = membersTable.contentSize
        tableViewHeight.constant = membersTable.contentSize.height
        scrollView.contentSize = CGSize(width: membersTable.contentSize.width, height: membersTable.contentSize.height + 200)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func setGroup(group: Group) {
        self.group = group
    }
    
    func createMarbleQRCode(content: String, color: CIColor, backgroundColor: CIColor = CIColor(red: 1, green: 1, blue: 1)) -> CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        qrFilter.setDefaults()
        qrFilter.setValue(content.data(using: .isoLatin1), forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        
        let coloredQR = colorFilter.outputImage
        
        let scaleX = 100 / (coloredQR?.extent.size.width)!
        let scaleY = 100 / (coloredQR?.extent.size.height)!
        
        return coloredQR?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }

}
