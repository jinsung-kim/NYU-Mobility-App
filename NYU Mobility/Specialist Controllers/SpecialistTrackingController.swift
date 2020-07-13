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

class SpecialistTrackingController: UIViewController {
    
    @IBOutlet weak var trackingButton: UIButton!
    @IBOutlet var viewer: UIView!
    
    var name: String?
    
    private var buttonState: Int = 0
    
    // Used to track pedometer when saving data
    var steps: Int32 = 0
    var maxSteps: Int32 = 0
    var distance: Int32 = 0 // In meters
    var maxDistance: Int32 = 0
    var startTime: Date = Date()
    
    // Used for creating the JSON
    var points: [SpecialistPoint] = []
    
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
        storageButton()
    }

    // Upper right item from the tracking controller that goes to the settings
    func storageButton() {
        self.viewer.backgroundColor = Colors.nyuPurple
        let storageButton = UIBarButtonItem()
        storageButton.title = "See Sessions"
        storageButton.action = #selector(sessionsTap)
        storageButton.target = self
        self.navigationItem.rightBarButtonItem = storageButton
    }
    
    @objc func sessionsTap() {
        self.performSegue(withIdentifier: "SeeSessions", sender: self)
    }
    
    // Used to send over data to the Storage Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is StorageController {
            let vc = segue.destination as? StorageController
            vc?.name = self.name!
        }
    }
    
    // Goes together with enableDoubleTap
    @objc func labelTapped(recognizer: UITapGestureRecognizer) {
        if (self.buttonState == 1) {
            trackingButton.setTitle("Resume", for: .normal)
            self.buttonState = 3
            trackingChange(trackingButton)
        } else {
            trackingButton.setTitle("Pause", for: .normal)
            self.buttonState = 4
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
        switch(self.buttonState) {
        case 0:
            startTracking()
            startTime = Date()
            sender.setTitle("Stop", for: .normal)
            self.buttonState = 1
        case 1:
            stopTracking()
            sender.setTitle("Reset", for: .normal)
            self.buttonState = 2
        case 2:
            savePoint() // Saves into Core Data
            clearData()
            sender.setTitle("Start", for: .normal)
            self.buttonState = 0
        case 3:
            stopTracking()
            self.buttonState = 0
        case 4:
            startTracking()
            sender.setTitle("Stop", for: .normal)
            self.buttonState = 1
        default: // Should never happen
            print("Unexpected case: \(self.buttonState)")
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
        startGyro()
        startUpdating()
    }
    
    /**
        Stops tracking the gyroscope, GPS location, and pedometer object
        Assumes that the previously stated managers are running
     */
    func stopTracking() {
        stopUpdating()
        stopGyros()
        self.saveData(currTime: Date())
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
        if (self.steps >= self.maxSteps) {
            self.maxSteps = self.steps
        }
        if (self.distance >= self.maxDistance) {
            self.maxDistance = self.distance
        }
        if (self.maxDistance != 0 && self.maxSteps != 0) {
            points.append(SpecialistPoint(dateFormatter(), self.maxSteps, self.maxDistance, self.avgPace,
                                self.currPace, self.currCad, self.gyroDict))
            
            // Clear the gyroscope data after getting its string representation
            self.gyroDict.removeAll()
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
        session.setValue(self.name!, forKeyPath: "user")
        
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
