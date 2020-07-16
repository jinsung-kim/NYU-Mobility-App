//
//  VideoRecordingController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/13/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVFoundation

// https://stackoverflow.com/questions/41697568/capturing-video-with-avfoundation

class VideoRecordingController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var cameraButton: UIButton!
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func setupCaptureMode(_ mode: Int) {
        // Video Mode
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

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        return AVCaptureVideoOrientation.portrait
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.startRecording()
    }

    func tempURL() -> URL? {
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

            self.outputURL = tempURL()
            self.movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            print(self.outputURL!)
        // stop recording otherwise
        } else {
            self.stopRecording()
            print("Done recording")
        }
    }

    func stopRecording() {
        if (self.movieOutput.isRecording == true) {
            self.movieOutput.stopRecording()
        }
    }

    // Protocol stubs
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            _ = outputURL as URL
        }
        outputURL = nil
    }
}
