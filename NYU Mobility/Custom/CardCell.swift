//
//  CardCell.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/1/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {
    
    // Holder
    @IBOutlet weak var cardView: UIView!
    
    // Start time label
    @IBOutlet weak var timeLabel: UILabel!
    
    func configure(date: Date) {
        // Setting Labels to update recording information
        timeLabel.text = "\(dateFormatter(date))"
        
        // Fitting the text to the labels
        timeLabel.sizeToFit()
        
        // Styling the card
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
    }
    
    // Transforming the date into a string
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
