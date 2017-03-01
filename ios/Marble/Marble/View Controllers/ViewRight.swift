//
//  ViewRight.swift
//  Marble
//
//  Created by Daniel Li on 10/11/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ViewRight: UIViewController, UIImagePickerControllerDelegate, UINavigationBarDelegate, AVCapturePhotoCaptureDelegate /*, AVCaptureFileOutputRecordingDelegate*/ {

    var captureSession : AVCaptureSession?
    var photoOutput : AVCapturePhotoOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var camera: AVCaptureDevice?
    var videoFileOut: AVCaptureMovieFileOutput?
    
    var media : UIImage?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cancelButtonOut: UIButton!
    @IBOutlet weak var nextButtonOut: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vPickDest = ViewPickDest(nibName: "ViewPickDest", bundle: nil)

        vPickDest?.delegate = self
        
        tempImageView.isUserInteractionEnabled = false
        tempImageView.isHidden = true
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
        previewLayer?.frame = cameraView.bounds
        cancelButtonOut.isHidden = true
        nextButtonOut.isHidden = true
        takePhotoButton.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else {
            print("Error making capture session")
            return;
        }
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        camera = defaultBackCamera()
        
        if let camera = camera {
            initCamera(with: camera, captureSession: captureSession)
        }
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
        print("double")
        if camera?.position == .front {
            camera = defaultBackCamera()
            if let camera = camera {
                initCamera(with: camera, captureSession: captureSession!)
            }
        } else {
            camera = defaultFrontCamera()
            if let camera = camera {
                initCamera(with: camera, captureSession: captureSession!)
            }
        }
    }
    
    func initCamera(with device: AVCaptureDevice, captureSession: AVCaptureSession) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.beginConfiguration()
            if captureSession.inputs.count > 0 {
                captureSession.removeInput(captureSession.inputs?[0] as! AVCaptureInput!)
            }
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                
                if captureSession.outputs.count == 0 {
                    photoOutput = AVCapturePhotoOutput()
                    
                    if captureSession.canAddOutput(photoOutput!) {
                        captureSession.addOutput(photoOutput!)
                        
                        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                        previewLayer!.connection.videoOrientation = .portrait
                        cameraView.layer.addSublayer(previewLayer!)
                    }
                }
            }
            captureSession.commitConfiguration()
            if !captureSession.isRunning {
                captureSession.startRunning()
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
    
//    func startCaptureVideo() {
//        print("start recording")
//        
//        captureSession?.removeOutput(photoOutput)
//        
//        videoFileOut = AVCaptureMovieFileOutput()
//        if (captureSession?.canAddOutput(videoFileOut))! {
//            captureSession?.addOutput(videoFileOut)
//        }
//        
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let filePath = documentsURL.appendingPathComponent("temp")
//        
//        if !(captureSession?.isRunning)! {
//            captureSession?.startRunning()
//        }
//        
//        videoFileOut?.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
//    }
//    
//    func stopCaptureVideo() {
//        print("stop recording")
//        videoFileOut?.stopRecording()
//    }
//    
//    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
//        print("starting")
//        print(captureOutput.debugDescription)
//        return
//    }
//    
//    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
//        
//        do {
//            //return [FileAttributeKey : Any]
//            let attr = try FileManager.default.attributesOfItem(atPath: outputFileURL.absoluteString)
//            var fileSize = attr[FileAttributeKey.size] as! UInt64
//            
//            //if you convert to NSDictionary, you can get file size old way as well.
//            let dict = attr as NSDictionary
//            fileSize = dict.fileSize()
//            print(fileSize)
//        } catch {
//            print("Error: \(error)")
//        }
//        print("hi")
//        if error != nil {
//            print(error)
//        }
//        print(connections)
//        
//        print(outputFileURL)
//        let player = AVPlayer(url: NSURL(fileURLWithPath: outputFileURL.absoluteString) as URL)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.view.bounds
//        self.view.layer.addSublayer(playerLayer)
//        player.play()
//        print("playing")
//        return
//    }
    
    
    @IBOutlet weak var tempImageView: DIImageView!
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                 kCVPixelBufferWidthKey as String: 160,
                                 kCVPixelBufferHeightKey as String: 160,
                                 ]
        settings.previewPhotoFormat = previewFormat
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
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
        UIApplication.shared.isStatusBarHidden = false
        vPickDest = ViewPickDest(nibName: "ViewPickDest", bundle: nil)
    }
    
    @IBAction func takeVideoAction(_ sender: UILongPressGestureRecognizer) {
//        if sender.state == .began {
//            photoTaken = true
//            startCaptureVideo()
//        } else if sender.state == .ended {
//            stopCaptureVideo()
//        }
    }
    
    var vPickDest: ViewPickDest?
    
    @IBAction func nextButton(_ sender: AnyObject) {
        media = UIImage(view: tempImageView)
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
    
    func mediaSent(groupIds: [Int]) {
        removeMediaPreview()
        (self.parent as! ViewController).scrollView.contentOffset.x = 0
        let userInfo = ["group_ids" : groupIds]
        NotificationCenter.default.post(name: Constants.Notifications.StoryPosted, object: self, userInfo: userInfo)
    }
    
}
