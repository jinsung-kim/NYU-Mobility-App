//
//  ClientController.swift
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

class ClientController: UIViewController, UITextFieldDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    // Text fields
    @IBOutlet weak var fullName: CustomTextField!
    @IBOutlet weak var clientEmail: CustomTextField!
    @IBOutlet weak var password: CustomTextField!
    @IBOutlet weak var specialistEmail: CustomTextField!
    @IBOutlet weak var specialistCode: CustomTextField!

    @IBOutlet weak var registerButton: CustomButton!
    @IBOutlet weak var loginRedirect: CustomButton!
    
    var last: UITextField?
    
    // Database setup
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelAdjustments()
        exitEdit()
    }
    
    func labelAdjustments() {
        // 4.0 inch screen iPhone SE (only device that needs smaller buttons)
        if (Device.size() == Size.screen4Inch) {
            fullName.widthAnchor.constraint(equalToConstant: 250).isActive = true
            clientEmail.widthAnchor.constraint(equalToConstant: 250).isActive = true
            password.widthAnchor.constraint(equalToConstant: 250).isActive = true
            specialistEmail.widthAnchor.constraint(equalToConstant: 250).isActive = true
            specialistCode.widthAnchor.constraint(equalToConstant: 250).isActive = true
        } else {
            // UI design for labels
            fullName.widthAnchor.constraint(equalToConstant: 350).isActive = true
            clientEmail.widthAnchor.constraint(equalToConstant: 350).isActive = true
            password.widthAnchor.constraint(equalToConstant: 350).isActive = true
            specialistEmail.widthAnchor.constraint(equalToConstant: 350).isActive = true
            specialistCode.widthAnchor.constraint(equalToConstant: 350).isActive = true
        }
                
        registerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        loginRedirect.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loginRedirect.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [fullName, clientEmail, password, specialistEmail, specialistCode])
        
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
    
    @IBAction func keyboardStays(_ sender: CustomTextField) {
        last = sender
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if (last != fullName && last != clientEmail && last != password) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if view.frame.origin.y == 0 {
                    view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    func exitEdit() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Once the user hits the register button, all of the boxes that they filled will be saved
    @IBAction func registered(_ sender: Any) {
        // At least one text field is empty
        // Uncomment all guards when launching
        if (password.text!.count == 0 || fullName.text!.count == 0 ||
            clientEmail.text!.count == 0 || specialistEmail.text!.count == 0) {
            alertUserRegistrationError()
            return
        }
        
        // Missing specialist code
        if (specialistCode.text!.count == 0) {
            alertUserRegistrationError(message: "You need a specialist code to use the application")
            return
        }
        
        // The password is not long enough
        if (password.text!.count < 6) {
            alertUserRegistrationError(message: "Password must be at least 6 characters long")
            return
        }
        
        spinner.show(in: view)
        
        // Firebase register attempt
        DatabaseManager.shared.userExists(with: clientEmail.text!, completion: { [weak self] exists in
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
            FirebaseAuth.Auth.auth().createUser(withEmail: self!.clientEmail.text!, password: self!.password.text!, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Error adding user")
                    return
                }
                
                // Saves all of the user defaults
                self!.save("email", self!.specialistEmail.text!)
                self!.save("username", self!.clientEmail.text!) // email treated as username
                self!.save("password", self!.password.text!)
                self!.save("name", self!.fullName.text!)
                self!.save("code", self!.specialistCode.text!)
                
                let client = ClientUser(fullName: self!.fullName.text!,
                                        username: self!.clientEmail.text!,
                                        password: self!.password.text!,
                                        code: self!.specialistCode.text!)
                
                DatabaseManager.shared.insertClientUser(with: client, completion: { success in
                    if success {
                        // if successful -> redirect
                        self!.performSegue(withIdentifier: "ToClient", sender: self)
                    }
                })
            })
        })
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "\(key)")
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

