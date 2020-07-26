//
//  SpecialistTrackingController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData
import CoreLocation

class SpecialistTrackingController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var trackingButton: UIButton!
    @IBOutlet weak var recordSessionButton: UIButton!
    @IBOutlet var viewer: UIView!
    @IBOutlet weak var circleView: UIView!
    
    var name: String?
    
    private var buttonState: Int = 0
    
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
        loadData()
        createCircleView()
        getLocationPermission() // Permission to track
        storageButton()
        recordSessionColor()
    }

    // Upper right item from the tracking controller that goes to the settings
    func storageButton() {
        viewer.backgroundColor = Colors.nyuPurple
        let storageButton = UIBarButtonItem()
        storageButton.title = "See Sessions"
        storageButton.action = #selector(sessionsTap)
        storageButton.target = self
        navigationItem.rightBarButtonItem = storageButton
    }
    
    func createCircleView() {
        circleView.layer.cornerRadius = 120 // half the width / height
        circleView.backgroundColor = Colors.nyuPurple
    }
    
    func recordSessionColor() {
        recordSessionButton.backgroundColor = Colors.nyuPurple
    }
    
    @objc func sessionsTap() {
        performSegue(withIdentifier: "SeeSessions", sender: self)
    }
    
    // Used to send over data to the Storage Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is StorageController) {
            let vc = segue.destination as? StorageController
            vc?.name = name!
        // Even the tracking done within the
        } else if (segue.destination is VideoRecordingController) {
            let vc = segue.destination as? VideoRecordingController
            vc?.name = name!
        }
    }
    
    // Goes together with enableDoubleTap
    @objc func labelTapped(recognizer: UITapGestureRecognizer) {
        if (buttonState == 1) {
            trackingButton.setTitle("Resume", for: .normal)
            buttonState = 3
            trackingChange(trackingButton)
        } else {
            trackingButton.setTitle("Pause", for: .normal)
            buttonState = 4
            trackingChange(trackingButton)
        }
    }
    
    func dateFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = formatter.string(from: Date())
        return dateString
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
    @IBAction func trackingChange(_ sender: UIButton) {
        switch(buttonState) {
        case 0:
            startTracking()
            startTime = Date()
            sender.setTitle("Stop", for: .normal)
            buttonState = 1
        case 1:
            stopTracking()
            sender.setTitle("Reset", for: .normal)
            buttonState = 2
        case 2:
            savePoint() // Saves into Core Data
            clearData()
            sender.setTitle("Start", for: .normal)
            buttonState = 0
        case 3:
            stopTracking()
            buttonState = 0
        case 4:
            startTracking()
            sender.setTitle("Stop", for: .normal)
            buttonState = 1
        default: // Should never happen
            print("Unexpected case: \(buttonState)")
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
    }
    
    /**
        Stops tracking the gyroscope, GPS location, and pedometer object
        Assumes that the previously stated managers are running
     */
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        stopUpdating()
        stopGyros()
        saveData(currTime: Date())
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
            self?.saveData(currTime: Date())
        }
    }
    
    func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
          [weak self] pedometerData, error in
          guard let pedometerData = pedometerData, error == nil else { return }

            // Runs concurrently
            DispatchQueue.main.async {
                self?.saveData(currTime: Date())
                self?.distance = Int32(truncating: pedometerData.distance ?? 0)
                self?.steps = Int32(truncating: pedometerData.numberOfSteps)
                self?.avgPace = Double(truncating: pedometerData.averageActivePace ?? 0)
                self?.currPace = Double(truncating: pedometerData.currentPace ?? 0)
                self?.currCad = Double(truncating: pedometerData.currentCadence ?? 0)
            }
        }
    }
    
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
    
    /**
        Saves the given data into the stack, and clears out the gyroscope data to start taking values again
        - Parameters:
            - currTime: Date in which the data has been tracked
     */
    func saveData(currTime: Date) {
        // JSON array implementation (See Point.swift for model)
        if (steps >= maxSteps) {
            maxSteps = steps
        }
        if (distance >= maxDistance) {
            maxDistance = distance
        }
        if (maxDistance != 0 && maxSteps != 0) {
            points.append(Point(dateFormatter(), maxSteps, maxDistance,
                                          avgPace, currPace, currCad, locationArray, gyroDict))
            
            // Clear the gyroscope data after getting its string representation
            gyroDict.removeAll()
        }
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
    
    // Saves Point
    func savePoint() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Session",
                                                in: managedContext)!
        
        let session = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        session.setValue(generateJSON(), forKeyPath: "json")
        session.setValue(startTime, forKeyPath: "startTime")
        session.setValue(name!, forKeyPath: "user")
        session.setValue("", forKeyPath: "videoURL") // no video url for this type of sessions
        
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
                    // CMRotationRate(x: 0.6999756693840027, y: -1.379577398300171, z: -0.3633846044540405)
                }
            }
        }
    }
    
    // Stops the gyroscope (assuming that it is available)
    func stopGyros() { self.motionManager.stopGyroUpdates() }
    
}
