//
//  PlayerView.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 9/22/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//
import UIKit
import AVKit
import AVFoundation

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
