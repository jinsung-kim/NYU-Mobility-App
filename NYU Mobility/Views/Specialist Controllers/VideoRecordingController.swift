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
import CoreMotion
import CoreData
import CoreLocation

// https://stackoverflow.com/questions/36536044/swift-video-to-document-directory

class VideoRecordingController: UIViewController, AVCaptureFileOutputRecordingDelegate,
                                CLLocationManagerDelegate {
    
    @IBOutlet weak var camPreview: UIView!
    
    @IBOutlet weak var cameraButton: UIView!
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var saved: String = ""
    
    // Movement tracking managers (copied from SpecialistTrackingController.swift
    
    var name: String?
    
    // Used to track pedometer when saving data
    private var steps: Int32 = 0
    private var maxSteps: Int32 = 0
    private var distance: Int32 = 0 // In meters
    private var maxDistance: Int32 = 0
    private var startTime: Date = Date()
    
    // GPS Location Services
    var coords: [CLLocationCoordinate2D] = []
    private let locationManager: CLLocationManager = CLLocationManager()
    private var locationArray: [String: [Double]] = ["long": [], "lat": []]
    
    // Used for creating the JSON
    var points: [Point] = []
    
    var sessions: [NSManagedObject] = []
    
    // Pedometer object - used to trace each step
    private let activityManager: CMMotionActivityManager = CMMotionActivityManager()
    private let pedometer: CMPedometer = CMPedometer()
    
    // Gyro Sensor
    private let motionManager: CMMotionManager = CMMotionManager()
    // Used to store all x, y, z values
    private var gyroDict: [String: [Double]] = ["x": [], "y": [], "z": []]
    
    // Pace trackers
    private var currPace: Double = 0.0
    private var avgPace: Double = 0.0
    private var currCad: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Screen will not go to sleep with this line below
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Instructions Page Redirect setup
        instructionButton()
        
        loadData()
        getLocationPermission()
        
        if (setupSession()) {
            setupPreview()
            startSession()
        }
        setupButton()
    }
    
    @IBAction func unwindToRecorder(_ sender: UIStoryboardSegue) {}
    
    // Upper right item from the tracking controller that goes to the settings
    func instructionButton() {
        let instructionButton = UIBarButtonItem()
        instructionButton.title = "See Tutorial"
        instructionButton.action = #selector(sessionsTap)
        instructionButton.target = self
        navigationItem.rightBarButtonItem = instructionButton
    }
    
    @objc func sessionsTap() {
        performSegue(withIdentifier: "VideoSessionTutorial", sender: self)
    }
    
    func setupButton() {
        cameraButton.isUserInteractionEnabled = true
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoRecordingController.startCapture))
        cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        cameraButton.backgroundColor = UIColor.white // button is white when initialized
        cameraButton.layer.cornerRadius = 30 // button round
        cameraButton.layer.masksToBounds = true
        
        camPreview.addSubview(cameraButton)
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }

    func setupSession() -> Bool {
        // Proof of concept: Lowering quality to 720p
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        if (captureSession.canAddOutput(movieOutput)) {
            captureSession.addOutput(movieOutput)
        }
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {}
    
    func startSession() {
        if (!captureSession.isRunning) {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if (captureSession.isRunning) {
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
        startRecording()
    }
    
    // Gets the directory that the video is stored in
    func getPathDirectory() -> URL {
        // Searches a FileManager for paths and returns the first one
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    func generateURL() -> URL? {
        saved = NSUUID().uuidString + ".mp4"
        let path = getPathDirectory().appendingPathComponent(saved)
        return path
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showVideo") { // going to video playback controller
            let vc = segue.destination as! VideoPlaybackController
            vc.session = sessions[sessions.count - 1]
        }
    }
    
    func startRecording() {
        
        if (movieOutput.isRecording == false) {
            cameraButton.backgroundColor = UIColor.red
            
            startTracking()
            startTime = Date()
            
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
            
            outputURL = generateURL()
            movieOutput.startRecording(to: outputURL!, recordingDelegate: self)
            
        } else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        if (movieOutput.isRecording == true) {
            cameraButton.backgroundColor = UIColor.white
            movieOutput.stopRecording()
            stopTracking()
            saveSession()
            clearData()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didStartRecordingToOutputFileAt fileURL: URL!,
                 fromConnections connections: [Any]!) {}
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            performSegue(withIdentifier: "showVideo", sender: outputURL!)
        }
    }
    
    // Movement tracking controller functions
    
    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Session")
        
        do {
            sessions = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // GPS Location Services
    
    func getLocationPermission() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    // Continuously gets the location of the user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for _ in locations { // _ -> currentLocation
            if let location: CLLocation = locationManager.location {
                // Coordinate object
                let coordinate: CLLocationCoordinate2D = location.coordinate
                coords.append(coordinate)
                // ... proceed with the location and coordinates
                if (locationArray["lat"] == nil) {
                    locationArray["lat"] = [coordinate.latitude]
                    locationArray["long"] = [coordinate.longitude]
                } else {
                    locationArray["lat"]!.append(coordinate.latitude)
                    locationArray["long"]!.append(coordinate.longitude)
                }
            }
            // Looks like this when debugged (city bike ride):
            // (Function): <+37.33144466,-122.03075535> +/- 30.00m
            // (speed 6.01 mps / course 180.98) @ 3/13/20, 8:55:48 PM Pacific Daylight Time
        }
    }
    
    // Pedometer Tracking
    
    /**
        Starts the gyroscope tracking, GPS location tracking, and pedometer object
        Assumes that location permissions and motion permissions have already been granted
        Changes the color of the UIView to green (indicating that it is in go mode)
        - Parameters:
            - fileName: The name of the file that should be played
     */
    func startTracking() {
        locationManager.startUpdatingLocation()
        startGyro()
        startUpdating()
        saveData(currTime: Date(), significant: true)
    }
    
    /**
        Stops tracking the gyroscope, GPS location, and pedometer object
        Assumes that the previously stated managers are running
     */
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        stopUpdating()
        stopGyros()
        saveData(currTime: Date(), significant: true)
    }
    
    func stopUpdating() { pedometer.stopUpdates() }
    
    // Pedometer Functions
    
    func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        }

        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
    }
    
    func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            self?.steps = 0
            self?.distance = 0
            self?.maxSteps = 0
            self?.maxDistance = 0
        }
    }
    
    func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
          [weak self] pedometerData, error in
          guard let pedometerData = pedometerData, error == nil else { return }

            // Runs concurrently
            DispatchQueue.main.async {
                self?.saveData(currTime: Date(), significant: false)
                self?.distance = Int32(truncating: pedometerData.distance ?? 0)
                self?.steps = Int32(truncating: pedometerData.numberOfSteps)
                self?.avgPace = Double(truncating: pedometerData.averageActivePace ?? 0)
                self?.currPace = Double(truncating: pedometerData.currentPace ?? 0)
                self?.currCad = Double(truncating: pedometerData.currentCadence ?? 0)
            }
        }
    }
    
    func dateToString(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    /**
        Saves the given data into the stack, and clears out the gyroscope data to start taking values again
        - Parameters:
            - currTime: Date in which the data has been tracked
            - significant: Whether the point must be included or not
     */
    func saveData(currTime: Date, significant: Bool) {
        // JSON array implementation (See Point.swift for model)
        if (steps >= maxSteps) {
            maxSteps = steps
        }
        if (distance >= maxDistance) {
            maxDistance = distance
        }
        
        // If the data collected is valid -> insert into the collection of points
        if (maxDistance != 0 || maxSteps != 0 || points.isEmpty || significant) {
            points.append(Point(dateToString(), maxSteps, maxDistance,
                                avgPace, currPace, currCad,
                                locationArray, gyroDict))
            
            // Clear the gyroscope data after getting its string representation
            gyroDict.removeAll()
            locationArray.removeAll()
        }
    }
    
    // Generate JSON in String form
    func generateJSON() -> String {
        let dicArray = points.map { $0.convertToDictionary() }
        if let data = try? JSONSerialization.data(withJSONObject: dicArray, options: .prettyPrinted) {
            let str = String(bytes: data, encoding: .utf8)
            return str!
        }
        return "There was an error generating the JSON file" // shouldn't ever happen
    }
    
    // Saves Point
    func saveSession() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Session",
                                                in: managedContext)!
        
        let session = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let json: String = generateJSON()
        
        session.setValue(json, forKeyPath: "json")
        session.setValue(startTime, forKeyPath: "startTime")
        session.setValue(name!, forKeyPath: "user")
        
        // Saving the necessary portion of the URL to be played in the future due to sandboxing
        // See generateURL() to see 'saved' file name + extension
        session.setValue(saved, forKeyPath: "videoURL")
        
        let code: String = UserDefaults.standard.string(forKey: "code")!
        let mode: String = "specialist"
        
        DatabaseManager.shared.insertClientSession(code: code, json: json, clientName: name!,
                                                   startTime: dateToString(startTime), mode: mode,
                                                   videoURL: saved[0 ..< 36], completion: { success in
            if (!success) {
                print("Failed to save to database")
            }
        })
        
        do {
            try managedContext.save()
            sessions.append(session)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func clearData() {
        points.removeAll()
    }
    
    // Gyroscope Functions
    
    // Starts the gyroscope once it is confirmed to be available
    func startGyro() {
        if motionManager.isGyroAvailable {
            // Set to update 5 times a second
            self.motionManager.gyroUpdateInterval = 0.2
            self.motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
                if let gyroData = data {
                    if (self.gyroDict["x"] == nil) { // No entries for this point yet
                        self.gyroDict["x"] = [gyroData.rotationRate.x]
                        self.gyroDict["y"] = [gyroData.rotationRate.y]
                        self.gyroDict["z"] = [gyroData.rotationRate.z]
                    } else { // We know there are already values inserted
                        self.gyroDict["x"]!.append(gyroData.rotationRate.x)
                        self.gyroDict["y"]!.append(gyroData.rotationRate.y)
                        self.gyroDict["z"]!.append(gyroData.rotationRate.z)
                    }
                    // Ex (output):
                    // CMRotationRate(x: 0.6999756693840027,
                    // y: -1.379577398300171, z: -0.3633846044540405)
                }
            }
        }
    }
    
    // Stops the gyroscope (assuming that it is available)
    func stopGyros() { motionManager.stopGyroUpdates() }
    
}
