//
//  ClientController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class ClientController: UIViewController, UITextFieldDelegate {
    
    // Text fields
    @IBOutlet weak var fullName: CustomText!
    @IBOutlet weak var specialistEmail: CustomText!
    @IBOutlet weak var specialistCode: CustomText!
    
    @IBOutlet weak var registerButton: CustomAdd!
    
    var last: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelAdjustments()
        exitEdit()
    }
    
    func labelAdjustments() {
        registerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // UI design for labels
        fullName.widthAnchor.constraint(equalToConstant: 350).isActive = true
        specialistEmail.widthAnchor.constraint(equalToConstant: 350).isActive = true
        specialistCode.widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [fullName, specialistEmail, specialistCode])
        
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
        if (last != fullName && last != specialistEmail) {
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
    
    @IBAction func registered(_ sender: Any) {
        saveEmail(specialistEmail.text!)
        saveName(fullName.text!)
        saveCode(specialistCode.text!)
    }
    
    func saveEmail(_ email: String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
    }
    
    func saveName(_ name: String) {
        let defaults = UserDefaults.standard
        defaults.set(name, forKey: "name")
    }
    
    func saveCode(_ code: String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey: "code")
    }
}

