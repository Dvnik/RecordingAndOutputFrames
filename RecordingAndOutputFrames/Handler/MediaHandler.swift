//
//  MediaHandler.swift
//  JunkTest
//
//  Created on 2022/11/10.
//

import Foundation
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
    var tempOutputURL: URL {
        get {
            return URL(fileURLWithPath: tempOutputPath)
        }
    }
    
    var playerController: AVPlayerViewController?
    //MARK: - functions
    func boundingPlayerViewController(in view: UIView) {
        let avpVC = AVPlayerViewController()
        avpVC.view.frame = view.bounds
        
        view.addSubview(avpVC.view)
        playerController = avpVC
    }
    
    func setPlayVideo(url setURL: URL) {
        playerController?.player = AVPlayer(url: setURL)
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

        }// end if
    }
    //MARK: get all frames from video
    /**
     from :https://stackoverflow.com/questions/42665271/swift-get-all-frames-from-video
     */
    
    /// 將影像轉為圖片(預設值)
    func getAllFrameImages() -> [UIImage] {
        return getAllFrameImages(videoURL: tempOutputURL)
    }
    /// 將影像轉為圖片，指定影像路徑、擷取頻率(間隔多少秒抓一張圖)
    func getAllFrameImages(videoURL: URL, rate: Float64 = 0.1) -> [UIImage] {
        let asset = AVAsset(url: videoURL)
        let duration:Float64 = CMTimeGetSeconds(asset.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        var newFrames = [UIImage]()
        var count:Float64 = 0.0
        // make frame images
        while count < duration {
            if let cgImage = getFrameImage(fromTime: count, generator: generator) {
                newFrames.append(UIImage(cgImage: cgImage))
            }
            
            count += rate
        }
        // last Frame
        if let cgImage = getFrameImage(fromTime: duration, generator: generator) {
            newFrames.append(UIImage(cgImage: cgImage))
        }
        // result
        return newFrames
    }
    /// 取得AVAssetImageGenerator(影像資源)中的一張截圖
    private func getFrameImage(fromTime:Float64, generator: AVAssetImageGenerator) -> CGImage? {
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:600)
        return try? generator.copyCGImage(at:time, actualTime: nil)
    }
    
    
}
