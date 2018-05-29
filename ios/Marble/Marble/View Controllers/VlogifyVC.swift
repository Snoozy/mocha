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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.collectionView?.allowsMultipleSelection = true
        
        nextBarBtn.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.black], for: .normal)
        nextBarBtn.title = ""

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "MemoriesCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        memories = State.shared.getMemoriesForGroup(groupId: group!.groupId)
        
        collectionView?.alwaysBounceVertical = true
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
        cell.numberLabel.text = String(clipsSelection.count + 1)
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
        if segue.identifier == "EditClips" {
            if let destVC = segue.destination as? EditClipsVC {
                destVC.clips = clipsSelection.map({ (idx) in
                    self.memories[idx.row]
                })
                destVC.group = group
            }
        }
    }
    
}

extension VlogifyVC : UICollectionViewDelegateFlowLayout {
    
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

