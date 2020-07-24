//
//  ClientController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Device

class ClientController: UIViewController, UITextFieldDelegate {
    
    // Text fields
    @IBOutlet weak var fullName: CustomText!
    @IBOutlet weak var specialistEmail: CustomText!
    @IBOutlet weak var specialistCode: CustomText!
    @IBOutlet weak var username: CustomText!
    @IBOutlet weak var password: CustomText!
    
    @IBOutlet weak var registerButton: CustomAdd!
    @IBOutlet weak var loginRedirect: CustomAdd!
    
    var last: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelAdjustments()
        exitEdit()
    }
    
    func labelAdjustments() {
        // 4.0 inch screen iPhone SE (only device that needs smaller buttons)
        if (Device.size() == Size.screen4Inch) {
            fullName.widthAnchor.constraint(equalToConstant: 250).isActive = true
            username.widthAnchor.constraint(equalToConstant: 250).isActive = true
            password.widthAnchor.constraint(equalToConstant: 250).isActive = true
            specialistEmail.widthAnchor.constraint(equalToConstant: 250).isActive = true
            specialistCode.widthAnchor.constraint(equalToConstant: 250).isActive = true
        } else {
            // UI design for labels
            fullName.widthAnchor.constraint(equalToConstant: 350).isActive = true
            username.widthAnchor.constraint(equalToConstant: 350).isActive = true
            password.widthAnchor.constraint(equalToConstant: 350).isActive = true
            specialistEmail.widthAnchor.constraint(equalToConstant: 350).isActive = true
            specialistCode.widthAnchor.constraint(equalToConstant: 350).isActive = true
        }
                
        registerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        loginRedirect.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loginRedirect.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [fullName, username, password, specialistEmail, specialistCode])
        
        // Keyboard settings
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Called when we leave this view controller, whether that is going back or finished
    override func viewDidDisappear(_ animated: Bool) {
        // Cleaning up to avoid any unnecessary notification messages
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @IBAction func keyboardStays(_ sender: CustomText) {
        last = sender
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if (last != fullName && last != username && last != password) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func exitEdit() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Once the user hits the register button, all of the boxes that they filled will be saved
    @IBAction func registered(_ sender: Any) {
        self.save("email", specialistEmail.text!)
        self.save("username", username.text!)
        self.save("password", password.text!)
        self.save("name", fullName.text!)
        self.save("code", specialistCode.text!)
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "\(key)")
    }
}

