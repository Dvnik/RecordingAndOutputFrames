//
//  ViewController.swift
//  RecordingAndOutputFrames
//
//  Created by Trixie Lulamoon on 2022/11/14.
//

import UIKit

class ViewController: UIViewController {
    //MARK: outlet
    @IBOutlet weak var recordPreview: UIView!
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var lblClickInfo: UILabel!
    //MARK: values
    let handler = MediaHandler.shared
    let cameraController = CameraController()
    
    var tempOutputPath: URL!
    var isRecording: Bool = false
    //MARK: life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblClickInfo.text = ""
        configureCameraController()
        handler.boundingPlayerViewController(in: playerView)
    }
    //MARK: functions
    private func configureCameraController() {
        cameraController.prepare { (error:Error?) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.recordPreview)
        }
    }
    //MARK: @IBAction

    @IBAction func actionRecording(_ sender: UIButton) {
        self.isRecording = !self.isRecording
        if self.isRecording {
            cameraController.startRecording(outputPath: handler.tempOutputURL, recButton: sender) { outputFileURL, error in
                if error != nil {
                    return
                }
                if let outputFileURL = outputFileURL {
                    self.handler.setPlayVideo(url: outputFileURL)
                }
                self.tempOutputPath = outputFileURL
            }
        }
        else {
            cameraController.stopRecording(recButton: sender)
        }
    }
    
    @IBAction func onClickAct01(_ sender: UIButton) {
        lblClickInfo.text = "\(#function)"
        guard let outputFileURL = tempOutputPath else { return }
        
        lblClickInfo.text = outputFileURL.description
        
    }
    
    @IBAction func onClickAct02(_ sender: UIButton) {
        lblClickInfo.text = "\(#function)"
    }
}
