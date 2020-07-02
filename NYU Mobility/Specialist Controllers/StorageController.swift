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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardCell
        
        //Getting the contents of the selected row
        let selectedRow = sessions[indexPath.row]
        
        // Assigning decibel readings to variables
        let avgDecibel = selectedRow.value(forKey: "avgDecibel") as! Int
        let minDecibel = selectedRow.value(forKey: "minDecibel") as! Int
        let maxDecibel = selectedRow.value(forKey: "maxDecibel") as! Int
        
        //Assigning text label of cell to decibel readings
        //cell.textLabel?.text = String("Avg: \(avgDecibel)dB| Min: \(minDecibel)dB| Max: \(maxDecibel)dB")
        cell.configure(recordNum: indexPath.row + 1, minDecibel: minDecibel, avgDecibel: avgDecibel, maxDecibel: maxDecibel)
        
        return cell
    }
    
    //Remove a recording by swiping right
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
