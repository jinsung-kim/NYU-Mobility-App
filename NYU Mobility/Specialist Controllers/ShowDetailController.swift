//
//  ShowDetailController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/21/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON // Used to convert string to JSON array

class ShowDetailController: UIViewController {
    
    
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var session: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(session.value(forKey: "json") as! String)
        self.updateLabels()
        self.getJSONArray()
    }
    
    func updateLabels() {
        
    }
    
    func getJSONArray() {
        let data = (session.value(forKey: "json") as! String).data(using: .utf8)!
        do {
            let json = try JSON(data: data)
            print(json)
        } catch {
            print("There was an error processing the string")
        }
    }
}
