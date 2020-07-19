//
//  VideoPlaybackController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/18/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlaybackController: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var videoURL: URL!
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avPlayerLayer = AVPlayerLayer(player: avPlayer)
        self.avPlayerLayer.frame = self.view.bounds
        self.avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        self.view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: self.videoURL as URL)
        self.avPlayer.replaceCurrentItem(with: playerItem)
        
        self.avPlayer.play()
    }
}
