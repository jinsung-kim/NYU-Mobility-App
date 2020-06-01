//
//  Point.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/1/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation

struct Point: Codable {
    var time: Date
    var steps: Int32
    var lat: Double
    var long: Double
    var gyroData: [Gyro]?
    
    init(_ time: Date, _ steps: Int32, _ lat: Double, _ long: Double, _ gyroData: [Gyro]) {
        self.time = time
        self.steps = steps
        self.lat = lat
        self.long = long
        self.gyroData = gyroData
    }
}
