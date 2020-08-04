//
//  LoginController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/13/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Device
import FirebaseDatabase
import FirebaseAuth
import JGProgressHUD

class LoginController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    // Text fields to fill up
    @IBOutlet weak var username: CustomTextField!
    @IBOutlet weak var password: CustomTextField!
    
    @IBOutlet weak var loginButton: CustomButton!
    
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
        if (getMode() == "client" && validLogin()) { // going to client mode
            self.performSegue(withIdentifier: "LoggedInClient", sender: self)
        } else if (getMode() == "specialist" && validLogin()) { // going to specialist mode
            self.performSegue(withIdentifier: "LoggedInSpecialist", sender: self)
        } else { // else do nothing (don't redirect) -> create error message
            alertUserLoginError()
        }
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
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
        let password = defaults.string(forKey: "password")
        if (email == "" || password == "") {
            return false
        }
        
        spinner.show(in: view)

        // Validate Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email!, password: password!, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email!)")
                return
            }
            
            let user = result.user
            let safeEmail = DatabaseManager.safeEmail(email!)
            
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let name = userData["fullName"] as? String,
                        let code = userData["code"] as? String,
                        let mode = userData["mode"] as? String else {
                            return
                    }
                    // STORE MODE OF THE USER
                    UserDefaults.standard.set(mode, forKey: "mode")
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(code, forKey: "code")
                case .failure(let error):
                    print("Failed to read data with error: \(error)")
                    return
                }
            })
            
            print("Logged in User: \(user)")
        })
        
        return true
    }
    
    func alertUserLoginError(message: String = "Login unsuccessful") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
