//
//  NewsFeedLandscapeCell.swift
//  ReplayMe
//
//  Created by Krishna on 19/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import AVFoundation
import UIKit

@available(iOS 13.0, *)
class NewsFeedLandscapeCell: UITableViewCell {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet var feedUserIMg: UIImageView!
    @IBOutlet var feedUserNameLbl: UILabel!
    @IBOutlet var feedDetailLbl: UILabel!
    @IBOutlet var totalLikeLbl: UILabel!
    @IBOutlet var totalCommentLbl: UILabel!

    @IBOutlet var buttonLike: UIButton!
    @IBOutlet var buttonComment: UIButton!
    @IBOutlet var buttonShare: UIButton!
    @IBOutlet var storyBtn: UIButton!
    @IBOutlet var storyLbl: UILabel!

    @IBOutlet var playerThumbnailImg: UIImageView!
    
    var indexPath: IndexPath?
    
    weak var parentVC: HomeViewController?
    
    
    func configureCell(videoURL: String) {
        if let url = URL(string: videoURL) {
            if self.playerView.playerLayer.player == nil {
                let avPlayer = AVPlayer(url: url)
                self.playerView.playerLayer.player = avPlayer
                self.playerView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.playerView.playerLayer.player?.play()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.playerView.playerLayer.frame = self.playerThumbnailImg.frame
            self.playerView.frame = self.playerThumbnailImg.frame
            self.playerView.playerLayer.player?.playImmediately(atRate: 1.0)
            self.playerView.playerLayer.player?.isMuted = false
        }
    }
}
