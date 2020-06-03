//
//  Point.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/1/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation

struct Point: Codable {
    var time: String
    var steps: Int32
    var lat: Double
    var long: Double
    var gyroData: [String: [Double]] // All x values held in the same place, y values, z values
    
    init(_ time: String, _ steps: Int32, _ lat: Double, _ long: Double, _ gyroData: [String: [Double]]) {
        self.time = time
        self.steps = steps
        self.lat = lat
        self.long = long
        self.gyroData = gyroData
    }
    
    func convertToDictionary() -> [String : Any] {
        let dic: [String: Any] = ["time": self.time, "steps": self.steps, "lat": self.lat,
                                  "long": self.long, "gyroData": self.gyroData]
        return dic
    }
}
