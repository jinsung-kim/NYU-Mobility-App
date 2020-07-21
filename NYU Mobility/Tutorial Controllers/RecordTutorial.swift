//
//  RecordTutorial.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/18/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class RecordTutorial: UIViewController {
    
    @IBOutlet weak var nextButton: CustomAdd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonConstraint()
        
    }
    
    func buttonConstraint() {
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
}
