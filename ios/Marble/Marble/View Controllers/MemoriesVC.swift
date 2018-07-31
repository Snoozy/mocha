//
//  MemoriesVC.swift
//  Marble
//
//  Created by Daniel Li on 12/23/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemoriesCell"

class MemoriesVC : UICollectionViewController, UIGestureRecognizerDelegate {
    
    var group: Group?
    var clips: [Clip] = []
    
    var memoryIdx: Int = 0
    
    @IBOutlet weak var vlogifyBtn: UIBarButtonItem!
    
    fileprivate let itemsPerRow: CGFloat = 4
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

    var refreshControl: UIRefreshControl?
    
    var vlogifyVC: VlogifyVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UINib(nibName: "MemoriesCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        vlogifyBtn.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: Constants.Colors.MarbleBlue], for: .normal)
        
        clips = State.shared.getClips(forGroup: self.group!.groupId)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: .valueChanged)
        collectionView?.addSubview(refreshControl!)
        collectionView?.alwaysBounceVertical = true
        
        let edgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgeSwiped(_:)))
        edgeGestureRecognizer.edges = UIRectEdge.left
        edgeGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(edgeGestureRecognizer)
    }
    
    @objc func pullDownRefresh() {
        State.shared.refreshClips {
            self.refreshControl?.endRefreshing()
            self.clips = State.shared.getClips(forGroup: self.group!.groupId)
            self.collectionView?.reloadData()
        }
    }
    @IBAction func vlogifyBtnPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Vlogify", bundle: nil).instantiateInitialViewController() as! UINavigationController
        vlogifyVC = vc.topViewController as? VlogifyVC
        vlogifyVC!.group = group
        vlogifyVC!.editVlogDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func edgeSwiped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clips.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemoriesCell
        
        cell.loadingIndicator.startAnimating()
        
        cell.clip = clips[indexPath.row]
        
        DispatchQueue.global(qos: .userInitiated).async {
            cell.clip!.loadMedia { (clip) in
                DispatchQueue.main.async {
                    cell.loadingIndicator.stopAnimating()
                    cell.refreshPreview()
                }
            }
        }
        
        return cell
    }
    
    let clipViewNib = UINib(nibName: "ClipView", bundle: nil)
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemoriesCell
        
        let clipViewer = clipViewNib.instantiate(withOwner: nil, options: nil)[0] as! ClipView
        clipViewer.isHidden = true
        clipViewer.commentingEnabled = false
        clipViewer.delegate = self
        clipViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        clipViewer.parentVC = self
        clipViewer.mediaStartClip(clip: cell.clip!)
        memoryIdx = indexPath.row
        
        clipViewer.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.addSubview(clipViewer)
    }

}

extension MemoriesVC : ClipViewDelegate {
    
    func nextClip(_ clipView: ClipView) -> Clip? {
        if memoryIdx < clips.count - 1 {
            memoryIdx += 1
            return clips[memoryIdx]
        } else {
            return nil
        }
    }
    
    func prevClip(_ clipView: ClipView) -> Clip? {
        if memoryIdx < 1 {
            return nil
        } else {
            memoryIdx -= 1
            return clips[memoryIdx]
        }
    }
    
}


extension MemoriesVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.bottom
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = (sectionInsets.left) * (itemsPerRow + 1)
        let availableWidth = UIScreen.main.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

}

extension MemoriesVC : EditVlogDelegate {
    
    func videoExportDone(_ editVlogVC: EditVlogVC) {
        var style = ToastStyle()
        style.backgroundColor = Constants.Colors.InfoNotifColor
        style.verticalPadding = 10.0
        style.horizontalPadding = 15.0
        self.navigationController?.view.makeToast("Vlog will continue uploading in the background.", duration: 5.0, position: .top, style: style)
        vlogifyVC?.dismiss(animated: true, completion: nil)
    }
    
}
