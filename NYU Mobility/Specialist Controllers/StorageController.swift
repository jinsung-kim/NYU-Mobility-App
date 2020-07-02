//
//  StorageController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/1/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreData

class StorageController: UITableViewController {
    
    var sessions: [NSManagedObject] = []
    @IBOutlet var customTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        customTableView.delegate = self
        customTableView.dataSource = self
    }
    
    // Load all of the sessions
    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Session")
        
        do {
            sessions = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageCell", for: indexPath) as! CardCell
        
        // Getting the contents of the selected row
        // See CardCell.swift in Custom group
        cell.configure(date: sessions[indexPath.row].value(forKey: "startTime") as! Date)
        
        return cell
    }
    
    // Right swipe 'Delete'
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let commit = sessions[indexPath.row]
            sessions.remove(at: indexPath.row)
            context.delete(commit)
            
            do{
                try context.save()
                customTableView.deleteRows(at: [indexPath], with: .fade)
            }catch{
                print("Error Deleting")
            }

            customTableView.reloadData()
        }
    }
    
}
