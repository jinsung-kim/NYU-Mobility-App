//
//  TrackingController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 5/29/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

// Navigation Bar: For the settings tab later
// https://www.youtube.com/watch?v=aW_u2nTxQ7A

import UIKit
import CoreMotion // Used to track user movement
import CoreLocation // Used to access coordinate data
// import CoreData // Used to store data
import AVFoundation // Used to play sounds

class TrackingController: UIViewController, CLLocationManagerDelegate {
    
    // What is used to change color
    @IBOutlet weak var viewer: UIView!
    
    // Button used to change states
    @IBOutlet weak var trackingButton: UIButton!
    
    // Creating a new LocationManager Object
    private let locationManager: CLLocationManager = CLLocationManager()
    private var locationArray: [String: [Double]] = ["long": [], "lat": []]
    
    // Pedometer object - used to trace each step
    private let activityManager: CMMotionActivityManager = CMMotionActivityManager()
    private let pedometer: CMPedometer = CMPedometer()
    
    // Gyro Sensor
    private let motionManager: CMMotionManager = CMMotionManager()
    private var gyroDict: [String:[Double]] = ["x": [], "y": [], "z": []] // Used to store all x, y, z values
    
    // Responsive button sounds
    private var player: AVAudioPlayer?
    
    // Triggering the button's three states
    private var buttonState: Int = 0
    
    // Used to track pedometer when saving data
    private var steps: Int32?
    
    // Used for creating the JSON
    private var points: [Point] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocationPermission()
        enableDoubleTap()
        // Initial screen is white, so must set it to
        // black so that you can see the start button
        self.viewer.backgroundColor = UIColor.black
    }
    
    func enableDoubleTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TrackingController.labelTapped(recognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        
        trackingButton.isUserInteractionEnabled = true
        trackingButton.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func labelTapped(recognizer: UITapGestureRecognizer) {
        if (self.buttonState == 1) {
            playSound("pause")
            trackingButton.setTitle("Resume", for: .normal)
            self.viewer.backgroundColor = UIColor.red
            self.buttonState = 3
            toggleButton(trackingButton)
        } else {
            playSound("resume")
            trackingButton.setTitle("Pause", for: .normal)
            self.viewer.backgroundColor = UIColor.green
            self.buttonState = 4
            toggleButton(trackingButton)
        }
    }
    
    func dateFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    // Generate JSON in String form
    func generateJSON() -> String {
        let dicArray = points.map { $0.convertToDictionary() }
        if let data = try? JSONSerialization.data(withJSONObject: dicArray, options: .prettyPrinted) {
            let str = String(bytes: data, encoding: .utf8)
            return str!
        }
        return "There was an error generating the JSON file"
    }
    
    /**
        Used to toggle into the next state of the button and tracking process
        Refers to the button state used globally
            0: Has not been turned on
            1: Currently tracking
            2: Done tracking
            3: Pause
            4: Resume
        - Parameters:
            - sender: The tracking button
     */
    @IBAction func toggleButton(_ sender: UIButton) {
        switch(self.buttonState) {
        case 0:
            startTracking()
            playSound("start")
            sender.setTitle("Stop", for: .normal)
            self.buttonState = 1
        case 1:
            stopTracking()
            playSound("stop")
            sender.setTitle("Reset", for: .normal)
            self.buttonState = 2
        case 2:
            saveAndExport(exportString: generateJSON())
            clearData()
            playSound("reset")
            sender.setTitle("Start", for: .normal)
            self.buttonState = 0
        case 3:
            stopTracking()
            self.buttonState = 0
        case 4:
            startTracking()
            playSound("resume")
            sender.setTitle("Stop", for: .normal)
            self.buttonState = 1
        default: // Should never happen
            print("Unexpected case: \(self.buttonState)")
        }
    }
    
    func getLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for _ in locations { // _ -> currentLocation
            
            if let location: CLLocation = locationManager.location {
                let coordinate: CLLocationCoordinate2D = location.coordinate

                // ... proceed with the location and coordinates
                if (self.locationArray["lat"] == nil) {
                    self.locationArray["lat"] = [coordinate.latitude]
                    self.locationArray["long"] = [coordinate.longitude]
                } else {
                    self.locationArray["lat"]!.append(coordinate.latitude)
                    self.locationArray["long"]!.append(coordinate.longitude)
                }
            }
            // Looks like this when debugged (city bike ride):
            // (Function): <+37.33144466,-122.03075535> +/- 30.00m
            // (speed 6.01 mps / course 180.98) @ 3/13/20, 8:55:48 PM Pacific Daylight Time
        }
    }
    
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
        self.viewer.backgroundColor = UIColor.green
    }
    
    /**
        Stops tracking the gyroscope, GPS location, and pedometer object
        Assumes that the previously stated managers are running
     */
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        stopUpdating()
        stopGyros()
        self.viewer.backgroundColor = UIColor.red
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
        }
    }
    
    func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
          [weak self] pedometerData, error in
          guard let pedometerData = pedometerData, error == nil else { return }

            // Runs concurrently
            DispatchQueue.main.async {
                self?.saveData(currTime: Date(), steps: (pedometerData.numberOfSteps as! Int32))
            }
        }
    }
    
    /**
        Saves the given data into the stack within CoreData, and clears out the gyroscope data to start taking values again
        - Parameters:
            - currTime: Date in which the data has been tracked
            - stepsTaken: Steps that have been taken
            - lat: lat coordinate the user is standing at
            - long: long coordinate the user is standing at
     */
    func saveData(currTime: Date, steps: Int32) {
        // JSON array implementation
        points.append(Point(dateFormatter(), steps, self.locationArray, self.gyroDict))
        
        // Clear the gyroscope data after getting its string representation
        self.gyroDict.removeAll()
        self.locationArray.removeAll()
    }
    
    func clearData() { points.removeAll() }
    
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
                    // CMRotationRate(x: 0.6999756693840027, y: -1.379577398300171, z: -0.3633846044540405)
                }
            }
        }
    }
    
    // Stops the gyroscope (assuming that it is available)
    func stopGyros() { self.motionManager.stopGyroUpdates() }
    
    // Sound Functionality
    
    /**
        Plays a sound given the state of the button
        - Parameters:
            - fileName: The name of the file being executed (all within 'Sound' group)
     */
    func playSound(_ fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }

            player.play()

        } catch let error {
            print("Unexpected Behavior: \(error.localizedDescription)")
        }
    }
    
    // Export Functionality
    func saveAndExport(exportString: String) {
            let exportFilePath = NSTemporaryDirectory() + "export.json"
            let exportFileUrl = NSURL(fileURLWithPath: exportFilePath)
            FileManager.default.createFile(atPath: exportFilePath, contents: Data(), attributes: nil)
            var fileHandle: FileHandle? = nil
            // Try
            do {
                fileHandle = try FileHandle(forWritingTo: exportFileUrl as URL)
            } catch {
                print("Error with File Handle")
            }
            
            if (fileHandle != nil) {
                fileHandle?.seekToEndOfFile()
                let jsonData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
                // Writes the JSON data into the file
                fileHandle?.write(jsonData!)
                fileHandle?.closeFile()
                
                let firstActivityItem = URL(fileURLWithPath: exportFilePath)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
                
                // Taking out some of the options that won't be needed / applicable
                activityViewController.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo
                ]
                
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    
    // Email Functionality
    
    func saveEmail(_ email: String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
    }
    
    func getEmail() -> String {
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "email")
        return email!
    }
}

