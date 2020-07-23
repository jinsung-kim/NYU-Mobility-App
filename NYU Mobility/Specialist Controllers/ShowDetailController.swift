//
//  ShowDetailController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/21/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreData

class ShowDetailController: UIViewController {
    
    
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var session: NSManagedObject!
    var validJSON: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(session.value(forKey: "json") as! String)
        var _ = self.processString()
        self.updateLabels()
    }
    
    func updateLabels() {
        
    }
    
    /**
        Processes the given session JSON, and returns in dictionary form
        - Returns: [String: Any], so that that the data can be processed
     */
    func processString() -> [String : Any] {
        var jsonArray = [String: Any]()
        let data = (session.value(forKey: "json") as! String).data(using: .utf8)!
        do {
            if let converted = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] {
                validJSON = true
                jsonArray = converted
            } else {
                validJSON = false
                print("JSON not valid")
            }
        } catch let error as NSError {
            print(error)
        }
        return jsonArray
    }
}
