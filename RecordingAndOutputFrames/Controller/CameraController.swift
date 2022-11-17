//
//  CameraController.swift
//  RecordingAndOutputFrames
//
//  Created on 2022/11/16.
//
// 拷貝來自同事的寫法，控制相機操作的Class
// 包含了處理Delegate的功能

import UIKit
import AVFoundation

class CameraController: NSObject {
    deinit {
        print(self, #function)
    }
    //MARK: typealie
    typealias URLCompletion = (URL?, Error?) -> Void
    typealias ImageCompletion = (UIImage?, Error?) -> Void
    typealias PrepareCompletion = (Error?) -> Void
    //MARK: values
    var captureSession:AVCaptureSession?
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?//預覽層（preview layer）做為相機預覽用
    
    var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ImageCompletion?
    // video recording
    var videoOutput: AVCaptureMovieFileOutput?// 設置影片擷取後輸出的session
    var videoRecordingCompletionBlock: URLCompletion?
    // get/set
    var uiOrientation: UIInterfaceOrientation {
        get {
            /**
             'windows' was deprecated in iOS 15.0: Use UIWindowScene.windows on a relevant window scene instead
             */
            if #available(iOS 15.0, *) {
                let appWindows = UIApplication.shared.connectedScenes
                // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
                // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
                // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
                
                return appWindows?.first?.windowScene?.interfaceOrientation ?? .unknown
            }
            else {
                return UIApplication.shared.statusBarOrientation
            }
            
//            if #available(iOS 13.0, *) {
//                /**
//                 'statusBarOrientation' was deprecated in iOS 13.0: Use the interfaceOrientation property of the window scene instead.
//                 */
//                return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
//            }
//            else {
//                return UIApplication.shared.statusBarOrientation
//            }
        }
    }
    //MARK: functions
    func prepare(isVideo : Bool = false, completionHandler: @escaping PrepareCompletion) {
        DispatchQueue(label: "prepare").async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevice()
                try self.configureDeviceInputs()
                if isVideo {
                    try self.configureVideoOutput()
                }
                else {
                    try self.configurePhotoOutput()
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }// end prepare
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        view.layer.masksToBounds = true
        
        self.updateViewframe(newFrame: view.frame)
    }
    
    func updateViewframe(newFrame: CGRect) {
        switch uiOrientation {
        case .portrait:
            self.previewLayer?.connection?.videoOrientation = .portrait
        case .landscapeLeft:
            self.previewLayer?.connection?.videoOrientation = .landscapeLeft
        case .landscapeRight:
            self.previewLayer?.connection?.videoOrientation = .landscapeRight
        case .portraitUpsideDown:
            self.previewLayer?.connection?.videoOrientation = .portraitUpsideDown
        default:
            break
        }
        self.previewLayer?.frame = CGRect(origin: CGPoint.zero, size: newFrame.size)
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        captureSession.beginConfiguration()// session start
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera(captureSession)
        case .rear:
            try switchToFrontCamera(captureSession)
        default:break
        }
        captureSession.commitConfiguration()// session end
    }
    //錄影的按鈕動畫
    private func recordingAnimation(isRecording status: Bool, playButton view: UIView) {
        if status {
            UIView.animate(withDuration: 0.5, delay: 0.3, options:  [.repeat, .autoreverse, .allowUserInteraction]) {
                view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }
        else {
            UIView.animate(withDuration: 0.5, delay: 0.0) {
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } completion: { result in
                view.layer.removeAllAnimations()
            }

        }// end if
    }
    //MARK: control camera
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
        
    }
    
    func startRunning() {
        guard let session = self.captureSession else { return }
        session.startRunning()
    }
    
    func stopRunning() {
        guard let session = self.captureSession else { return }
        session.stopRunning()
    }
    //video control
    func startRecording(outputPath: URL, recButton: UIButton? = nil, completion: @escaping URLCompletion) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        self.videoOutput?.startRecording(to: outputPath, recordingDelegate: self)
        self.videoRecordingCompletionBlock = completion
        if let btnView = recButton {
            recordingAnimation(isRecording: true, playButton: btnView)
        }
        
    }
    
    func stopRecording(recButton: UIButton? = nil) {
        self.videoOutput?.stopRecording()
        if let btnView = recButton {
            recordingAnimation(isRecording: false, playButton: btnView)
        }
    }
}


//MARK: prepare
extension CameraController {
    private func createCaptureSession() {
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    private func configureCaptureDevice() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video , position: .back)
        let cameras = session.devices.compactMap { $0 }
        
        guard cameras.isEmpty == false else { throw CameraControllerError.noCamerasAvailable }
        
        for camera in cameras {
            if camera.position == .front {
                self.frontCamera = camera
            }
            
            if camera.position == .back {
                self.rearCamera = camera
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }
    private func configureDeviceInputs() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        if let rearCamera = self.rearCamera {
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
            }
            self.currentCameraPosition = .rear
        }
        else if let frontCamera = self.frontCamera {
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
            }else{
                throw CameraControllerError.inputsAreInvalid
            }
            self.currentCameraPosition = .front
        }
        else {
            throw CameraControllerError.noCamerasAvailable
        }
    }
    
    private func configurePhotoOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
        if captureSession.canAddOutput(self.photoOutput!) {
            captureSession.addOutput(self.photoOutput!)
        }
        captureSession.startRunning()
    }
    
    private func configureVideoOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        self.videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(self.videoOutput!) {
            captureSession.addOutput(self.videoOutput!)
        }
        
        captureSession.startRunning()
    }
}

//MARK: switchCameras
extension CameraController {
    // mark inner functions
    private func switchToFrontCamera(_ captureSession: AVCaptureSession) throws {
        guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput), let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
        self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        captureSession.removeInput(rearCameraInput)
        
        if captureSession.canAddInput(self.frontCameraInput!) {
            captureSession.addInput(self.frontCameraInput!)
            self.currentCameraPosition = .front
        }else{
            throw CameraControllerError.invalidOperation
        }
    }
    
    private func switchToRearCamera(_ captureSession: AVCaptureSession) throws {
        guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput), let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
        self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        captureSession.removeInput(frontCameraInput)
        
        if captureSession.canAddInput(self.rearCameraInput!) {
            captureSession.addInput(self.rearCameraInput!)
            self.currentCameraPosition = .rear
        }else{
            throw CameraControllerError.invalidOperation
        }
    }
}
//MARK: AVCapturePhotoCaptureDelegate
extension CameraController:AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        }else if let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData), let cgImage = image.cgImage {
            
            var newImage:UIImage!
            switch uiOrientation {
            case .portrait:
                newImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            case .portraitUpsideDown:
                newImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
            case .landscapeLeft:
                newImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .down)
            case .landscapeRight:
                newImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
            default:
                break
            }
            self.photoCaptureCompletionBlock?(newImage, nil)
        }else{
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}
//MARK: AVCaptureFileOutputRecordingDelegate
extension CameraController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            self.videoRecordingCompletionBlock?(nil, error)
        }
        else {
            self.videoRecordingCompletionBlock?(outputFileURL, nil)
        }
    }
}
//MARK: - enum
extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case back
        case rear
        case unspecified
    }
}
