//
//  RecordColors.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/18/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class RecordColors: UIViewController {
    
    @IBOutlet weak var startButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonConstraint()
    }
    
    func buttonConstraint() {
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
}

