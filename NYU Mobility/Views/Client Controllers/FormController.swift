//
//  FormController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/13/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class FormController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addButton: CustomButton!
    
    @IBOutlet weak var name: CustomTextField!
    @IBOutlet weak var street: CustomTextField!
    @IBOutlet weak var city: CustomTextField!
    @IBOutlet weak var state: CustomTextField!
    @IBOutlet weak var zip: CustomTextField!
    
    var last: UITextField?
    
    // Local Storage
    var userLocations: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        update()
        exitEdit()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Cleaning up to avoid any unnecessary notification messages
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    func update() {
        addButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        name.widthAnchor.constraint(equalToConstant: 150).isActive = true
        street.widthAnchor.constraint(equalToConstant: 300).isActive = true
        city.widthAnchor.constraint(equalToConstant: 150).isActive = true
        state.widthAnchor.constraint(equalToConstant: 100).isActive = true
        zip.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [name, street, city, state, zip])
        
        // Keyboard settings
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func keyboardStays(_ sender: CustomTextField) {
        last = sender
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if (last != name && last != street) {
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
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func submitLocation(_ sender: Any) {
        var address: String = ""
        // Ex: 123 Apple Street Cupertino, CA 95015
        address = "\(street.text!) \(city.text!), \(state.text!) \(zip.text!)"
        savePoint(name: name.text!, address: address)
        
    }
    
    // Load Points
    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserSaved")
        
        do {
            userLocations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Saves Point
    func savePoint(name: String, address: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "UserSaved",
                                                in: managedContext)!
        
        let point = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        point.setValue(name, forKeyPath: "name")
        point.setValue(address, forKeyPath: "address")
        
        // Address -> Coordinates
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // No location found
                return
            }
            point.setValue(location.coordinate.latitude, forKeyPath: "lat")
            point.setValue(location.coordinate.longitude, forKeyPath: "long")
        }
        
        do {
            try managedContext.save()
            // Only save if there are less than 5 previously saved points
            if (userLocations.count <= 5) {
                userLocations.append(point)
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

// Used to go from one UITextField to the next
extension UITextField {
    class func connectFields(fields: [UITextField]) -> Void {
        guard let last = fields.last else {
            return
        }
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .next
            fields[i].addTarget(fields[i + 1], action: #selector(self.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        last.returnKeyType = .done
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
    }
}
