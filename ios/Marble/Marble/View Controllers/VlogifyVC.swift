//
//  VlogifyVC.swift
//  Marble
//
//  Created by Daniel Li on 4/21/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ClipCell"

class VlogifyVC: UICollectionViewController {

    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 0.0, right: 5.0)

    @IBOutlet weak var nextBarBtn: UIBarButtonItem!
    
    var group: Group?
    var memories: [Clip] = []
    
    var editVlogDelegate: EditVlogDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.collectionView?.allowsMultipleSelection = true
        
        nextBarBtn.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: Constants.Colors.MarbleBlue], for: .normal)
        nextBarBtn.title = ""

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "MemoriesCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        let clips = State.shared.getClips(forGroup: self.group!.groupId)
        for clip in clips {
            memories.append(clip)
        }
        
        collectionView?.alwaysBounceVertical = true
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.delaysTouchesBegan = true
        lpgr.minimumPressDuration = 0.3
        self.collectionView?.addGestureRecognizer(lpgr)
        
        let headerView = UIView(frame: CGRect(x: 0, y: -50, width: self.view.frame.width, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        label.text = "Hold to preview. Tap to select."
        label.alpha = 0.7
        label.textAlignment = .center
        headerView.addSubview(label)
        collectionView?.addSubview(headerView)
        collectionView?.contentInset.top = 50
        
    }
    
    @objc func pullDownRefresh() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        cell.clip = memories[indexPath.row]
        
        cell.loadingIndicator.stopAnimating()
        
        DispatchQueue.main.async {
            cell.clip!.loadMedia { (clip) in
                cell.refreshPreview()
                cell.loadingIndicator.stopAnimating()
            }
        }
        return cell
    }
    
    var clipsSelection: [IndexPath] = [IndexPath]()
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemoriesCell
        
        cell.alpha = 0.8
        cell.numberLabel.isHidden = false
        cell.numberLabel.text = String("✓")
        clipsSelection.append(indexPath)
        
        if clipsSelection.count > 0 {
            nextBarBtn.title = "Next"
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemoriesCell
        
        cell.alpha = 1.0
        cell.numberLabel.isHidden = true
        if let idx = clipsSelection.index(of: indexPath) {
            clipsSelection.remove(at: idx)
        }
        
        if clipsSelection.count < 1 {
            nextBarBtn.title = ""
        }
    }
    
    @IBAction func doneBtnPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditVlog" {
            if let destVC = segue.destination as? EditVlogVC {
                destVC.clips = clipsSelection.map({ (idx) in
                    self.memories[idx.row]
                })
                destVC.group = group
                destVC.delegate = self.editVlogDelegate
            }
        }
    }
    
    let clipViewNib = UINib(nibName: "ClipView", bundle: nil)
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView?.indexPathForItem(at: p) {
            let cell = self.collectionView?.cellForItem(at: indexPath) as! MemoriesCell
            
            let clipViewer = clipViewNib.instantiate(withOwner: nil, options: nil)[0] as! ClipView
            clipViewer.isHidden = true
            clipViewer.commentingEnabled = false
            clipViewer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            clipViewer.parentVC = self
            clipViewer.mediaStartClip(clip: cell.clip!)
            
            clipViewer.window?.windowLevel = UIWindowLevelStatusBar
            self.view.window?.windowLevel = UIWindowLevelStatusBar
            self.view.window?.addSubview(clipViewer)
        } else {
            print("couldn't find index path")
        }
    }
    
}

extension VlogifyVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = (sectionInsets.right) * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
}
