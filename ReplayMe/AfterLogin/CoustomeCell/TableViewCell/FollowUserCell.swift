//
//  FollowUserCell.swift
//  ReplayMe
//
//  Created by Krishna on 12/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class FollowUserCell: UITableViewCell {
    @IBOutlet var followingProfileImg: UIImageView!
    @IBOutlet var followerProfileImg: UIImageView!
    @IBOutlet var followerBtn: UIButton!
    
    @IBOutlet var followingBtn: UIButton!
    @IBOutlet var followingUserName: UILabel!
    @IBOutlet var followerUserNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
