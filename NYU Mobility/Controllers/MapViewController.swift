//
//  MapViewController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/8/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

// https://www.hackingwithswift.com/example-code/media/how-to-convert-text-to-speech-using-avspeechsynthesizer-avspeechutterance-and-avspeechsynthesisvoice

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Controller View Objects
    @IBOutlet weak var mapView: MKMapView!
    // Distance + Step Labels
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    // Used to track pedometer when saving data
    var steps: Int32?
    
    // Used for creating the JSON that will be manipulated to grab the coordinates
    var coords: [CLLocationCoordinate2D] = []
    
    // All the map functions go here
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isScrollEnabled = false
        updateLabels()
        voiceResults()
    }
    
    // Updates the labels
    func updateLabels() {
        distanceLabel.text = "Distance Walked: \(String(totalDistanceCalculated().truncate(places: 2))) mi"
        stepsLabel.text = "Steps Taken: \(self.steps!) steps"
    }
    
    // Currently testing
    func voiceResults() {
        let result = "You walked \(totalDistanceCalculated().truncate(places :2)) miles and took \(self.steps!) steps"
        let utterance = AVSpeechUtterance(string: result)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    /**
       Calculates the distance traveled between each point given in miles
        - Returns: A double containing the distance traveled
    */
    func totalDistanceCalculated() -> Double {
        var total: Double = 0
        var result: Double
        let radians: Double = (180 / Double.pi)
        
        // Variables used to be converted
        var long1: Double
        var long2: Double
        var lat1: Double
        var lat2: Double
        
        // General Case: If there are more than two coordinate points
        if (coords.count >= 2) {
            for i in 0...(coords.count - 2) {
                // Convert to radians
                long1 = coords[i].longitude / radians
                long2 = coords[i + 1].longitude / radians
                lat1 = coords[i].latitude / radians
                lat2 = coords[i + 1].latitude / radians
                
                result = acos((sin(lat1) * sin(lat2)) + (cos(lat1) * cos(lat2) * cos(long2 - long1))) * 3963.0
                total += result
            }
        // Edge case: If the route is very short and only has two coordinate points
        // Should only happen for accidental double clicks
        } else {
            total = 0
        }
        return total
    }
    
    // Currently: Atlas page destroyed with outstanding references
    // Apple bug maybe?
    deinit {
        mapView.annotations.forEach{ mapView.removeAnnotation($0) }
        mapView.delegate = nil
    }
}

extension Double{
    // Truncates double to how ever many places is needed
    // Used to manage the text to speech feature
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
