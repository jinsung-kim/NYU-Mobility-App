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
    @IBOutlet weak var videoAvailableLabel: UILabel!
    
    func configure(date: Date, video: String) {
        // Setting Labels to update recording information
        timeLabel.text = "Session Started: \(dateFormatter(date))"
        
        if (video == "") {
            videoAvailableLabel.text = ""
        } else {
            videoAvailableLabel.text = "📷" // indicates that there is a video to be played
        }
        
        videoAvailableLabel.textColor = UIColor.black
        timeLabel.textColor = Colors.black
        
        // Fitting the text to the labels
        timeLabel.sizeToFit()

        
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
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // space out sessions in content view
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
