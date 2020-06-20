//
//  TrackingController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 5/29/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreData // Local storage (user saved locations)
import CoreMotion // Used to track user movement
import CoreLocation // Used to access coordinate data
import AVFoundation // Used to play sounds
import MessageUI // Used to send emails

class TrackingController: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    
    // What is used to change color
    @IBOutlet var viewer: UIView!
    
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
    // Used to store all x, y, z values
    private var gyroDict: [String: [Double]] = ["x": [], "y": [], "z": []]
    
    // Pace trackers
    private var currPace: Double = 0.0
    private var avgPace: Double = 0.0
    private var currCad: Double = 0.0
    
    // Responsive button sounds
    var player: AVAudioPlayer?
    
    // Triggering the button's three states
    private var buttonState: Int = 0
    
    // Used to track pedometer when saving data
    var steps: Int32 = 0
    var distance: Int32 = 0 // In meters
    
    // Used for creating the JSON
    var points: [Point] = []
    var coords: [CLLocationCoordinate2D] = []
    
    // Local Storage
    var userLocations: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton()
        getLocationPermission() // Permission to track
        enableDoubleTap() // Double tap feature
        loadData() // Gets user saved locations
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (getEmail() == "") {
            showInputDialog(title: "Add Email",
                            subtitle: "Enter the email of your clinician who will view your data",
                            actionTitle: "Add",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "Email: ",
                            inputKeyboardType: .emailAddress)
            { (input:String?) in
                self.saveEmail(input!)
            }
        }
    }
    
    // Used to send over data to MapView Controller to read out results
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MapViewController
        {
            let vc = segue.destination as? MapViewController
            vc?.steps = self.steps
            vc?.coords = self.coords
            vc?.distance = self.distance
        }
    }
    
    func settingsButton() {
        let settingsButton = UIBarButtonItem()
        settingsButton.title = "Settings"
        settingsButton.action = #selector(settingsTap)
        settingsButton.target = self
        self.navigationItem.rightBarButtonItem = settingsButton
    }
    
    func enableDoubleTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TrackingController.labelTapped(recognizer: )))
        tapGestureRecognizer.numberOfTapsRequired = 2
        
        trackingButton.isUserInteractionEnabled = true
        trackingButton.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func settingsTap() {
        playSound("settings")
        self.performSegue(withIdentifier: "SettingsSegue", sender: self)
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
            self.performSegue(withIdentifier: "MapViewSegue", sender: self)
            sendEmail(jsonData: saveAndExport(exportString: generateJSON()))
            clearData()
            playSound("reset")
            sender.setTitle("Start", for: .normal)
            self.viewer.backgroundColor = UIColor.white
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
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for _ in locations { // _ -> currentLocation
            
            if let location: CLLocation = locationManager.location {
                let coordinate: CLLocationCoordinate2D = location.coordinate
                
                self.coords.append(coordinate)

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
            self?.distance = 0
            self?.saveData(currTime: Date(), steps: 0)
        }
    }
    
    func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
          [weak self] pedometerData, error in
          guard let pedometerData = pedometerData, error == nil else { return }

            // Runs concurrently
            DispatchQueue.main.async {
                self?.saveData(currTime: Date(),
                               steps: (pedometerData.numberOfSteps as! Int32))
                self?.distance = Int32(truncating: pedometerData.distance ?? 0)
                self?.steps = Int32(truncating: pedometerData.numberOfSteps)
                self?.avgPace = Double(truncating: pedometerData.averageActivePace ?? 0)
                self?.currPace = Double(truncating: pedometerData.currentPace ?? 0)
                self?.currCad = Double(truncating: pedometerData.currentCadence ?? 0)
            }
        }
    }
    
    /**
        Saves the given data into the stack, and clears out the gyroscope data to start taking values again
        - Parameters:
            - currTime: Date in which the data has been tracked
            - stepsTaken: Steps that have been taken
     */
    func saveData(currTime: Date, steps: Int32) {
        // JSON array implementation (See Point.swift for model)
        points.append(Point(dateFormatter(), steps, self.distance, self.avgPace,
                            self.currPace, self.currCad,
                            self.locationArray, self.gyroDict))
        
        // Clear the gyroscope data after getting its string representation
        self.gyroDict.removeAll()
        self.locationArray.removeAll()
    }
    
    func clearData() {
        points.removeAll()
        coords.removeAll()
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
    
    // Sound Functionality
    
    /**
        Plays a sound given the state of the button
        - Parameters:
            - fileName: The name of the file being executed (all within 'Sound' group)
     */
    func playSound(_ fileName: String) {
        if (getState()) {
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
    }
    
    // Export Functionality
    func saveAndExport(exportString: String) -> Data {
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
        
        fileHandle?.seekToEndOfFile()
        let jsonData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        // Writes the JSON data into the file
        fileHandle?.write(jsonData!)
        fileHandle?.closeFile()
        return jsonData ?? Data()
    }
    
    // Gesture Functionality
    func getState() -> Bool {
        let defaults = UserDefaults.standard
        let gesture = defaults.bool(forKey: "state")
        return gesture
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
    
    func sendEmail(jsonData: Data) {
        let recipientEmail = getEmail()
        let subject = "JSON Export"
        let body = "Here is the data that I tracked"

        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            
            mail.addAttachmentData(jsonData, mimeType: "application/json" , fileName: "export.json")

            present(mail, animated: true)

        // Show third party email composer if default Mail app is not present
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        return defaultUrl
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // User Location Saved
    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "UserSaved")
        
        do {
            userLocations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}

// Pop up text field for initial sign up
extension UIViewController {
    func showInputDialog(title: String? = nil,
                         subtitle: String? = nil,
                         actionTitle: String? = "Add",
                         cancelTitle: String? = "Cancel",
                         inputPlaceholder: String? = nil,
                         inputKeyboardType: UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))

        self.present(alert, animated: true, completion: nil)
    }
}
