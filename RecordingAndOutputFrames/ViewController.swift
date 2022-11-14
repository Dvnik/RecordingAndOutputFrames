//
//  ViewController.swift
//  RecordingAndOutputFrames
//
//  Created by Trixie Lulamoon on 2022/11/14.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    //MARK: outlet
    @IBOutlet weak var recordPreview: UIView!
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var lblClickInfo: UILabel!
    //MARK: values
    let handler = MediaHandler.shared
    
    var avPlayerVC: AVPlayerViewController!
    var tempOutputPath: URL!

    var isRecording: Bool = false
    //MARK: life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblClickInfo.text = ""
        _ = handler.defaultConfigure(showView: recordPreview)
        avPlayerVC = handler.boundingPlayerViewController(in: playerView)
    }
    //MARK: @IBAction

    @IBAction func actionRecording(_ sender: UIButton) {
        self.isRecording = !self.isRecording
        handler.recordingAnimation(isRecording: self.isRecording, playButton: sender)
        handler.defaultRecordMedia(isRecording: self.isRecording, recordingDelegate: self)
    }
    
    
    @IBAction func onClickAct01(_ sender: UIButton) {
        lblClickInfo.text = "\(#function)"
    }
    
    @IBAction func onClickAct02(_ sender: UIButton) {
        lblClickInfo.text = "\(#function)"
    }
    
    @IBAction func onClickAct03(_ sender: UIButton) {
        lblClickInfo.text = "\(#function)"
    }
}

//MARK: - AVCaptureFileOutputRecordingDelegate
extension ViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error ?? "")
            return
        }
        
        tempOutputPath = outputFileURL
        avPlayerVC.player = AVPlayer(url: outputFileURL)
    }
    
    
    
    
    
}
