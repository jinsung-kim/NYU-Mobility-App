//
//  SpecialistController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Device
import FirebaseDatabase

class SpecialistController: UIViewController {
    
    // Text fields to fill up
    @IBOutlet weak var name: CustomTextField!
    @IBOutlet weak var password: CustomTextField!
    @IBOutlet weak var email: CustomTextField!
    
    // Register button
    @IBOutlet weak var registerButton: CustomButton!
    // Login instead -> redirect
    @IBOutlet weak var loginRedirect: CustomButton!
    
    var last: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelAdjustments()
        exitEdit()
    }
    
    @IBAction func registered(_ sender: Any) {
        // At least one text field is empty
//        if (password.text!.count == 0 || name.text!.count == 0 ||
//            username.text!.count == 0 || email.text!.count == 0) {
//            alertUserRegistrationError()
//            return
//        }
        
        // The password is not long enough
//        if (password.text!.count < 6) {
//            alertUserRegistrationError(message: "Password must be at least 6 characters long")
//            return
//        }
        
        // Firebase register attempt
        
        
        save("name", name.text!)
        save("email", email.text!)
        save("username", email.text!)
        save("password", password.text!)
        generateCode()
        performSegue(withIdentifier: "ShowCode", sender: self)
    }
    
    func labelAdjustments() {
        if (Device.size() == Size.screen4Inch) {
            name.widthAnchor.constraint(equalToConstant: 250).isActive = true
            password.widthAnchor.constraint(equalToConstant: 250).isActive = true
            email.widthAnchor.constraint(equalToConstant: 250).isActive = true
        } else {
            name.widthAnchor.constraint(equalToConstant: 350).isActive = true
            password.widthAnchor.constraint(equalToConstant: 350).isActive = true
            email.widthAnchor.constraint(equalToConstant: 350).isActive = true
        }
        
        registerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginRedirect.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loginRedirect.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [name, email, password])
        
        // Keyboard settings
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//     Called when we leave this view controller, whether that is going back or finished
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
//        if (last != name && last != email && last != password) {
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                if view.frame.origin.y == 0 {
//                    view.frame.origin.y -= keyboardSize.height
//                }
//            }
//        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    func exitEdit() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "\(key)")
    }
    
    func generateCode() {
        let uuid = UUID().uuidString[0 ..< 8]
        let defaults = UserDefaults.standard
        defaults.set(uuid, forKey: "code")
    }
    
    // Error Messages
    func alertUserRegistrationError(message: String = "Please enter all information to create a new account.") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

// Used to truncate UUID string code
extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start ... end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start ..< end])
    }
}
