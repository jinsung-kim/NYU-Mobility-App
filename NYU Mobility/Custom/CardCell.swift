//
//  CardCell.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/1/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {
    //UILabels to connect to storyboard
    @IBOutlet weak var cardView: UIView!
    
    func configure(date: Date){
        //Setting Labels to update recording information
        recordingNumLabel.text = "#\(recordNum)"
        
        //Fiting the text to the labels
        recordingNumLabel.sizeToFit()
        minLabel.sizeToFit()
        avgLabel.sizeToFit()
        maxLabel.sizeToFit()
        
        //Styling the card
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
    }
}
