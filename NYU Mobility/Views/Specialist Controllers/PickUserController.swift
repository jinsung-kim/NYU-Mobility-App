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
    var sessions: [NSManagedObject] = []
    var name: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        addButton()
        
        printSessions()
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.nyuPurple // Sets the background color to purple
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    // Used to send over data to the Specialist Tracking Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SpecialistTrackingController {
            let vc = segue.destination as? SpecialistTrackingController
            vc?.name = name!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        name = (users[indexPath.row].value(forKey: "name") as! String)
        index = indexPath.row
        updateTime()
        performSegue(withIdentifier: "ToSpecialistTracking", sender: self)
    }
    
    @objc func addButtonTap() {
        showInputDialog(title: "Add a patient",
                        subtitle: "Please enter their full name",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Ex: John Appleseed",
                        inputKeyboardType: .emailAddress)
        { (input: String?) in
            self.saveUser(input!, Date())
        }
        tableView.reloadData()
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
        
        let fetchRequestUsers = NSFetchRequest<NSManagedObject>(entityName: "User")
        let fetchRequestSessions = NSFetchRequest<NSManagedObject>(entityName: "Session")
        
        do {
            users = try managedContext.fetch(fetchRequestUsers)
            sessions = try managedContext.fetch(fetchRequestSessions)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Saves user
    func saveUser(_ name: String, _ date: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        
        let user = NSManagedObject(entity: entity, insertInto: managedContext)
        
        user.setValue(name, forKeyPath: "name")
        user.setValue(date, forKeyPath: "lastActive")
        
        do {
            try managedContext.save()
            users.append(user)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
    // update time for a user session
    func updateTime() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            users[index!].setValue(Date(), forKey: "lastActive")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
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
        
        cell.clipsToBounds = true
        
        // Getting the contents of the selected row
        // See UserCell.swift in Custom group
        cell.configure(users[indexPath.row].value(forKey: "name") as! String,
                       users[indexPath.row].value(forKey: "lastActive") as! Date)
        
        return cell
    }
    
    // Right swipe 'Delete'
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let commit = users[indexPath.row]
            
            let toDelete = users[indexPath.row].value(forKey: "name") as! String
            deleteAllSessions(toDelete)

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
    
    // Gets the directory that the video is stored in
    func getPathDirectory() -> URL {
        // Searches a FileManager for paths and returns the first one
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    func generateURL(_ ind: size_t) -> URL? {
        let path = getPathDirectory().appendingPathComponent(sessions[ind].value(forKey: "videoURL") as! String)
        return path
    }
    
    /**
        Removes the sessions under a client's name
        - Parameters:
            - name: The name of the client
     */
    func deleteAllSessions(_ name: String) {
        var user: String = ""
        for ind in (0 ..< sessions.count).reversed() {
            user = sessions[ind].value(forKey: "user") as! String
            if (name == user) {
                // Only delete if there is a valid URL there
                // Otherwise, the entire directory will be deleted
                if (sessions[ind].value(forKey: "videoURL") as! String != "") {
                    try? FileManager.default.removeItem(at: generateURL(ind)!)
                }
                deleteSession(ind)
            }
        }
    }
    /**
        Deletes a session given the index
        - Parameters:
            - ind: The index (unsigned integer, to ensure that a non-valid index won't be provided)
     */
    func deleteSession(_ ind: size_t) {
        print(ind)
        print("user: \(sessions[ind].value(forKey: "user") as! String)")
        print("videoURL: \(sessions[ind].value(forKey: "videoURL") as! String)")
        print("startTime: \(sessions[ind].value(forKey: "startTime") as! Date)")
        print()
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            context.delete(sessions[ind])
            try context.save()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Used for testing purposes
    func printSessions() {
        for session in sessions {
            print("user: \(session.value(forKey: "user") as! String)")
            print("videoURL: \(session.value(forKey: "videoURL") as! String)")
            print("startTime: \(session.value(forKey: "startTime") as! Date)")
            print()
        }
    }
    
}
