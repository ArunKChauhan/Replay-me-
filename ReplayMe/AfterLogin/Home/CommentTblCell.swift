//
//  CommentTblCell.swift
//  ReplayMe
//
//  Created by Core Techies on 02/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class CommentTblCell: UITableViewCell {
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var commentTimeLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
