//
//  RegistrationController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 6/30/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
//import CoreData

class RegistrationController: UIViewController {
    
    // Client button
    @IBOutlet weak var clientButton: CustomAdd!
    
    // Specialist button
    @IBOutlet weak var specialistButton: CustomAdd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonConstraints()
    }
    
    func buttonConstraints() {
        // Client button styling
        clientButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        clientButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
        // Specialist button styling
        specialistButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        specialistButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }

}


