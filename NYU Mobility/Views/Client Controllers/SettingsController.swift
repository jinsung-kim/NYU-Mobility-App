//
//  SettingsController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import CoreLocation

class SettingsController: UITableViewController {

    // Switch label
    @IBOutlet weak var gestureSwitch: UISwitch!
    
    // Clinician's email label
    @IBOutlet weak var clinicianEmail: UILabel!
    
    // Location Labels -> Currently supports up to 5 locations
    @IBOutlet weak var firstLoc: UILabel!
    @IBOutlet weak var secondLoc: UILabel!
    @IBOutlet weak var thirdLoc: UILabel!
    @IBOutlet weak var fourthLoc: UILabel!
    @IBOutlet weak var fifthLoc: UILabel!
    
    // Buttons associated to the location labels above
    @IBOutlet weak var firstBut: UIButton!
    @IBOutlet weak var secondBut: UIButton!
    @IBOutlet weak var thirdBut: UIButton!
    @IBOutlet weak var fourthBut: UIButton!
    @IBOutlet weak var fifthBut: UIButton!
    
    var player: AVAudioPlayer?
    
    // Local Storage
    var userLocations: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        updateLabels()
        updateButtons()
        gestureSwitch.isOn = UserDefaults.standard.bool(forKey: "state")
    }
    
    @IBAction func unwindSettings(_ sender: UIStoryboardSegue) {}
    
    // When it returns to the settings page
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        updateLabels()
        updateButtons()
    }
    
    // Leaving the settings page
    override func viewWillDisappear(_ animated: Bool) {
        playSound("back")
    }
   
    @IBAction func changeEmailPressed(_ sender: Any) {
        showInputDialog(title: "Add Email",
                        subtitle: "Enter the email of your clinician who will view your data",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Email: ",
                        inputKeyboardType: .emailAddress)
        { (input: String?) in
            self.save("email", input!)
        }
    }
    
    // Logs out of the current system -> Deletes all of their saved variables
    @IBAction func logoutPressed(_ sender: Any) {
        save("email", "")
        save("username", "")
        save("password", "")
        save("name", "")
        save("code", "")
    }
    
    // Updates all of the labels as necessary, based on what the user has already inputted
    func updateLabels() {
        clinicianEmail.text = "Clinician Email: \(getEmail())"
        let arr: [UILabel] = [firstLoc, secondLoc, thirdLoc, fourthLoc, fifthLoc]
        for (index, point) in userLocations.enumerated() {
            arr[index].text = "\(String(describing: point.value(forKey: "name")!)): \(String(describing: point.value(forKey: "address")!))"
        }
        for j in userLocations.count ..< 5 {
            arr[j].text = "None"
        }
    }
    
    func updateButtons() {
        let arr: [UIButton] = [firstBut, secondBut, thirdBut, fourthBut, fifthBut]
        for i in 0 ..< userLocations.count {
            arr[i].setTitle("Delete", for: .normal)
        }
        // Rest of them should be "Add" buttons to redirect to the form
        for j in userLocations.count ..< 5 {
            arr[j].setTitle("Add", for: .normal)
        }
    }
    
    @IBAction func responsiveGestureSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "state")
    }
    
    // Button Handler
    @IBAction func pressed(_ sender: UIButton) {
        switch (sender) {
        case firstBut:
            update(0)
        case secondBut:
            update(1)
        case thirdBut:
            update(2)
        case fourthBut:
            update(3)
        case fifthBut:
            update(4)
        default:
            print("Shouldn't happen")
        }
    }
    
    func update(_ index: size_t) {
        // Make sure that there is a valid address at that point
        if (index < userLocations.count) {
            deleteData(index)
            userLocations.remove(at: index)
            updateLabels()
            updateButtons()
        } else {
            // Moves onto the Form controller
            performSegue(withIdentifier: "FormSegue", sender: self)
        }
    }
    
    // Sound Functionality
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
    
    // Email Functionality:
    func getEmail() -> String {
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "email")
        return email!
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    // State Functionality:
    func getState() -> Bool {
        let defaults = UserDefaults.standard
        let gesture = defaults.bool(forKey: "state")
        return gesture
    }
    
    func saveState(_ state: String) {
        let defaults = UserDefaults.standard
        defaults.set(state, forKey: "state")
    }
    
    // Load all of the points
    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserSaved")
        
        do {
            userLocations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Deleting CoreData object
    func deleteData(_ index: size_t) {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            context.delete(userLocations[index])
            try context.save()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
}

// Pop up text field for email change
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
