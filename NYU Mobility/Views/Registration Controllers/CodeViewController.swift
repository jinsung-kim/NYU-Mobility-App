//
//  CodeViewController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/8/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController {
    
    // Code label
    @IBOutlet weak var codeLabel: UILabel!
    // Next button
    @IBOutlet weak var nextButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        buttonConstraints()
        codeLabel.text = getCode()
    }
    
    func buttonConstraints() {
        // next button
        nextButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func getCode() -> String {
        let defaults = UserDefaults.standard
        let code = defaults.string(forKey: "code")
        return code!
    }

}


