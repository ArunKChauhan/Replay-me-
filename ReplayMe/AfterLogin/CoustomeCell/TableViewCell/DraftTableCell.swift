//
//  DraftTableCell.swift
//  ReplayMe
//
//  Created by Krishna on 10/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class DraftTableCell: UITableViewCell {
    
    @IBOutlet weak var saveGallaryBtn: UIButton!
    @IBOutlet var filterBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
      @IBOutlet weak var sendBtn: UIButton!
      @IBOutlet weak var deletBtn: UIButton!
      @IBOutlet var thumbImg: UIImageView!
      @IBOutlet var draftNameLbl: UILabel!
      @IBOutlet var draftTimeLbl: UILabel!

    @IBOutlet var nextBtn: UIButton!
    
    @IBOutlet weak var saveGallaryBtnl: UIButton!
      @IBOutlet var filterBtnl: UIButton!
      @IBOutlet weak var shareBtnl: UIButton!
        @IBOutlet weak var sendBtnl: UIButton!
        @IBOutlet weak var deletBtnl: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
