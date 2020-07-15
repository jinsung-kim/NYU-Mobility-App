//
//  VideoPlaybackViewController.swift
//  NYU Mobility
//
//  Created by Jin Kim on 7/15/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlaybackViewController: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var videoURL: URL!
    @IBOutlet weak var videoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
    
        view.layoutIfNeeded()
    
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
    
        avPlayer.play()
    }
}
