//
//  PlayerView.swift
//  DemoSwiftyCam
//
//  Created by Mahendra Singh on 25/03/20.
//  Copyright © 2020 Cappsule. All rights reserved.
//

import UIKit
import AVKit;
import AVFoundation;

class PlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self;
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer;
    }
    
    var player: AVPlayer? {
        get {
            
            return playerLayer.player;
        }
        set {
            playerLayer.player = newValue;
        }
    }
}
