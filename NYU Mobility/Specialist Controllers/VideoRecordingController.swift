//
//  VideoRecordingController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/13/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

// https://stackoverflow.com/questions/41697568/capturing-video-with-avfoundation

class VideoRecordingController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var camPreview: UIView!
    
    let cameraButton = UIView()
    
    let captureSession = AVCaptureSession()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    
    var outputURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.setupSession()) {
            self.setupPreview()
            self.startSession()
        }
        
        self.cameraButton.isUserInteractionEnabled = true
        
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoRecordingController.startCapture))
        self.cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        self.cameraButton.frame = CGRect(x: 0, y: self.camPreview.frame.height - 60,
                                         width: 60, height: 60)
        self.cameraButton.center.x = view.center.x // centers horizontally
        self.cameraButton.backgroundColor = UIColor.white // button is white when initialized
        self.cameraButton.layer.cornerRadius = 30 // button round
        self.cameraButton.layer.masksToBounds = true
        
        self.camPreview.addSubview(cameraButton)
        
    }
    
    func setupPreview() {
        // Configure previewLayer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.frame = self.camPreview.bounds
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.camPreview.layer.addSublayer(self.previewLayer)
    }

    func setupSession() -> Bool {
        
        self.captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if (self.captureSession.canAddInput(input)) {
                self.captureSession.addInput(input)
                self.activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if (self.captureSession.canAddInput(micInput)) {
                self.captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        if (self.captureSession.canAddOutput(movieOutput)) {
            self.captureSession.addOutput(movieOutput)
        }
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {}
    
    func startSession() {
        if (!self.captureSession.isRunning) {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if (self.captureSession.isRunning) {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        default:
            orientation = AVCaptureVideoOrientation.portrait
        }
        return orientation
    }
    
    @objc func startCapture() {
        self.startRecording()
    }

    func generateURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! VideoPlaybackController
        vc.videoURL = sender as? URL
    }
    
    func startRecording() {
        
        if (self.movieOutput.isRecording == false) {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }
            
            self.outputURL = self.generateURL()
            self.movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        } else {
            self.stopRecording()
        }
    }
    
    func stopRecording() {
        if (self.movieOutput.isRecording == true) {
            self.movieOutput.stopRecording()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!,
                 fromConnections connections: [Any]!) {}
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            let videoRecorded = self.outputURL! as URL
            self.performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
    
}
