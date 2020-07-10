//
//  PickUserController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/9/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreData

class PickUserController: UITableViewController {
    
    var users: [NSManagedObject] = []
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        addButton()
        self.navigationItem.setHidesBackButton(true, animated: false)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Used to send over data to the Specialist Tracking Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SpecialistTrackingController
        {
            let vc = segue.destination as? SpecialistTrackingController
            vc?.name = self.name!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.name = (users[indexPath.row].value(forKey: "name") as! String)
        self.performSegue(withIdentifier: "ToSpecialistTracking", sender: self)
    }
    
    @objc func addButtonTap() {
        showInputDialog(title: "Add a patient",
                        subtitle: "Please enter their full name",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Ex: John Appleseed",
                        inputKeyboardType: .emailAddress)
        { (input: String?) in
            self.savePoint(input!)
        }
    }
    
    func addButton() {
        let addButton = UIBarButtonItem()
        addButton.title = "Add Patient"
        addButton.action = #selector(addButtonTap)
        addButton.target = self
        self.navigationItem.rightBarButtonItem = addButton
    }

    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        do {
            users = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Saves user
    func savePoint(_ name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "User",
                                                in: managedContext)!
        
        let user = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        user.setValue(name, forKeyPath: "name")
        
        do {
            try managedContext.save()
                users.append(user)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // Table view functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        // Getting the contents of the selected row
        // See UserCell.swift in Custom group
        cell.configure(users[indexPath.row].value(forKey: "name") as! String)
        
        return cell
    }
    
    // Right swipe 'Delete'
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let commit = users[indexPath.row]
            users.remove(at: indexPath.row)
            context.delete(commit)
            
            do {
                try context.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error Deleting")
            }
            tableView.reloadData()
        }
    }
    
}
