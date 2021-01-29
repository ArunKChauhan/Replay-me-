//
//  HomeNewFeedCell.swift
//  ReplayMe
//
//  Created by Core Techies on 28/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import AVFoundation
import UIKit

class HomeNewFeedCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var shotImageView: UIImageView!
    @IBOutlet var postUserImg: UIImageView!
    @IBOutlet var postUserName: UILabel!
    @IBOutlet var totalReactCountLbl: UILabel!
    @IBOutlet var lastCommentUserNameLbl: UILabel!
    @IBOutlet var lastCommentLbl: UILabel!

    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var commentBtn: UIButton!
    @IBOutlet var playerThumb: UIImageView!

    @IBOutlet var playerView: PlayerView!

    @IBOutlet var userDetailBtn: UIButton!

    var indexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }
    
    func configureCell(videoURL: String) {
        if let url = URL(string: videoURL) {
            if self.playerView.playerLayer.player == nil {
                let avPlayer = AVPlayer(url: url)
                self.playerView.playerLayer.player = avPlayer
                self.playerView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.playerView.playerLayer.frame = self.playerThumb.frame
            self.playerView.frame = self.playerThumb.frame
            self.playerView.playerLayer.player?.playImmediately(atRate: 1.0)
            self.playerView.playerLayer.player?.isMuted = false
        }
    }
}
