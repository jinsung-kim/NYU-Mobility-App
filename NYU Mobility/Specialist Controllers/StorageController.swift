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
    var filter: [NSManagedObject] = []
    var map: [Int] = [] // Maps out the index that the filtered
    
    @IBOutlet var customTableView: UITableView!
    
    var name: String?
    
    var tappedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        self.tableView.backgroundColor = Colors.nyuPurple // Sets the background color to purple
        customTableView.delegate = self
        customTableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    // Go to video player
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is VideoPlaybackController) {
            let vc = segue.destination as? VideoPlaybackController
            vc?.videoURL = URL(string: sessions[map[tappedIndex]].value(forKey: "videoURL") as! String)
        }
    }
    
    // Load all of the sessions
    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Session")
        // Order reversed
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do {
            sessions = try managedContext.fetch(fetchRequest)
            for elem in 0 ..< sessions.count {
                if (self.filterName(elem)) {
                    filter.append(sessions[elem])
                    map.append(elem)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func filterName(_ ind: Int) -> Bool {
        // Compare names of sessions
        if ((sessions[ind].value(forKey: "user") as! String) == self.name!) {
            return true
        }
        return false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filter.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageCell", for: indexPath) as! CardCell
        
        cell.clipsToBounds = true
        
        // Getting the contents of the selected row
        // See CardCell.swift in Custom group
        cell.configure(date: filter[indexPath.row].value(forKey: "startTime") as! Date)
        
        return cell
    }
    
    // Used to redirect to display view controller with specifics
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tappedIndex = indexPath.row
        if (sessions[map[tappedIndex]].value(forKey: "videoURL") as! String == "") { // No video to accompany the session
//            print("No video session")
            self.performSegue(withIdentifier: "showDetails", sender: self)
        } else {
//            print("Video session available")
            self.performSegue(withIdentifier: "replayVideo", sender: self)
        }
    }
    
    // Right swipe 'Delete'
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            // Find the appropriate filtered index and remove it in the original
            let context = appDelegate.persistentContainer.viewContext
            let commit = sessions[map[indexPath.row]] // index out of range
            sessions.remove(at: map[indexPath.row])
            context.delete(commit)
            // delete within filtered list as well
            filter.remove(at: indexPath.row)
            do {
                try context.save()
                customTableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error Deleting")
            }
            customTableView.reloadData()
        }
    }
}
