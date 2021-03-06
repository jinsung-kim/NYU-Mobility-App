//
//  VideoPlaybackController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/18/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import SwiftyJSON // Used to extract JSON information throughout the video playback

class VideoPlaybackController: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    // View for card
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    
    var session: NSManagedObject!
    var videoURL: URL!
    
    var sessionLength: String = ""
    var stepCount: Int = 0
    var distance: Int = 0
    
    var results: JSON? = nil
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Screen will not go to sleep with this line below
        UIApplication.shared.isIdleTimerDisabled = true
        
        shareVideoButton()
        
        // rounds the corners of the card
        cardView.layer.cornerRadius = 15
        
        results = getJSONArray()
        
        extractInformation()
        updateLabels()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        videoURL = generateURL()
        let playerItem = AVPlayerItem(url: videoURL!)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    // Upper right item from the tracking controller that goes to send the video off
    func shareVideoButton() {
        let instructionButton = UIBarButtonItem()
        instructionButton.title = "Share"
        instructionButton.action = #selector(sessionsTap)
        instructionButton.target = self
        navigationItem.rightBarButtonItem = instructionButton
    }
    
    @objc func sessionsTap() {
        performSegue(withIdentifier: "ShareVideo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is ShareVideoController) {
            let vc = segue.destination as? ShareVideoController
            vc?.session = session
        }
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
    
    func updateLabels() {
        // If the time difference function returns a non-empty string, there is a valid session
        if (sessionLength != "") {
            timeElapsedLabel.text = "Session Length: \(sessionLength)"
        // There is no valid session
        } else {
            timeElapsedLabel.text = "Session was too short"
        }
        stepCountLabel.text = "Step Count: \(stepCount) steps"
        distanceCoveredLabel.text = "Distance: \(distance) m"
    }
    
    // Gets the directory that the video is stored in
    func getPathDirectory() -> URL {
        // Searches a FileManager for paths and returns the first one
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    func generateURL() -> URL? {
        let path = getPathDirectory().appendingPathComponent(session.value(forKey: "videoURL") as! String)
        return path
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
        Looks at the results of the JSON conversion and extracts information for the labels
     */
    func extractInformation() {
        // Session was not long enough to be considered a session or
        // no significant data was collected
        if (results!.count < 3) {
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
