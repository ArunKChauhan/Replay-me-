//
//  PeopleActivitiesCell.swift
//  ReplayMe
//
//  Created by Krishna on 03/06/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class PeopleActivitiesCell: UITableViewCell {
    @IBOutlet var userImg: UIImageView!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var mesgLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
