//
//  EditVlogVC.swift
//  Marble
//
//  Created by Daniel Li on 5/6/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation

private let reuseIdentifier = "ClipCell"

class EditVlogVC: UICollectionViewController {

    var clips: [Clip] = [Clip]()
    var group: Group?
    var clipIdx: Int = 0
    
    var delegate: EditVlogDelegate?
    
    @IBOutlet weak var createBtn: UIBarButtonItem!
    
    fileprivate var holdGest: UILongPressGestureRecognizer!
    
    var descrTextView: UITextView?
    var placeholderLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "MemoriesCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        collectionView?.contentSize = CGSize(width: clips.count * 266, height: 150)
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = CGSize(width: 150, height: 256)
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        }
        
        createBtn.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: Constants.Colors.MarbleBlue], for: .normal)
        
        holdGest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height/4, width: view.frame.width, height: 20))
        textLabel.text = "Hold and drag clips to reorder"
        textLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        textLabel.textColor = UIColor.gray
        textLabel.textAlignment = .center
        bgView.addSubview(textLabel)
        
        descrTextView = UITextView(frame: CGRect(x: 5, y: view.frame.height*(3/4) + 15, width: view.frame.width, height: (view.frame.height/4) - 15))
        descrTextView!.font = UIFont.systemFont(ofSize: 17.0)
        descrTextView!.keyboardType = UIKeyboardType.twitter
        descrTextView!.returnKeyType = UIReturnKeyType.done
        descrTextView!.delegate = self
        
        placeholderLabel = UILabel()
        placeholderLabel!.text = "Add a description. (250 characters max)"
        placeholderLabel?.font = UIFont.italicSystemFont(ofSize: (descrTextView!.font?.pointSize)!)
        placeholderLabel!.sizeToFit()
        descrTextView!.addSubview(placeholderLabel!)
        placeholderLabel?.frame.origin = CGPoint(x: 5, y: (descrTextView!.font?.pointSize)! / 2)
        placeholderLabel!.textColor = UIColor.lightGray
        placeholderLabel!.isHidden = !descrTextView!.text.isEmpty
        
        bgView.addSubview(descrTextView!)
        
        self.collectionView?.backgroundView = bgView
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                print(self.view.frame.origin.y)
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            print(self.view.frame.origin.y)
            self.view.frame.origin.y = 0
        }
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
        if createBtn.title == "Done" {
            descrTextView?.resignFirstResponder()
            createBtn.title = "Create"
            return
        }
        
        if (descrTextView?.text ?? "").count > 250 {
            let alert = UIAlertController(title: "Description must be under 250 characters.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let progHUD = ProgressHUD(text: "Creating Vlog")
        self.view.addSubview(progHUD)
        
        var assets: [AVAsset] = [AVAsset]()
        for clip in clips {
            assets.append(AVAsset(url: clip.videoFileUrl!))
        }
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let vidPath = documentsUrl.appendingPathComponent("vlogified_" + UUID().uuidString + ".mp4")
        
        var builder = TransitionCompositionBuilder(assets: assets, transitionDuration: 0.3)
        let composition = builder?.buildComposition()
        
        let descr = self.descrTextView!.text ?? ""
        
        let session = composition?.makeExportSession(preset: AVAssetExportPreset1280x720, outputURL: vidPath!, outputFileType: AVFileType.mp4)
        session?.exportAsynchronously {
            DispatchQueue.main.async {
                progHUD.removeFromSuperview()
                self.delegate?.videoExportDone(self)
                NotificationCenter.default.post(name: Constants.Notifications.ClipUploadFinished, object: nil)
            }
            print("export complete")
            let attr = try! FileManager.default.attributesOfItem(atPath: vidPath!.path)
            let fileSize = attr[FileAttributeKey.size] as! UInt64
            print("video file size: " + String(describing: fileSize))
            
            let clipIds = self.clips.map { $0.id }
            Networker.shared.uploadVlog(videoUrl: vidPath!, description: descr, clipIds: clipIds, groupId: self.group!.groupId, completionHandler: { response in
                switch response.result {
                case .success(let val):
                    let json = JSON(val)
                    let cacheFilename = vidPath!.deletingLastPathComponent().appendingPathComponent(json["media_id"].stringValue + ".mp4")
                    try! FileManager.default.moveItem(at: vidPath!, to: cacheFilename)
                    self.delegate?.videoUploadDone(self)
                case .failure:
                    print(response.debugDescription)
                }
            })
        }
    }
    
    // MARK: - UICollectionViewDataSource

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
        if (descrTextView?.isFirstResponder)! {
            descrTextView?.resignFirstResponder()
            createBtn.title = "Create"
            return
        }
        
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

// MARK: - ClipViewDelegate
extension EditVlogVC : ClipViewDelegate {
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

// MARK: - UITextViewDelegate
extension EditVlogVC : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        createBtn.title = "Done"
    }
    
}
