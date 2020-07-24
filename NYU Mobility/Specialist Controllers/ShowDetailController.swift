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
    
    @IBOutlet weak var sessionLengthLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var sessionLength: String = ""
    var stepCount: Int = 0
    var distance: Int = 0
    
    var results: JSON? = nil
    
    var session: NSManagedObject!
    
    // Extracted information
    
    override func viewDidLoad() {
        super.viewDidLoad()
        results = self.getJSONArray() // processes into the json var
        extractInformation()
        updateLabels()
    }
    
    /**
        After information has been extracted from the JSON array, the data is then displayed onto the screen
     */
    func updateLabels() {
        
        // invalid session
        if (sessionLength == "") {
            sessionLengthLabel.text = "The session was too\nshort to track analytics"
            stepCountLabel.text = ""
            distanceLabel.text = ""
        } else {
            sessionLengthLabel.text = "Length of Session: \(sessionLength)"
            stepCountLabel.text = "Step Count: \(stepCount) steps"
            distanceLabel.text = "Distance Covered: \(distance) m"
        }
    }
    
    /**
        Gets the time interval between two dates
        - Returns: String containing the number of minutes and seconds that has passed between the session start and end
     */
    func getTimeDifference(_ startTime: Date, _ endTime: Date) -> String {
        let difference = Calendar.current.dateComponents([.minute, .second], from: startTime, to: endTime)
        let formattedString = String(format: "%d minutes and %d seconds", difference.minute!, difference.second!)
        return formattedString
    }
    
    /**
        Takes the existing session json string, and converts it into a readable JSON array to extract information
        - Returns: JSON? of the string (See SwiftyJSON documentation for more)
     */
    func getJSONArray() -> JSON? {
        let data = (session.value(forKey: "json") as! String).data(using: .utf8)!
        do {
            let json = try JSON(data: data)
            return json
        } catch {
            print("There was an error processing the string")
        }
        return nil
    }
    
    /**
        Looks at the results of the JSON conversion and extracts information for the labels
     */
    func extractInformation() {
        // Session was not long enough to be considered a session or
        // no significant data was collected
        if (results!.count < 2) {
            return
        }
        // Precondition: There is sufficient data to be collected + sorted + evaluated
        
        // Gets the start and end time to get time difference
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let startTime = formatter.date(from: results![0]["time"].string!)
        let endTime = formatter.date(from: results![results!.count - 1]["time"].string!)
        
        sessionLength = getTimeDifference(startTime!, endTime!)
        distance = results![results!.count - 1]["distance"].int!
        stepCount = results![results!.count - 1]["steps"].int!
    }
}
