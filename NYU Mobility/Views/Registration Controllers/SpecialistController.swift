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
import FirebaseAuth
import JGProgressHUD

class SpecialistController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
        if (password.text!.count == 0 || name.text!.count == 0 ||
            email.text!.count == 0) {
            alertUserRegistrationError()
            return
        }
        
        // The password is not long enough
        if (password.text!.count < 6) {
            alertUserRegistrationError(message: "Password must be at least 6 characters long")
            return
        }
        
        spinner.show(in: view)
        
        // Firebase register attempt
        DatabaseManager.shared.userExists(with: email.text!, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                strongSelf.alertUserRegistrationError(message: "It seems that a user for that email already exists")
                return
            }
            
            // If the user does not exist -> Add
            FirebaseAuth.Auth.auth().createUser(withEmail: self!.email.text!, password: self!.password.text!, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Error adding user")
                    return
                }
                
                // Saves all of the user defaults
                self!.save("name", self!.name.text!)
                self!.save("email", self!.email.text!)
                self!.save("username", self!.email.text!)
                self!.save("password", self!.password.text!)
                self!.generateCode()
                
                let specialist = SpecialistUser(fullName: self!.name.text!,
                                                username: self!.email.text!,
                                                password: self!.password.text!,
                                                code: UserDefaults.standard.string(forKey: "code")!)
                DatabaseManager.shared.insertSpecialistUser(with: specialist, completion: { success in
                    self!.performSegue(withIdentifier: "ShowCode", sender: self)
                })
            })
        })
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
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
//                                               name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
//                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//     Called when we leave this view controller, whether that is going back or finished
    override func viewDidDisappear(_ animated: Bool) {
        // Cleaning up to avoid any unnecessary notification messages
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
//                                                  object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
//                                                  object: nil)
    }
    
    @IBAction func keyboardStays(_ sender: UITextField) {
        last = sender
    }

//    @objc func keyboardWillHide(notification: NSNotification) {
//        if view.frame.origin.y != 0 {
//            view.frame.origin.y = 0
//        }
//    }
    
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
