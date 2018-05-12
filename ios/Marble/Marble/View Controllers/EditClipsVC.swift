//
//  EditClipsVC.swift
//  Marble
//
//  Created by Daniel Li on 5/6/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ClipCell"

class EditClipsVC: UICollectionViewController {

    var clips: [Story] = [Story]()
    
    var clipIdx: Int = 0
    
    fileprivate var holdGest: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "MemoriesCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        collectionView?.contentSize = CGSize(width: clips.count * 266, height: 150)
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = CGSize(width: 266, height: 150)
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        }
        
        holdGest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIdx = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView?.beginInteractiveMovementForItem(at: selectedIdx)
        case .changed:
        collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView?.endInteractiveMovement()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        cell.story = clips[indexPath.row]
        
        cell.loadingIndicator.stopAnimating()
        cell.refreshPreview()
        
        return cell
    }
    
    let storyViewNib = UINib(nibName: "StoryView", bundle: nil)

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemoriesCell
        
        let imageViewer = storyViewNib.instantiate(withOwner: nil, options: nil)[0] as! StoryView
        imageViewer.isHidden = true
        imageViewer.commentingEnabled = false
        imageViewer.delegate = self
        
        imageViewer.loopVideo = false
        imageViewer.showOverlay = false
        imageViewer.commentingEnabled = false
        
        imageViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        imageViewer.parentVC = self
        imageViewer.mediaStartStory(story: cell.story!)
        clipIdx = indexPath.row
        
        imageViewer.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.windowLevel = UIWindowLevelStatusBar
        self.view.window?.addSubview(imageViewer)
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        clips.swapAt(sourceIndexPath.item, destinationIndexPath.item)
    }

}

extension EditClipsVC : StoryViewDelegate {
    func nextStory(_ storyView: StoryView) -> Story? {
        if clipIdx < clips.count - 1 {
            clipIdx += 1
            return clips[clipIdx]
        } else {
            return nil
        }
    }
    
    func prevStory(_ storyView: StoryView) -> Story? {
        if clipIdx < 1 {
            return nil
        } else {
            clipIdx -= 1
            return clips[clipIdx]
        }
    }
}
