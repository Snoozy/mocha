//
//  MemoriesVC.swift
//  Marble
//
//  Created by Daniel Li on 12/23/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemoriesCell"

class MemoriesVC: UICollectionViewController {
    
    var group: Group?
    var memories: [Clip] = []
    
    var memoryIdx: Int = 0
    
    @IBOutlet weak var vlogifyBtn: UIBarButtonItem!
    
    fileprivate let itemsPerRow: CGFloat = 4
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UINib(nibName: "MemoriesCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        vlogifyBtn.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: Constants.Colors.MarbleBlue], for: .normal)
        
        memories = State.shared.getMemoriesForGroup(groupId: group!.groupId)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullDownRefresh), for: .valueChanged)
        collectionView?.addSubview(refreshControl!)
        collectionView?.alwaysBounceVertical = true
    }
    
    @objc func pullDownRefresh() {
        State.shared.getMyMemories {
            self.refreshControl?.endRefreshing()
            self.memories = State.shared.getMemoriesForGroup(groupId: self.group!.groupId)
            self.collectionView?.reloadData()
        }
    }
    @IBAction func vlogifyBtnPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Vlogify", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let vlogifyVC = vc.topViewController as! VlogifyVC
        vlogifyVC.group = group
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemoriesCell
        
        cell.loadingIndicator.startAnimating()
        
        cell.clip = memories[indexPath.row]
        
        DispatchQueue.main.async {
            cell.clip!.loadMedia { (clip) in
                cell.loadingIndicator.stopAnimating()
                cell.refreshPreview()
            }
        }
        
        return cell
    }
    
    let clipViewNib = UINib(nibName: "ClipView", bundle: nil)
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemoriesCell
        
        let imageViewer = clipViewNib.instantiate(withOwner: nil, options: nil)[0] as! ClipView
        imageViewer.isHidden = true
        imageViewer.commentingEnabled = false
        imageViewer.delegate = self
        imageViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        imageViewer.parentVC = self
        imageViewer.mediaStartClip(clip: cell.clip!)
        memoryIdx = indexPath.row
        
        imageViewer.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.addSubview(imageViewer)
    }

}

extension MemoriesVC : ClipViewDelegate {
    
    func nextClip(_ clipView: ClipView) -> Clip? {
        if memoryIdx < memories.count - 1 {
            memoryIdx += 1
            return memories[memoryIdx]
        } else {
            return nil
        }
    }
    
    func prevClip(_ clipView: ClipView) -> Clip? {
        if memoryIdx < 1 {
            return nil
        } else {
            memoryIdx -= 1
            return memories[memoryIdx]
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
