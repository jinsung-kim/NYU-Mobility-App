//
//  UserCell.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/9/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    func configure(_ name: String){
        //Setting Labels to update recording information
        nameLabel.text = "\(name)"
        
        //Fiting the text to the labels
        nameLabel.sizeToFit()
        
        //Styling the card
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
    }
}
