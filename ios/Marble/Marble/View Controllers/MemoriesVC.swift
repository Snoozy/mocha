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
    var memories: [Story] = []
    
    fileprivate let itemsPerRow: CGFloat = 4
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UINib(nibName: "MemoriesCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        memories = State.shared.getMemoriesForGroup(groupId: group!.groupId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func donePressed(_ sender: Any) {
        UIApplication.shared.statusBarStyle = .lightContent
        self.dismiss(animated: true, completion: nil)
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
        
        cell.story = memories[indexPath.row]
        
        DispatchQueue.main.async {
            cell.story!.loadMedia { (story) in
                cell.loadingIndicator.stopAnimating()
                cell.refreshPreview()
            }
        }
        
        return cell
    }
    
    let storyViewNib = UINib(nibName: "StoryView", bundle: nil)
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemoriesCell
        
        let imageViewer = storyViewNib.instantiate(withOwner: nil, options: nil)[0] as! StoryView
        imageViewer.isHidden = true
        imageViewer.commentingEnabled = false
        imageViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        imageViewer.parentVC = self
        imageViewer.mediaStartStory(story: cell.story!)
        
        imageViewer.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.addSubview(imageViewer)
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
