//
//  usersCollectionViewCell.swift
//  ReplayMe
//
//  Created by Core Techies on 28/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class usersCollectionViewCell: UICollectionViewCell {
     @IBOutlet weak var imgView: UIImageView!
        @IBOutlet weak var lblUserName: UILabel!
       // let redColor = UIColor(hex: "FF1494")
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            self.lblUserName.textAlignment = .center
            self.imgView.layer.cornerRadius = self.imgView.frame.size.height / 2;
            //self.imgView.layer.borderColor = redColor.cgColor
            self.imgView.layer.borderWidth = 3
            self.imgView.clipsToBounds = true
            
        }
    }
