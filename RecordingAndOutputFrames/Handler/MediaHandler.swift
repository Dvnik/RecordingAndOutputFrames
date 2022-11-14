//
//  MediaHandler.swift
//  JunkTest
//
//  Created on 2022/11/10.
//

import Foundation
import AVFoundation
import AVKit

class MediaHandler: NSObject {
    //MARK: Singleton
    public static var shared:MediaHandler {
        get {
            if handler == nil { handler = MediaHandler() }
            return handler
        }
    }
    private static var handler:MediaHandler!
    //MARK:Value
    var tempOutputPath: String {
        get {
            return NSTemporaryDirectory() + "output.mov"
        }
    }
    
    //AVFoundation
    let captureSession = AVCaptureSession()
    var videoFileOutput = AVCaptureMovieFileOutput()// 設置影片擷取後輸出的session
    
    var currentDevice: AVCaptureDevice!//必須找到相機裝置來拍攝影片
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?//預覽層（preview layer）做為相機預覽用
    
    //MARK: - functions
    //MARK: default setting
    func defaultConfigure(showView: UIView) -> Bool {
        // 取得後置相機來擷取影片
        currentDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        // 取得輸入資料源
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return false
        }
        // 以高解析度來預設 session
        captureSession.sessionPreset = .high
        // 設置輸入與輸出裝置的 session
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        // 提供相機預覽
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.frame = showView.bounds
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // 將cameraPreviewLayer加入到要顯示的view底下
        showView.layer.addSublayer(cameraPreviewLayer!)
        
        captureSession.startRunning()
        
        return true
    }
    // 執行錄影的功能
    func defaultRecordMedia(isRecording status: Bool, recordingDelegate delegate: AVCaptureFileOutputRecordingDelegate) {
        if status {
            let outputURL = URL(fileURLWithPath: tempOutputPath)
            videoFileOutput.startRecording(to: outputURL, recordingDelegate: delegate)
        }
        else {
            videoFileOutput.stopRecording()
        }
    }
    //MARK: viewSet
    func boundingPlayerViewController(in view: UIView) -> AVPlayerViewController {
        let avpVC = AVPlayerViewController()
        avpVC.view.frame = view.bounds
        
        view.addSubview(avpVC.view)
        return avpVC
    }
    //錄影的按鈕動畫
    func recordingAnimation(isRecording status: Bool, playButton view: UIView) {
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

        }
        
    }
    
    
    
}
