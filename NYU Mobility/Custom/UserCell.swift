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
    @IBOutlet weak var lastSession: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    func configure(_ name: String, _ last: Date) {
        // Setting Labels to update recording information
        nameLabel.text = "\(name)"
        lastSession.text = "Last Active: \(dateFormatter(last))"
        
        // Fitting the text to the labels
        nameLabel.sizeToFit()
        
        // Styling the card
        cardView.backgroundColor = Colors.white
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = self.frame.size.height / 4
    }
    
    // Transforming the date into a string
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
