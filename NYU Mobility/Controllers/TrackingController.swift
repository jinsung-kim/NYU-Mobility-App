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
import CoreData // Used to store data
import AVFoundation // Used to play sounds

class TrackingController: UIViewController, CLLocationManagerDelegate {
    
    // What is used to change color
    @IBOutlet weak var viewer: UIView!
    
    // Button used to change states
    @IBOutlet weak var trackingButton: UIButton!
    
    // Creating a new LocationManager Object
    let locationManager: CLLocationManager = CLLocationManager()
    
    // Pedometer object - used to trace each step
    let activityManager: CMMotionActivityManager = CMMotionActivityManager()
    let pedometer: CMPedometer = CMPedometer()
    
    // Gyro Sensor
    let motionManager: CMMotionManager = CMMotionManager()
    var gyroArray: [CMRotationRate] = []
    
    // Responsive button sounds
    var player: AVAudioPlayer?
    
    // Triggering the button's three states
    var buttonState: Int = 0
    
    // Used to track pedometer when saving data
    var steps: Int32?
    
    // Local Storage
    var travelPoints: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocationPermission()
        enableDoubleTap()
        loadData()
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
    
    // Testing purposes
    func createExportString() -> String {
        var time: Date
        var steps: Int32
        var lat: Double
        var long: Double
        var gyro: String
        var export: String = NSLocalizedString("Time, Steps Taken, Lat, Long, Gyro \n", comment: "")
        for (index, point) in travelPoints.enumerated() {
            if (index < travelPoints.count - 1) {
                time = (point.value(forKey: "time") as? Date)!
                steps = (point.value(forKey: "steps") as? Int32)!
                lat = (point.value(forKey: "lat") as? Double)!
                long = (point.value(forKey: "long") as? Double)!
                gyro = (point.value(forKey: "gyroArray") as? String ?? "")
                
                let timeString = "\(String(describing: time))"
                let stepString = "\(String(describing: steps))"
                let latString = "\(String(describing: lat))"
                let longString = "\(String(describing: long))"
                let gyroString = "\(String(describing: gyro))"
                
                export += timeString + "," + stepString + "," + latString + "," + longString + "," + gyroString + "\n"
            }
        }
        return export
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
            print(createExportString())
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
                self.saveData(currTime: Date(), steps: (self.steps ?? 0),
                              lat: coordinate.latitude, long: coordinate.longitude)
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
                self?.steps = Int32(truncating: pedometerData.numberOfSteps)
            }
        }
    }
    
    /**
        Saves the given data into the stack within CoreData, and clears out the gyroscope data to start taking values again
        - Parameters:
            - currTime: Date in which the data has been tracked
            - stepsTaken: Steps that have been taken
            - xCoord: x coordinate the user is standing at
            - yCoord: y coordinate the user is standing at
     */
    func saveData(currTime: Date, steps: Int32, lat: Double, long: Double) {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        
        let entity =
          NSEntityDescription.entity(forEntityName: "CurrentSeq",
                                     in: managedContext)!
        
        let point = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        let gyroString: String = generateGyroString()
//        let gyroString: String = "1/2/3, 4/5/6"
        
        point.setValue(currTime, forKeyPath: "time")
        point.setValue(steps, forKeyPath: "steps")
        point.setValue(lat, forKeyPath: "lat")
        point.setValue(long, forKeyPath: "long")
        point.setValue(gyroString, forKeyPath: "gyroArray")
        
        // Clear the gyroscope data after getting its string representation
        gyroArray.removeAll()
        
        do {
          try managedContext.save()
          travelPoints.append(point)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /**
       Loads all of the NSManagedObject array, so that it can be accessed by the device
       - Parameters:
           - currTime: Date in which the data has been tracked
           - stepsTaken: Steps that have been taken
           - xCoord: x coordinate the user is standing at
           - yCoord: y coordinate the user is standing at
    */
    func loadData() {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "CurrentSeq")
        
        //3
        do {
          travelPoints = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func clearData() { travelPoints.removeAll() }
    
    // Gyroscope Functions
    
    // Starts the gyroscope once it is confirmed to be available
    func startGyro() {
        if motionManager.isGyroAvailable {
            // Set to update 5 times a second
            self.motionManager.gyroUpdateInterval = 0.2
            self.motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
                if let gyroData = data {
                    self.gyroArray.append(gyroData.rotationRate)
                    // Ex (output):
                    // CMRotationRate(x: 0.6999756693840027, y: -1.379577398300171, z: -0.3633846044540405)
                }
            }
        }
    }
    
    // Stops the gyroscope (assuming that it is available)
    func stopGyros() { self.motionManager.stopGyroUpdates() }
    
    func generateGyroString() -> String {
        var result: String = ""
        var currPoint: String = ""
        for gyro in gyroArray {
            currPoint = "\(String(describing: gyro.x))" + "/"
                        + "\(String(describing: gyro.y))" + "/"
                        + "\(String(describing: gyro.z))" + ", "
            result += currPoint
        }
        return result
    }
    
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
    
    func saveEmail(_ email: String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
//        defaults.synchronize()
    }
    
    func getEmail() -> String {
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "email")
        return email!
    }
}

