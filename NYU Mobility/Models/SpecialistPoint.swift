//
//  SpecialistPoint.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/1/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//
import Foundation

public struct SpecialistPoint: Codable {
    var time: String
    var steps: Int32
    var distance: Int32
    var gyroData: [String: [Double]] // All x values held in the same place, y values, z values
    var avgPace: Double
    var currPace: Double
    var currCad: Double
    
    // Used to add each point within the JSON
    init(_ time: String, _ steps: Int32, _ distance: Int32, _ avgPace: Double, _ currPace: Double,
         _ currCad: Double, _ gyroData: [String: [Double]]) {
        self.time = time
        self.steps = steps
        self.gyroData = gyroData
        self.currCad = currCad
        self.avgPace = avgPace
        self.currPace = currPace
        self.distance = distance
    }
    
    func convertToDictionary() -> [String : Any] {
        let dic: [String: Any] = ["time": self.time, "steps": self.steps, "distance": self.distance,
                                  "gyroData": self.gyroData, "avgPace": self.avgPace,
                                  "currPace": self.currPace, "currCad": self.currCad]
        return dic
    }
}
