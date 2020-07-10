//
//  SpecialistController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class SpecialistController: UIViewController {
    
    // Text fields to fill up
    @IBOutlet weak var name: CustomText!
    @IBOutlet weak var email: CustomText!
    
    // Register button
    @IBOutlet weak var registerButton: CustomAdd!
    // Login instead button
    
    
    var last: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelAdjustments()
        exitEdit()
    }
    
    @IBAction func registered(_ sender: Any) {
        saveName(name.text!)
        saveEmail(email.text!)
        generateCode()
    }
    
    func labelAdjustments() {
        
        registerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        name.widthAnchor.constraint(equalToConstant: 350).isActive = true
        email.widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [name, email])
        
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
    
    @IBAction func keyboardStays(_ sender: UITextField) {
        last = sender
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if (last != name) {
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
    
    func saveEmail(_ email: String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
    }
    
    func saveName(_ name: String) {
        let defaults = UserDefaults.standard
        defaults.set(name, forKey: "name")
    }
    
    func generateCode() {
        let uuid = UUID().uuidString
        let defaults = UserDefaults.standard
//        var code: String = ""
        defaults.set(uuid, forKey: "code")
    }
    
}
