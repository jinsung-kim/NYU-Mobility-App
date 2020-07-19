//
//  LoginController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/13/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Device

class LoginController: UIViewController {
    
    // Text fields to fill up
    @IBOutlet weak var username: CustomText!
    @IBOutlet weak var password: CustomText!
    
    // Login Button
    @IBOutlet weak var loginButton: CustomAdd!
    
    var last: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelAdjustments()
        exitEdit()
    }
    
    @IBAction func loginSubmitted(_ sender: Any) {
        // Save values
        save("username", username.text!)
        save("password", password.text!)
        // Redirects to the proper storyboard reference via "show" segue
        if (self.getMode() == "client" && self.validLogin()) { // going to client mode
            self.performSegue(withIdentifier: "LoggedInClient", sender: self)
        } else if (self.getMode() == "specialist" && self.validLogin()){ // going to specialist mode
            self.performSegue(withIdentifier: "LoggedInSpecialist", sender: self)
        } // else do nothing (don't redirect) -> create error message
    }
    
    func labelAdjustments() {
        if (Device.size() == Size.screen4Inch) {
            username.widthAnchor.constraint(equalToConstant: 250).isActive = true
            password.widthAnchor.constraint(equalToConstant: 250).isActive = true
        } else {
            username.widthAnchor.constraint(equalToConstant: 350).isActive = true
            password.widthAnchor.constraint(equalToConstant: 350).isActive = true
        }
        
        loginButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [username, password])
    }
    
    func exitEdit() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "\(key)")
    }
    
    func getMode() -> String {
        let defaults = UserDefaults.standard
        let mode = defaults.string(forKey: "mode")
        return mode!
    }
    
    func validLogin() -> Bool {
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "username")
        let name = defaults.string(forKey: "password")
        if (email == "" || name == "") {
            return false
        }
        return true
    }
    
}
