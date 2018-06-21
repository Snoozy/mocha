//
//  ViewRight.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AVKit
import AudioToolbox

class ViewRight: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    var imageMedia : UIImage?
    var videoMediaUrl: URL?
    
    var timer: Timer?
    var timerCount: Int = 0
    
    var loaded: Bool = false
    
    var isRecordingVideo: Bool = false
    var isPlayingVideoPreview: Bool = false
    
    @IBOutlet weak var recordingProgress: UIProgressView!
    
    @IBOutlet weak var cancelButtonOut: UIButton!
    @IBOutlet weak var nextButtonOut: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet var takeVideoLongPress: UILongPressGestureRecognizer!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cameraFlipButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var cancelBtnBotSpace: NSLayoutConstraint!
    @IBOutlet weak var takePhotoBtnBotSpace: NSLayoutConstraint!
    @IBOutlet weak var nextBtnBotSpace: NSLayoutConstraint!
    
    @IBOutlet weak var recordingTimer: UILabel!
    @IBOutlet weak var recordingTimerTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        captureButton = takePhotoButton
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        super.viewDidLoad()
        
        swipeToZoomInverted = true
        
        vPickDest = ViewPickDest(nibName: "ViewPickDest", bundle: nil)
        vPickDest?.view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        vPickDest?.delegate = self
        
        tempImageView.isUserInteractionEnabled = false
        tempImageView.isHidden = true
        
        videoView.isHidden = true
        captionView.isHidden = true
        
        styleLayer(layer: backButton.layer)
        styleLayer(layer: cameraFlipButton.layer)
        styleLayer(layer: flashButton.layer)
        styleLayer(layer: takePhotoButton.layer)
        styleLayer(layer: cancelButtonOut.layer)
        styleLayer(layer: nextButtonOut.layer)
        
        recordingProgress.transform = recordingProgress.transform.scaledBy(x: 1, y: 6)
        recordingProgress.trackTintColor = UIColor.clear
        
        takeVideoLongPress.delegate = self
        
        nextButtonOut.layer.cornerRadius = 5
        
        cancelButtonOut.layer.borderWidth = 1
        cancelButtonOut.layer.cornerRadius = 5
        cancelButtonOut.layer.borderColor = UIColor.white.cgColor
        
        cancelButtonOut.isHidden = true
        nextButtonOut.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.view.isUserInteractionEnabled = true
        
        cameraDelegate = self
        
        if !isIPhoneX() {
            takePhotoBtnBotSpace.constant -= 10
            nextBtnBotSpace.constant -= 20
            cancelBtnBotSpace.constant -= 20
            recordingTimerTop.constant -= 10
            takePhotoButton.layoutIfNeeded()
            nextButtonOut.layoutIfNeeded()
            cancelButtonOut.layoutIfNeeded()
            recordingTimer.layoutIfNeeded()
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        print("photo taken")
        
        tempImageView.image = photo
        tempImageView.isHidden = false
        cancelButtonOut.isHidden = false
        nextButtonOut.isHidden = false
        takePhotoButton.isHidden = true
        tempImageView.isUserInteractionEnabled = true
        UIApplication.shared.isStatusBarHidden = true

        startCaptionEditing()

        mediaType = .image
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        isRecordingVideo = true
        
        backButton.isHidden = true
        flashButton.isHidden = true
        cameraFlipButton.isHidden = true
        
        self.timer = Timer(timeInterval: 0.01, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
        recordingProgress.progress = 0
        timerCount = 0
        recordingProgress.isHidden = false
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        self.setZoomScaleWithLock(to: beginZoomScale)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        let focusGif = UIImage(gifName: "focus")
        let imgView = UIImageView(gifImage: focusGif, manager: SwiftyGifManager.defaultManager, loopCount: 1)
        imgView.frame = CGRect(origin: CGPoint(x: point.x - 42, y: point.y - 42), size: CGSize(width: 84, height: 84))
        swiftyCam.view.addSubview(imgView)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            imgView.removeFromSuperview()
        }
    }
    
    var player: AVPlayer?
    var audioPlayer: AVAudioPlayer?
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        takePhotoButton.isHidden = true
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        
        let audioUrl = url.deletingPathExtension().appendingPathExtension("m4a")
        audioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        
        if isIPhoneX() {
            let topMargin = 40
            let botMargin = 20
            playerLayer.frame = CGRect(x: CGFloat(0), y: CGFloat(topMargin), width: self.view.bounds.width, height: self.view.bounds.height - CGFloat(topMargin + botMargin))
        } else {
            playerLayer.frame = self.view.bounds
        }
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.masksToBounds = true
        videoView.isHidden = false
        videoView.layer.addSublayer(playerLayer)
        videoView.backgroundColor = UIColor.black
        audioPlayer?.prepareToPlay()
        player?.play()
        audioPlayer?.play()
        player?.actionAtItemEnd = .none

        startCaptionEditing()

        videoMediaUrl = url
        mediaType = .video

        cancelButtonOut.isHidden = false
        nextButtonOut.isHidden = false
        cameraFlipButton.isHidden = true

        isPlayingVideoPreview = true

        print("playing")
        return
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        if mediaType == .video {
            player?.seek(to: kCMTimeZero)
            audioPlayer?.currentTime = 0
            player?.play()
            audioPlayer?.play()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    var ignoreQR: Bool = false
    var responder: SCLAlertViewResponder?
    let qrLockQueue = DispatchQueue(label: "com.amarbleapp.QrLockQueue")
    
    override func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        qrLockQueue.sync() {
            if ignoreQR || metadataObjects.count == 0 || isRecordingVideo || isPlayingVideoPreview {
                return
            }
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObject.ObjectType.qr {
                let qrStr = metadataObj.stringValue
                if let qrStr = qrStr {
                    if qrStr.contains("marble.group") {
                        ignoreQR = true
                        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
                        
                        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                        loadingIndicator.hidesWhenStopped = true
                        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                        loadingIndicator.startAnimating();
                        
                        alert.view.addSubview(loadingIndicator)
                        present(alert, animated: true, completion: nil)
                        let groupId = String(qrStr.characters.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)[1])
                        Networker.shared.findGroupBy(code: groupId, completionHandler: { response in
                            self.dismiss(animated: false, completion: nil)
                            switch response.result {
                            case .success:
                                let response = response.result.value as! NSDictionary
                                if let status = response["status"] as? Int {
                                    if status == 0 {  // successfuly found group
                                        
                                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                        
                                        let name = response["group_name"] as! String
                                        let memberCount = response["member_count"] as! Int
                                        let groupCode = response["code"] as! String
                                        
                                        let appearance = SCLAlertView.SCLAppearance(
                                            showCloseButton: false,
                                            hideWhenBackgroundViewIsTapped: true
                                        )
                                        
                                        let alert = SCLAlertView(appearance: appearance)
                                        alert.addButton("Join Marble", action: {
                                            Networker.shared.joinGroup(code: groupCode, completionHandler: { response in
                                                switch response.result {
                                                case .success(let value):
                                                    print("segue")
                                                    let json = JSON(value)
                                                    print(json)
                                                    let group = json["group"]
                                                    let groupId = group["group_id"].int!
                                                    State.shared.addGroup(name: group["name"].stringValue, id: groupId, lastSeen: group["last_seen"].int64 ?? 0, members: group["members"].int ?? 1,  code: group["code"].string ?? String(groupId))
                                                    let parentVC = self.parent as? ViewController
                                                    parentVC?.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                                                    NotificationCenter.default.post(name: Constants.Notifications.ClipUploadFinished, object: self)
                                                case .failure:
                                                    print(response.debugDescription)
                                                    let parentVC = self.parent as? ViewController
                                                    parentVC?.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                                                }
                                            })
                                        })
                                        alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: Constants.Colors.MarbleBlue, action: {
                                            self.responder?.close()
                                        })
                                        self.responder = alert.showInfo(name, subTitle: String(memberCount) + (memberCount > 1 ? " members" : " member"))
                                        self.responder?.setDismissBlock {
                                            self.ignoreQR = false
                                        }
                                    } else {  // error occurred
                                        self.ignoreQR = false
                                    }
                                }
                            case .failure:
                                print(response.debugDescription)
                            }
                            
                        })
                    }
                }
            }
        }
    }
    
    // MARK: Video capture
    
    func startCaptureVideo() {
        print("start recording")
        super.startVideoRecording()
    }
    
    @objc func timerTick() {
        timerCount += 1
        if timerCount > Constants.MaxVideoLength * 100 {
            stopCaptureVideo()
        }
        recordingProgress.progress += 0.001
    }
    
    func stopCaptureVideo() {
        print("stop recording")
        
        timer?.invalidate()
        isRecordingVideo = false
        recordingProgress.isHidden = true
        super.stopVideoRecording()
    }
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var captionView: MediaCaptionView!
    
    @IBOutlet weak var tempImageView: MediaImageView!
    
    func didPressTakePhoto() {
        super.takePhoto()
    }
    
    var photoTaken = Bool()
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if !photoTaken {
            photoTaken = true
            startCaptureVideo()
        } else {
            stopCaptureVideo()
        }
    }
    
    @IBAction func cancelPhoto(_ sender: AnyObject) {
        removeMediaPreview()
        if mediaType == .video {
            deleteVideoFile()
        }
    }
    
    func removeMediaPreview() {
        tempImageView.isHidden = true
        cancelButtonOut.isHidden = true
        nextButtonOut.isHidden = true
        takePhotoButton.isHidden = false
        photoTaken = false
        tempImageView.isUserInteractionEnabled = true
        vPickDest = ViewPickDest(nibName: "ViewPickDest", bundle: nil)
        backButton.isHidden = false
        flashButton.isHidden = false
        cameraFlipButton.isHidden = false
        
        stopCaptionEditing()
                
        // VIDEO PREVIEW
        videoView.isHidden = true
        isPlayingVideoPreview = false
        player?.pause()
        player = nil
        
        mediaType = nil
    }
    
    func deleteVideoFile() {
        do {
            try FileManager.default.removeItem(at: videoMediaUrl!)
            let audioUrl = videoMediaUrl?.deletingPathExtension().appendingPathExtension("m4a")
            try FileManager.default.removeItem(at: audioUrl!)
        } catch {
            print("error deleting video files")
        }
    }
    
    @IBAction func takeVideoAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            photoTaken = true
            startCaptureVideo()
        } else if sender.state == .ended {
            stopCaptureVideo()
        }
    }
    
    var mediaType: MediaType?
    
    var vPickDest: ViewPickDest?
    
    var captionImage: UIImage?
    
    @IBAction func nextButton(_ sender: AnyObject) {
        if mediaType == .image {
            print("image")
            imageMedia = UIImage(view: tempImageView)
        } else if mediaType == .video {
            print("video")
        } else {
            print("error")
            return
        }
        isPlayingVideoPreview = false
        if !captionView.isEmpty() {
            captionImage = captionView.getCaptionImage()
        } else {
            captionImage = nil
        }
        
        vPickDest?.delegate = self
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidth = UIScreen.main.bounds.size.width
        vPickDest?.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        
        if let window = UIApplication.shared.keyWindow {
            window.insertSubview((vPickDest?.view)!, aboveSubview: self.view)
            UIView.animate(withDuration: 0.3, animations: {
                self.vPickDest?.view.frame = (self.vPickDest?.view.frame.offsetBy(dx: -screenWidth, dy: 0))!
            }, completion: { (value: Bool) in
                self.vPickDest?.active = true
                if let postingGroup = self.postingGroup {
                    self.vPickDest?.enableGroups(groups: [postingGroup])
                }
                UIApplication.shared.isStatusBarHidden = false
                UIApplication.shared.statusBarStyle = .default
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    func renderVideoAndUpload(groupIds: [Int], completionHandler: @escaping (DataResponse<Any>) -> ()) {
        if let videoUrl = videoMediaUrl {
            let audioUrl = videoUrl.deletingPathExtension().appendingPathExtension("m4a")
            
            let audioAsset = AVAsset(url: audioUrl)
            let vidAsset = AVURLAsset(url: videoUrl)
            let composition = AVMutableComposition()
            print(videoUrl)
            
            let vTrack = vidAsset.tracks(withMediaType: AVMediaType.video)
            let vidTrack: AVAssetTrack = vTrack[0]
            let vidTimeRange = CMTimeRange(start: kCMTimeZero, duration: vidTrack.timeRange.duration)
            
            let aTracks = audioAsset.tracks(withMediaType: .audio)

            let compositionVidTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
            do {
                try compositionVidTrack.insertTimeRange(vidTimeRange, of: vidTrack, at: kCMTimeZero)
            } catch {
                print("time range insert error")
            }
            
            if aTracks.count > 0 {
                let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
                for audioTrack in aTracks {
                    try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: kCMTimeZero)
                }
            }
            
            let size = vidTrack.naturalSize
            
            let vidLayer = CALayer()
            vidLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
            print(size)
            
            let parentLayer = CALayer()
            parentLayer.frame = CGRect(x : 0, y: 0, width: size.height, height: size.width)
            parentLayer.addSublayer(vidLayer)
            
            if let capImg = captionImage {
                let captionLayer = CALayer()
                captionLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
                captionLayer.contents = capImg.cgImage
                parentLayer.addSublayer(captionLayer)
            }
            
            let layerComposition = AVMutableVideoComposition()
            layerComposition.frameDuration = CMTimeMake(1, 30)
            layerComposition.renderSize = CGSize(width: size.height, height: size.width)
            layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: vidLayer, in: parentLayer)
            
            // instructions
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: composition.duration)
            let videoTrack = composition.tracks(withMediaType: AVMediaType.video)[0]
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            if currentCamera == .front {
                print(vidTrack.preferredTransform)
                layerInstruction.setTransform(vidTrack.preferredTransform.translatedBy(x: -vidTrack.preferredTransform.ty, y: 0), at: kCMTimeZero)
            } else {
                layerInstruction.setTransform(vidTrack.preferredTransform, at: kCMTimeZero)
            }
            instruction.layerInstructions = [layerInstruction]
            layerComposition.instructions = [instruction]
            
            // export file path
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            let vidPath = documentsUrl.appendingPathComponent("rendered_" + videoUrl.lastPathComponent)
            
            let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset960x540)
            
            assetExport?.videoComposition = layerComposition
            assetExport?.outputFileType = AVFileType.mp4
            assetExport?.shouldOptimizeForNetworkUse = true
            assetExport?.outputURL = vidPath
            assetExport?.fileLengthLimit = Constants.MaxVideoSize
            
            assetExport?.exportAsynchronously(completionHandler: {
                print("export complete")
                let attr = try! FileManager.default.attributesOfItem(atPath: vidPath!.path)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                print("video file size: " + String(describing: fileSize))
                
                Networker.shared.uploadClip(videoUrl: vidPath!, groupIds: groupIds, completionHandler: { response in
                    switch response.result {
                    case .success(let val):
                        let json = JSON(val)
                        let cacheFilename = vidPath!.deletingLastPathComponent().appendingPathComponent(json["media_id"].stringValue + ".mp4")
                        try! FileManager.default.moveItem(at: vidPath!, to: cacheFilename)
                        completionHandler(response)
                    case .failure:
                        print(response.debugDescription)
                    }
                })
            })
        }
    }
    
    func imageMediaSent(groupIds: [Int]) {
        removeMediaPreview()
        (self.parent as! ViewController).scrollView.contentOffset.x = 0
        let userInfo = ["group_ids" : groupIds]
        NotificationCenter.default.post(name: Constants.Notifications.ClipPosted, object: self, userInfo: userInfo)
    }
    
    var bgIdentifier: UIBackgroundTaskIdentifier?
    
    func sendVideoMedia(groupIds: [Int]) {
        print("groups: " + String(describing: groupIds))
        removeMediaPreview()
        (self.parent as! ViewController).scrollView.contentOffset.x = 0
        let userInfo = ["group_ids" : groupIds]
        NotificationCenter.default.post(name: Constants.Notifications.ClipPosted, object: self, userInfo: userInfo)
        
        bgIdentifier = UIApplication.shared.beginBackgroundTask {
            if let bgIdentifier = self.bgIdentifier {
                UIApplication.shared.endBackgroundTask(bgIdentifier)
            }
        }
        renderVideoAndUpload(groupIds: groupIds, completionHandler: { response in
            print("VIDEO UPLOAD DONE")
            print(response.debugDescription)
            NotificationCenter.default.post(name: Constants.Notifications.ClipUploadFinished, object: self)
            if let bgIdentifier = self.bgIdentifier {
                UIApplication.shared.endBackgroundTask(bgIdentifier)
            }
        })
    }
    
    @IBAction func toggleCameraBtnPress(_ sender: UIButton) {
        switchCamera()
    }
    
    @IBAction func flashToggleBtnPress(_ sender: UIButton) {
        if !flashEnabled {
            sender.setImage(UIImage(named: "flash-on"), for: .normal)
            flashEnabled = true
        } else {
            sender.setImage(UIImage(named: "flash-off"), for: .normal)
            flashEnabled = false
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        let parentVC = parent as? ViewController
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
    }
    
    func resetState() {
        clearPostingGroup()
    }
    
    var postingGroup: Group?
    
    func postToGroup(group: Group) {
        postingGroup = group
    }
    
    @IBAction func cameraRollBtnPress(_ sender: Any) {
        print("camera roll")
        
    }
    
    func clearPostingGroup() {
        postingGroup = nil
    }
    
    func startCaptionEditing() {
        captionView.configure()
        captionView.isHidden = false
        captionView.isUserInteractionEnabled = true
    }
    
    func stopCaptionEditing() {
        captionView.isUserInteractionEnabled = false
        captionView.isHidden = true
    }
}

extension ViewRight : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            processSelectedImage(img: possibleImage)
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            processSelectedImage(img: possibleImage)
        } else if let possibleVideo = info["UIImagePickerControllerMediaURL"] as? NSURL {
            processSelectedVideo(vid: possibleVideo)
        } else {
            return
        }
        
        dismiss(animated: true)

    }
    
    func processSelectedImage(img: UIImage) {
        print(img.size)
    }
    
    func processSelectedVideo(vid: NSURL) {
        print(vid)
    }
}
