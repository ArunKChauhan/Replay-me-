//
//  VideoPlayerItem.swift
//  InstagramVideoCell
//
//  Created by Daffodil on 08/03/20.
//  Copyright © 2020 Saurabh Yadav. All rights reserved.
//

enum PlayerState {
    case play
    case pause
}

import Foundation
class VideoPlayerItem{
    var url: URL!
    var playerState: PlayerState = .pause
}
