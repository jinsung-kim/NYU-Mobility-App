//
//  Gyro.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/1/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation

struct Gyro: Codable {
    var x: Double
    var y: Double
    var z: Double
    
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}
