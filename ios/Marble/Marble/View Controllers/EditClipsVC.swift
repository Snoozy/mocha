//
//  EditClipsVC.swift
//  Marble
//
//  Created by Daniel Li on 5/6/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation

private let reuseIdentifier = "ClipCell"

class EditClipsVC: UICollectionViewController {

    var clips: [Clip] = [Clip]()
    
    var clipIdx: Int = 0
    @IBOutlet weak var createBtn: UIBarButtonItem!
    
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
    
    @IBAction func createBtnPressed(_ sender: Any) {
        let progHUD = ProgressHUD(text: "Creating Vlog")
        self.view.addSubview(progHUD)
        
        var assets: [AVAsset] = [AVAsset]()
        for clip in clips {
            assets.append(AVAsset(url: clip.videoFileUrl!))
        }
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let vidPath = documentsUrl.appendingPathComponent("vlogified_" + UUID().uuidString)
        
        var builder = TransitionCompositionBuilder(assets: assets, transitionDuration: 0.3)
        let composition = builder?.buildComposition()
        
        let session = composition?.makeExportSession(preset: AVAssetExportPreset1280x720, outputURL: vidPath!, outputFileType: AVFileType.mp4)
        session?.exportAsynchronously {
            progHUD.removeFromSuperview()
        }
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
        
        cell.clip = clips[indexPath.row]
        
        cell.loadingIndicator.stopAnimating()
        cell.refreshPreview()
        
        return cell
    }
    
    let clipViewNib = UINib(nibName: "ClipView", bundle: nil)

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemoriesCell
        
        let imageViewer = clipViewNib.instantiate(withOwner: nil, options: nil)[0] as! ClipView
        imageViewer.isHidden = true
        imageViewer.commentingEnabled = false
        imageViewer.delegate = self
        
        imageViewer.loopVideo = false
        imageViewer.showOverlay = false
        imageViewer.commentingEnabled = false
        
        imageViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        imageViewer.parentVC = self
        imageViewer.mediaStartClip(clip: cell.clip!)
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

extension EditClipsVC : ClipViewDelegate {
    func nextClip(_ clipView: ClipView) -> Clip? {
        if clipIdx < clips.count - 1 {
            clipIdx += 1
            return clips[clipIdx]
        } else {
            return nil
        }
    }
    
    func prevClip(_ clipView: ClipView) -> Clip? {
        if clipIdx < 1 {
            return nil
        } else {
            clipIdx -= 1
            return clips[clipIdx]
        }
    }
}
