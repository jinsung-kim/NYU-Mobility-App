//
//  Gyro.swift
//  NYU Mobility
//
//  Created by Jin Kim on 5/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation

public class Gyro: NSObject {
    
    let x: Double
    let y: Double
    let z: Double
    
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}
