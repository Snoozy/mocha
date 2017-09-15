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

class ViewRight: UIViewController, UIImagePickerControllerDelegate, UINavigationBarDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession : AVCaptureSession?
    var photoOutput : AVCapturePhotoOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var camera: AVCaptureDevice?
    var audioDeviceInput: AVCaptureDeviceInput?
    var videoFileOut: AVCaptureMovieFileOutput?
    
    var cameraInput: AVCaptureDeviceInput?
    
    var imageMedia : UIImage?
    var videoMediaUrl: URL?
    
    var timer: Timer?
    var timerCount: Int = 0
    
    var loaded: Bool = false
    
    var isRecordingVideo: Bool = false
    var isPlayingVideoPreview: Bool = false
    
    @IBOutlet weak var recordingProgress: UIProgressView!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cancelButtonOut: UIButton!
    @IBOutlet weak var nextButtonOut: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet var takeVideoLongPress: UILongPressGestureRecognizer!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cameraFlipButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let panGest = UIPanGestureRecognizer(target: self, action: #selector(cameraViewPan(_:)))
        panGest.delegate = self
        self.parent?.view.isUserInteractionEnabled = true
        self.parent?.view.addGestureRecognizer(panGest)
        
        takeVideoLongPress.delegate = self
        
        nextButtonOut.layer.cornerRadius = 5
        
        cancelButtonOut.layer.borderWidth = 1
        cancelButtonOut.layer.cornerRadius = 5
        cancelButtonOut.layer.borderColor = UIColor.white.cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initCameraView()
    }
    
    func initCameraView() {
        if loaded {
            return
        }
        self.loaded = true

        
        captureSession = AVCaptureSession()
        captureSession?.automaticallyConfiguresApplicationAudioSession = false
        captureSession?.usesApplicationAudioSession = true
        
        guard let captureSession = self.captureSession else {
            print("Error making capture session")
            return;
        }
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        self.camera = self.defaultBackCamera()
        self.audioDeviceInput = try? AVCaptureDeviceInput(device: getAudioDevice())
        
        if let camera = self.camera {
            self.initCamera(with: camera, captureSession: captureSession)
        }
        
        self.previewLayer?.frame = self.cameraView.bounds
        self.cancelButtonOut.isHidden = true
        self.nextButtonOut.isHidden = true
        self.takePhotoButton.isHidden = false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 5.0
    var lastZoomFactor: CGFloat = 1.0
    
    // Return zoom value between the minimum and maximum zoom values
    func minMaxZoom(_ factor: CGFloat, device: AVCaptureDevice) -> CGFloat {
        return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
    }
    
    func update(device: AVCaptureDevice, scale factor: CGFloat) {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.videoZoomFactor = factor
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        
        guard let device = camera else { return }
        
        let newScaleFactor = minMaxZoom(sender.scale * lastZoomFactor, device: device)
        
        switch sender.state {
        case .began: fallthrough
        case .changed: update(device: device, scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor, device: device)
            update(device: device, scale: lastZoomFactor)
        default: break
        }
    }
    
    @IBAction func cameraViewPan(_ sender: UIPanGestureRecognizer) {
        if isRecordingVideo {
            let maxLength = UIScreen.main.bounds.height * 0.6
            
            let translation = sender.translation(in: self.view)
            let deltaX = -translation.y
            let zoomScale = min(deltaX / maxLength, 1.0)
            
            let deltaZoom = maximumZoom - minimumZoom
            
            guard let device = camera else { return }
            
            let newScaleFactor = minMaxZoom(lastZoomFactor + (zoomScale * deltaZoom), device: device)
            
            switch sender.state {
            case .began: fallthrough
            case .changed: update(device: device, scale: newScaleFactor)
            case .ended:
                lastZoomFactor = minMaxZoom(newScaleFactor, device: device)
                update(device: device, scale: lastZoomFactor)
            default: break
            }
        }
    }
    
    func getAudioDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    }
    
    func defaultBackCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDuoCamera,
                                                      mediaType: AVMediaTypeVideo,
                                                      position: .back) {
            return device
        } else if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                                             mediaType: AVMediaTypeVideo,
                                                             position: .back) {
            return device
        } else {
            return nil
        }
    }
    
    func defaultFrontCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
            return device
        } else {
            return nil
        }
    }
    
    @IBAction func cameraDoubleTapped(_ sender: Any) {
        toggleCameraPosition()
    }
    
    func toggleCameraPosition() {
        captureSession?.beginConfiguration()
        captureSession?.removeInput(cameraInput!)
        if camera?.position == .front {
            camera = defaultBackCamera()
        } else {
            camera = defaultFrontCamera()
        }
        if let camera = camera {
            cameraInput = try! AVCaptureDeviceInput(device: camera)
            if (captureSession?.canAddInput(cameraInput))! {
                captureSession?.addInput(cameraInput)
            }
        }
        captureSession?.commitConfiguration()
    }
    
    func initCamera(with device: AVCaptureDevice?, captureSession: AVCaptureSession) {
        do {
            cameraInput = try AVCaptureDeviceInput(device: device)
            captureSession.beginConfiguration()
            if captureSession.inputs.count > 0 {
                print("camera already initialized")
                return
            }
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                if captureSession.outputs.count == 0 {
                    let captureMetadataOutput = AVCaptureMetadataOutput()
                    if captureSession.canAddOutput(captureMetadataOutput) {
                        print("add qr code detection")
                        captureSession.addOutput(captureMetadataOutput)
                        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        print("types: \(captureMetadataOutput.availableMetadataObjectTypes)")
                        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                    }
                    photoOutput = AVCapturePhotoOutput()
                    if captureSession.canAddOutput(photoOutput!) {
                        print("photo output added")
                        captureSession.addOutput(self.photoOutput!)
                    }
                }
            }
            captureSession.commitConfiguration()
            if !captureSession.isRunning {
                captureSession.startRunning()
                self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                self.previewLayer!.connection.videoOrientation = .portrait
                self.previewLayer!.frame = cameraView.layer.bounds
                self.cameraView.layer.addSublayer(self.previewLayer!)
                captureSession.beginConfiguration()
                videoFileOut = AVCaptureMovieFileOutput()
                if (captureSession.canAddOutput(videoFileOut)) {
                    print("video output added")
                    captureSession.addOutput(videoFileOut)
                    if (videoFileOut?.connection(withMediaType: AVMediaTypeVideo).isVideoStabilizationSupported)! {
                        print("enable video stabilization")
                        videoFileOut?.connection(withMediaType: AVMediaTypeVideo).preferredVideoStabilizationMode = .cinematic
                    }
                }
                captureSession.commitConfiguration()
                print("started capture session")
            }
            print("capture session: \(captureSession.outputs)")
        } catch {
            print("Error accessing input device")
            return;
        }

    }
    
    @IBAction func cameraTouched(_ sender: UITapGestureRecognizer) {
        ignoreQR = false
        if (camera?.isFocusModeSupported(.autoFocus))! {
            let screenSize = cameraView.bounds.size
            let touchPoint = sender.location(in: cameraView)
            let x = touchPoint.x / screenSize.height
            let y = touchPoint.y / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
        
            if let device = camera {
                do {
                    try device.lockForConfiguration()
            
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .continuousAutoExposure
                    device.unlockForConfiguration()
                } catch {
                    
                }
            }
        }
    }
    
    var ignoreQR: Bool = false
    var responder: SCLAlertViewResponder?
    let qrLockQueue = DispatchQueue(label: "com.amarbleapp.QrLockQueue")
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        qrLockQueue.sync() {
            if ignoreQR || metadataObjects == nil || metadataObjects.count == 0 || isRecordingVideo || isPlayingVideoPreview {
                return
            }
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                let qrStr = metadataObj.stringValue
                if let qrStr = qrStr {
                    if qrStr.contains("marble.group") {
                        ignoreQR = true
                        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
                        
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
                                        let groupId = response["group_id"] as! Int
                                        
                                        let appearance = SCLAlertView.SCLAppearance(
                                            showCloseButton: false,
                                            hideWhenBackgroundViewIsTapped: true
                                        )
                                        
                                        let alert = SCLAlertView(appearance: appearance)
                                        alert.addButton("Join Marble", action: {
                                            Networker.shared.joinGroup(id: groupId, completionHandler: { response in
                                                switch response.result {
                                                case .success(let value):
                                                    print("segue")
                                                    let json = JSON(value)
                                                    print(json)
                                                    let group = json["group"]
                                                    let groupId = group["group_id"].int!
                                                    State.shared.addGroup(name: group["name"].stringValue, id: groupId, lastSeen: group["last_seen"].int64 ?? 0, members: group["members"].int ?? 1)
                                                    let parentVC = self.parent as? ViewController
                                                    parentVC?.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                                                    NotificationCenter.default.post(name: Constants.Notifications.StoryUploadFinished, object: self)
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
    
    var audioSessionCatOpts: AVAudioSessionCategoryOptions?
    var audioSessionCat: String?
    var audioSessionInit: Bool = false
    var audioSessionOriginal: AVAudioSession?
    
    func startCaptureVideo() {
        print("start recording")
        
        isRecordingVideo = true
        
        backButton.isHidden = true
        flashButton.isHidden = true
        cameraFlipButton.isHidden = true
        
//        try! AVAudioSession.sharedInstance().setActive(true)
        print("configuring audio session")
        let audioSession = AVAudioSession.sharedInstance()
        audioSessionCatOpts = audioSession.categoryOptions
        audioSessionCat = audioSession.category
        print("audio: \(audioSession.category), \(audioSession.mode), \(audioSession.categoryOptions)")
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
                                                        with: [.mixWithOthers, .allowBluetoothA2DP, .allowAirPlay])
        try! audioSession.setActive(true)
        captureSession?.beginConfiguration()
        if (captureSession?.canAddInput(audioDeviceInput!))! {
            captureSession?.addInput(audioDeviceInput!)
        }
        captureSession?.commitConfiguration()
//        captureSession?.beginConfiguration()
//        if let audioDeviceInput = audioDeviceInput {
//            if (captureSession?.canAddInput(audioDeviceInput))! {
//                captureSession?.addInput(audioDeviceInput)
//            }
//        }
//        captureSession?.commitConfiguration()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent(randomString(length: 10) + ".mp4")
        
        if !(captureSession?.isRunning)! {
            print("start capture video start capture session running")
            captureSession?.startRunning()
        }
        
        if flashActive && (camera?.isTorchModeSupported(.on) ?? false) {
            try! camera?.lockForConfiguration()
            camera?.torchMode = .on
            camera?.unlockForConfiguration()
        }
        
        if camera?.position == .front && (videoFileOut?.connection(withMediaType: AVMediaTypeVideo).isVideoMirroringSupported) ?? false {
            videoFileOut?.connection(withMediaType: AVMediaTypeVideo).isVideoMirrored = true
        }
        
        videoFileOut?.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
        self.timer = Timer(timeInterval: 0.01, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
        recordingProgress.progress = 0
        timerCount = 0
        recordingProgress.isHidden = false
    }
    
    func timerTick() {
        timerCount += 1
        if timerCount > Constants.MaxVideoLength * 100 {
            stopCaptureVideo()
        }
        recordingProgress.progress += 0.001
    }
    
    func stopCaptureVideo() {
        print("stop recording")
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryAmbient, with: [.mixWithOthers, .allowAirPlay])

        captureSession?.beginConfiguration()
        print("removing audio device input")
        captureSession?.removeInput(audioDeviceInput)
        captureSession?.commitConfiguration()
        
        print("reverting audio session: \(audioSessionCat)")
        videoFileOut?.stopRecording()
        
        if camera?.position == .back {
            try! camera?.lockForConfiguration()
            camera?.torchMode = .off
            camera?.unlockForConfiguration()
        }
        
        timer?.invalidate()
        isRecordingVideo = false
        recordingProgress.isHidden = true
        
    }
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var captionView: MediaCaptionView!
    
    var playerLooper: AVPlayerLooper?
    var player: AVQueuePlayer?
    
    
    // VIDEO CAPTURE DELEGATE CALLBACK
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        takePhotoButton.isHidden = true
        
        if error != nil {
            print(error)
        }
        
        player = AVQueuePlayer()
        let playerLayer = AVPlayerLayer(player: player)
        let playerItem = AVPlayerItem(url: outputFileURL)
        playerLooper = AVPlayerLooper(player: player!, templateItem: playerItem)
        
        playerLayer.frame = self.cameraView.bounds
        videoView.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoView.isHidden = false
        player?.play()
        
        captionView.configure()
        captionView.clearCaption()
        captionView.isHidden = false
        
        videoMediaUrl = outputFileURL
        mediaType = .video

        cancelButtonOut.isHidden = false
        nextButtonOut.isHidden = false
        cameraFlipButton.isHidden = true
        
        isPlayingVideoPreview = true

        print("playing")
        return
    }
    
    @IBOutlet weak var tempImageView: MediaImageView!
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        if flashActive {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // IMAGE CAPTURE DELEGATE CALLBACK
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            var image: UIImage? = UIImage(data: dataImage)
            if camera?.position == .front {
                image = UIImage(cgImage: (image?.cgImage!)!, scale: (image?.scale)!, orientation: .leftMirrored)
            }
            tempImageView.image = image
            tempImageView.isHidden = false
            cancelButtonOut.isHidden = false
            nextButtonOut.isHidden = false
            takePhotoButton.isHidden = true
            tempImageView.isUserInteractionEnabled = true
            UIApplication.shared.isStatusBarHidden = true
            
            captionView.configure()
            captionView.clearCaption()
            captionView.isHidden = false
//            tempImageView.clearCaption()
            
            mediaType = .image
        } else {
            print("Error processing image.")
        }
    }
    
    func didPressTakePhoto() {
        if let videoConnection = photoOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            capturePhoto()
        }
    }
    
    var photoTaken = Bool()
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        photoTaken = true
        didPressTakePhoto()
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
        
        captionView.isHidden = true
        
        update(device: camera!, scale: minimumZoom)
        lastZoomFactor = minimumZoom
        
        // VIDEO PREVIEW
        videoView.isHidden = true
        playerLooper?.disableLooping()
        isPlayingVideoPreview = false
        player?.pause()
        player = nil
        playerLooper = nil
        
        mediaType = nil
    }
    
    func deleteVideoFile() {
        try! FileManager.default.removeItem(at: videoMediaUrl!)
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
            captionImage = UIImage(view: captionView)
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
                UIApplication.shared.isStatusBarHidden = false
                UIApplication.shared.statusBarStyle = .default
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    func renderVideoAndUpload(groupIds: [Int], completionHandler: @escaping (DataResponse<Any>) -> ()) {
        if let videoUrl = videoMediaUrl {
            let vidAsset = AVURLAsset(url: videoUrl)
            let composition = AVMutableComposition()
            print(videoUrl)
            
            let vTrack = vidAsset.tracks(withMediaType: AVMediaTypeVideo)
            let vidTrack: AVAssetTrack = vTrack[0]
            let vidTimeRange = CMTimeRange(start: kCMTimeZero, duration: vidTrack.timeRange.duration)
            
            let aTracks = vidAsset.tracks(withMediaType: AVMediaTypeAudio)

            let compositionVidTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
            do {
                try compositionVidTrack.insertTimeRange(vidTimeRange, of: vidTrack, at: kCMTimeZero)
            } catch {
                print("time range insert error")
            }
            
            if aTracks.count > 0 {
                let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
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
            
            let layerComposition = AVMutableVideoComposition()
            layerComposition.frameDuration = CMTimeMake(1, 30)
            layerComposition.renderSize = CGSize(width: size.height, height: size.width)
            layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: vidLayer, in: parentLayer)
            
            // instructions
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: composition.duration)
            let videoTrack = composition.tracks(withMediaType: AVMediaTypeVideo)[0]
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            if camera?.position == .front {
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
            
            
            let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720)
            
            assetExport?.videoComposition = layerComposition
            assetExport?.outputFileType = AVFileTypeMPEG4
            assetExport?.shouldOptimizeForNetworkUse = true
            assetExport?.outputURL = vidPath
            assetExport?.fileLengthLimit = Constants.MaxVideoSize
            
            // IDK WHY THIS DOESN'T WORK. CAUSES FRONT CAMERA RECORDING TO CRASH
            //assetExport?.canPerformMultiplePassesOverSourceMediaData = true
            
            assetExport?.exportAsynchronously(completionHandler: {
                print("export complete")
                let attr = try! FileManager.default.attributesOfItem(atPath: vidPath!.path)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                print("video file size: " + String(describing: fileSize))
                
//                let player = AVPlayer(url: vidPath!)
//                let playerController = AVPlayerViewController()
//                playerController.player = player
//                self.present(playerController, animated: true) {
//                    player.play()
//                }
                
                Networker.shared.uploadVideo(videoUrl: vidPath!, caption: self.captionImage, groupIds: groupIds, completionHandler: { response in
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
        NotificationCenter.default.post(name: Constants.Notifications.StoryPosted, object: self, userInfo: userInfo)
    }
    
    func sendVideoMedia(groupIds: [Int]) {
        print("groups: " + String(describing: groupIds))
        removeMediaPreview()
        (self.parent as! ViewController).scrollView.contentOffset.x = 0
        let userInfo = ["group_ids" : groupIds]
        NotificationCenter.default.post(name: Constants.Notifications.StoryPosted, object: self, userInfo: userInfo)
        renderVideoAndUpload(groupIds: groupIds, completionHandler: { response in
            print("VIDEO UPLOAD DONE")
            print(response.debugDescription)
            NotificationCenter.default.post(name: Constants.Notifications.StoryUploadFinished, object: self)
        })
    }
    
    @IBAction func toggleCameraBtnPress(_ sender: UIButton) {
        toggleCameraPosition()
    }
    
    var flashActive = false
    
    @IBAction func flashToggleBtnPress(_ sender: UIButton) {
        if !flashActive {
            sender.setImage(UIImage(named: "flash-on"), for: .normal)
            flashActive = true
        } else {
            sender.setImage(UIImage(named: "flash-off"), for: .normal)
            flashActive = false
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        let parentVC = parent as? ViewController
        parentVC?.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
    }
        
}
