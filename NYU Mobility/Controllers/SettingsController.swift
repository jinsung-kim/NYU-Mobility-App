//
//  SettingsController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsController: UITableViewController {

    // Switch label
    @IBOutlet weak var gestureSwitch: UISwitch!
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gestureSwitch.isOn = UserDefaults.standard.bool(forKey: "state")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (getState()) {
            playSound("back")
        }
    }
    
    @IBAction func changeEmailPressed(_ sender: Any) {
        showInputDialog(title: "Add Email",
                        subtitle: "Enter the email of your clinician who will view your data",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Email: ",
                        inputKeyboardType: .emailAddress)
        { (input: String?) in
            self.saveEmail(input!)
        }
    }
    
    @IBAction func responsiveGestureSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "state")
    }
    
    // Sound Functionality
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
    }
    
    func saveState(_ state: String) {
        let defaults = UserDefaults.standard
        defaults.set(state, forKey: "state")
    }
    
    func getState() -> Bool {
        let defaults = UserDefaults.standard
        let gesture = defaults.bool(forKey: "state")
        return gesture
    }
    
}
