//
//  DraftsTblCell.swift
//  ReplayMe
//
//  Created by Core Techies on 04/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class DraftsTblCell: UITableViewCell {

    @IBOutlet weak var saveGallaryBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var deletBtn: UIButton!
    @IBOutlet var thumbImg: UIImageView!
    @IBOutlet var draftNameLbl: UILabel!
    @IBOutlet var draftTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
