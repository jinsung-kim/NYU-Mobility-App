//
//  RegistrationController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Device

class RegistrationController: UIViewController {
    
    // Client button
    @IBOutlet weak var clientButton: CustomAdd!
    
    // Specialist button
    @IBOutlet weak var specialistButton: CustomAdd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.skipRegistration()
        self.buttonConstraints()
    }
    
    func buttonConstraints() {
        // 4.0 inch screen iPhone SE (only device that needs smaller buttons)
        if (Device.size() == Size.screen4Inch) {
            clientButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            specialistButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            // Client button styling
            clientButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
            // Specialist button styling
            specialistButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
        }
        clientButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        specialistButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func getRegistered() -> Bool {
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "email")
        let name = defaults.string(forKey: "name")
        if (email == "" || name == "") {
            return false
        }
        return true
    }
    
    @IBAction func clientMode(_ sender: Any) {
        self.setMode("client")
    }
    
    @IBAction func specialistMode(_ sender: Any) {
        self.setMode("specialist")
    }
    
    func skipRegistration() {
        if (self.getRegistered() && self.getMode() == "client") {
            self.performSegue(withIdentifier: "SkipRegistration", sender: self)
        } else if (self.getRegistered() && self.getMode() == "specialist") {
            self.performSegue(withIdentifier: "SkipSpecialist", sender: self)
        }
    }
    
    func setMode(_ mode: String) {
        let defaults = UserDefaults.standard
        defaults.set(mode, forKey: "mode")
    }
    
    func getMode() -> String {
        let defaults = UserDefaults.standard
        let mode = defaults.string(forKey: "mode")
        return mode!
    }
}


