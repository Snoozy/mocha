//
//  ViewRight.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewRight: UIViewController, UIImagePickerControllerDelegate, UINavigationBarDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {

    var captureSession : AVCaptureSession?
    var photoOutput : AVCapturePhotoOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var camera: AVCaptureDevice?
    var audioDevice: AVCaptureDevice?
    var videoFileOut: AVCaptureMovieFileOutput?
    
    var cameraInput: AVCaptureDeviceInput?
    
    var imageMedia : UIImage?
    var videoMediaUrl: URL?
    
    var loaded: Bool = false
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cancelButtonOut: UIButton!
    @IBOutlet weak var nextButtonOut: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
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
        
        styleButton(button: backButton)
        styleButton(button: cameraFlipButton)
        styleButton(button: flashButton)
        styleButton(button: takePhotoButton)
        styleButton(button: cancelButtonOut)
        styleButton(button: nextButtonOut)
        
    }
    
    func styleButton(button: UIButton) {
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 1.5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("right")
        return .lightContent
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

        
        self.captureSession = AVCaptureSession()
        
        guard let captureSession = self.captureSession else {
            print("Error making capture session")
            return;
        }
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        self.camera = self.defaultBackCamera()
        self.audioDevice = getAudioDevice()
        
        if let camera = self.camera {
            self.initCamera(with: camera, audio: audioDevice, captureSession: captureSession)
        }
        
        self.previewLayer?.frame = self.cameraView.bounds
        self.cancelButtonOut.isHidden = true
        self.nextButtonOut.isHidden = true
        self.takePhotoButton.isHidden = false
        
    }
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        
        guard let device = camera else { return }
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(sender.scale * lastZoomFactor)
        
        switch sender.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
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
    
    func initCamera(with device: AVCaptureDevice, audio: AVCaptureDevice?, captureSession: AVCaptureSession) {
        do {
            cameraInput = try AVCaptureDeviceInput(device: device)
            captureSession.beginConfiguration()
            if captureSession.inputs.count > 0 {
                print("camera already initialized")
                return
            }
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                if let audio = audio {
                    let input = try AVCaptureDeviceInput(device: audio)
                    if captureSession.canAddInput(input) {
                        captureSession.addInput(input)
                    }
                }
                if captureSession.outputs.count == 0 {
                    photoOutput = AVCapturePhotoOutput()
                    
                    if captureSession.canAddOutput(photoOutput!) {
                        print("photo output added")
                        captureSession.addOutput(self.photoOutput!)
                    }
                    
                    videoFileOut = AVCaptureMovieFileOutput()
                    if (captureSession.canAddOutput(videoFileOut)) {
                        print("video output added")
                        captureSession.addOutput(videoFileOut)
                    }
                }
            }
            captureSession.commitConfiguration()
            if !captureSession.isRunning {
                captureSession.startRunning()
                self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                self.previewLayer!.connection.videoOrientation = .portrait
                self.cameraView.layer.addSublayer(self.previewLayer!)
            }
        } catch {
            print("Error accessing input device")
            return;
        }

    }
    
    @IBAction func cameraTouched(_ sender: UITapGestureRecognizer) {
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
    
    // MARK: Video capture
    
    func startCaptureVideo() {
        print("start recording")
        
        backButton.isHidden = true
        flashButton.isHidden = true
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent(randomString(length: 10) + ".mp4")
        
        if !(captureSession?.isRunning)! {
            captureSession?.startRunning()
        }
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    let filePathName = "\(documentPath)/\(fileName)"
                    try fileManager.removeItem(atPath: filePathName)
                }
                
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache after deleting images: \(files)")
            }
            
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
        if (videoFileOut?.connection(withMediaType: AVMediaTypeVideo).isVideoStabilizationSupported)! {
            videoFileOut?.connection(withMediaType: AVMediaTypeVideo).preferredVideoStabilizationMode = .cinematic
        }
        if camera?.position == .front && (videoFileOut?.connection(withMediaType: AVMediaTypeVideo).isVideoMirroringSupported)! {
            videoFileOut?.connection(withMediaType: AVMediaTypeVideo).isVideoMirrored = true
        }
        
        videoFileOut?.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
    }
    
    func stopCaptureVideo() {
        print("stop recording")
        videoFileOut?.stopRecording()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("starting")
        print(captureOutput.outputFileURL)
        return
    }
    
    @IBOutlet weak var videoView: MediaVideoView!
    
    var playerLooper: AVPlayerLooper?
    var player: AVQueuePlayer?
    
    
    // VIDEO CAPTURE DELEGATE CALLBACK
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        takePhotoButton.isHidden = true
        
        if error != nil {
            print(error)
        }
        print(connections)
        
        player = AVQueuePlayer()
        let playerLayer = AVPlayerLayer(player: player)
        let playerItem = AVPlayerItem(url: outputFileURL)
        playerLooper = AVPlayerLooper(player: player!, templateItem: playerItem)
        
        playerLayer.frame = self.cameraView.bounds
        videoView.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoView.isHidden = false
        player?.play()
        cancelButtonOut.isHidden = false
        nextButtonOut.isHidden = false
        videoView.configure()
        videoView.clearCaption()
        videoMediaUrl = outputFileURL
        mediaType = .video
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
            tempImageView.clearCaption()
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
        
        // VIDEO PREVIEW
        videoView.isHidden = true
        playerLooper?.disableLooping()
        player?.pause()
        player = nil
        playerLooper = nil
        
        mediaType = nil
    }
    
    @IBAction func takeVideoAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            photoTaken = true
            startCaptureVideo()
        } else if sender.state == .ended {
            stopCaptureVideo()
        }
    }
    
    enum MediaType {
        case video
        case image
    }
    
    var mediaType: MediaType?
    
    var vPickDest: ViewPickDest?
    
    @IBAction func nextButton(_ sender: AnyObject) {
        if mediaType == .image {
            print("image")
            imageMedia = UIImage(view: tempImageView)
        } else if mediaType == .video {
            print("video")
            renderVideoWithCaption()
            return
        } else {
            print("error")
            return
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
    
    func renderVideoWithCaption() {
        if let videoUrl = videoMediaUrl {
            let vidAsset = AVURLAsset(url: videoUrl)
            let composition = AVMutableComposition()
            
            
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
            
            let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            for audioTrack in aTracks {
                try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: kCMTimeZero)
            }
            
            
            let size = vidTrack.naturalSize
            
            //videoView.caption.layer.frame.size = CGSize(width: size.height, height: size.width)
            let captionImg = UIImage(view: videoView)
            let captionLayer = CALayer()
            captionLayer.contents = captionImg.cgImage
            captionLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
            
            let vidLayer = CALayer()
            vidLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
            print(size)
            
            let parentLayer = CALayer()
            parentLayer.frame = CGRect(x : 0, y: 0, width: size.height, height: size.width)
            parentLayer.addSublayer(vidLayer)
            parentLayer.addSublayer(captionLayer)
            
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
            let vidPath = documentsUrl.appendingPathComponent("result.mp4")
            
            let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            assetExport?.videoComposition = layerComposition
            assetExport?.outputFileType = AVFileTypeMPEG4
            assetExport?.outputURL = vidPath
            assetExport?.exportAsynchronously(completionHandler: {
                print("complete")
                DispatchQueue.main.async {
                    let player = AVPlayer(url: vidPath!)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    UIApplication.topViewController()?.present(playerController, animated: true) {
                        player.play()
                    }
                }
            })
        }
    }
    
    func mediaSent(groupIds: [Int]) {
        removeMediaPreview()
        (self.parent as! ViewController).scrollView.contentOffset.x = 0
        let userInfo = ["group_ids" : groupIds]
        NotificationCenter.default.post(name: Constants.Notifications.StoryPosted, object: self, userInfo: userInfo)
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
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}
