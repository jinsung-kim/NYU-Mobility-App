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
        // Do any additional setup after loading the view, typically from a nib.
        if (self.setupSession()) {
            self.setupPreview()
            self.startSession()
        }
        self.setupButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // If resources cannot be allocated anymore, clear them (still testing)
    }
    
    func setupButton() {
        self.cameraButton.isUserInteractionEnabled = true
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.startCapture))
        self.cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        self.cameraButton.frame = CGRect(x: 0, y: self.camPreview.frame.height - 40,
                                         width: 60, height: 60)
        self.cameraButton.center.x = view.center.x // centers horizontally
        self.cameraButton.backgroundColor = UIColor.white // button is white when initialized
        self.cameraButton.layer.cornerRadius = 30 // button round
        self.cameraButton.layer.masksToBounds = true
        self.camPreview.addSubview(cameraButton)
    }
    
    func setupPreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.frame = UIScreen.main.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.camPreview.layer.addSublayer(previewLayer)
    }

    func setupSession() -> Bool {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.high

        // Setup Camera
        let camera = AVCaptureDevice.default(for: .video)!

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

        if (self.captureSession.canAddOutput(movieOutput)) {
            self.captureSession.addOutput(movieOutput)
        }
        return true
    }

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

    // Note: app only works in portrait mode, so that is the only orientation that the camera will support
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        return AVCaptureVideoOrientation.portrait
    }
    
    @objc func startCapture() {
        self.cameraButton.backgroundColor = UIColor.red
        self.startRecording()
    }

    func generateURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString

        if (directory != "") {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }

    func startRecording() {
        // only record if there isn't already a previous session
        if (self.movieOutput.isRecording == false) {
            let connection = movieOutput.connection(with: .video)
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
            self.outputURL = generateURL()
            self.movieOutput.startRecording(to: self.outputURL, recordingDelegate: self)
        // stop recording otherwise
        } else {
            self.stopRecording()
        }
    }

    func stopRecording() {
        if (self.movieOutput.isRecording == true) {
            self.cameraButton.backgroundColor = UIColor.white
            self.movieOutput.stopRecording()
            self.redirectReplay()
        }
    }
    
    func redirectReplay() {
        let video = AVPlayer(url: self.outputURL!)
        let videoPlayer = AVPlayerViewController()
        videoPlayer.player = video
        self.present(videoPlayer, animated: true, completion: {
            video.play()
        })
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didFinishRecordingToOutputFileAt outputFileURL: URL!,
                 fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            print("Error capturing movie: \(error!.localizedDescription)")
        } else {
            let videoRecorded = outputURL! as URL
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }

    // Protocol stubs
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error outputting movie: \(error!.localizedDescription)")
        } else {
            _ = outputURL as URL
        }
        outputURL = nil
    }
}
