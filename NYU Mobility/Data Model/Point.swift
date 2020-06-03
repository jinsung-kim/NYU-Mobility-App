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
    var coordinates: [String: [Double]]
    var gyroData: [String: [Double]] // All x values held in the same place, y values, z values
    
    init(_ time: String, _ steps: Int32, _ coordinates: [String: [Double]], _ gyroData: [String: [Double]]) {
        self.time = time
        self.steps = steps
        self.coordinates = coordinates
        self.gyroData = gyroData
    }
    
    func convertToDictionary() -> [String : Any] {
        let dic: [String: Any] = ["time": self.time, "steps": self.steps, "coordinates": self.coordinates, "gyroData": self.gyroData]
        return dic
    }
}
