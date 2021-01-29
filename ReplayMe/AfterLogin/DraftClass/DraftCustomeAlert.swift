    //
//  DraftCustomeAlert.swift
//  ReplayMe
//
//  Created by Core Techies on 18/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class DraftCustomeAlert: UIViewController {
 var delegate: CustomAlertViewDelegate?
    
    @IBOutlet weak var toStoryBtn: UIButton!
    @IBOutlet weak var toFeedBtn: UIButton!
    @IBOutlet weak var toStoryFeedBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func toStoryBtnClicked(_ sender: UIButton) {
        delegate?.okButtonTapped(textFieldValue: "Story")
               self.dismiss(animated: true, completion: nil)
    }
    @IBAction func toFeedBtnClicked(_ sender: Any) {
        delegate?.okButtonTapped( textFieldValue: "Feed")
                   self.dismiss(animated: true, completion: nil)
    }
    @IBAction func toFeedStoryBtnClicked(_ sender: Any) {
        delegate?.okButtonTapped( textFieldValue: "FeedStory")
                         self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
           
    }
    

}
