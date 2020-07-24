//
//  CustomTextField.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/7/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    // Called
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupField()
    }
    
    func setupField() {
        backgroundColor = Colors.white
        textColor = Colors.black
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                            attributes: [NSAttributedString.Key.foregroundColor: Colors.gray])
        }
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
