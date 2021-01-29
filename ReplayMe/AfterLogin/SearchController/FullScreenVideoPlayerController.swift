//
//  FullScreenVideoPlayerController.swift
//  ReplayMe
//
//  Created by Krishna on 06/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

@available(iOS 13.0, *)
class FullScreenVideoPlayerController: UIViewController,NVActivityIndicatorViewable {
    @IBOutlet var playeBackView: UIView!
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    @IBOutlet var profileImg: UIImageView!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var contentLbl: UILabel!
    @IBOutlet var likeCountLbl: UILabel!
    @IBOutlet var commentCountLbl: UILabel!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var playerThumbImg: UIImageView!
    var playerDetailDict = Dictionary<String, AnyObject>()
    var totalLike: Int = 0
    var checkVideoCount: Bool = true
        
   // var videostr
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerThumbImg.sd_setImage(with: URL(string: playerDetailDict["videoScreenShotUrl"] as? String ?? ""), placeholderImage: UIImage(named: "layer35"))
        contentLbl.text = playerDetailDict["content"] as? String ?? ""
        let videoURL = URL(string: playerDetailDict["videoUrl"] as? String ?? "")
        self.player = AVPlayer(url: videoURL!)
        self.playerViewController = AVPlayerViewController()
        playerViewController.showsPlaybackControls = false
        playerViewController.player = self.player
        playerViewController.view.frame = self.playeBackView.frame
        playerViewController.player?.play()
        self.playeBackView.addSubview(playerViewController.view)
     
        NotificationCenter.default.addObserver(self,
                      selector: #selector(playerItemDidReadyToPlay(notification:)),
                      name: .AVPlayerItemNewAccessLogEntry,
                      object: player?.currentItem)

//newsFeedDetailApi()
    }
    @objc func playerItemDidReadyToPlay(notification: Notification) {
            if let _ = notification.object as? AVPlayerItem {
                // player is ready to play now!!
                print("krishna Dev")
                if checkVideoCount == true{
                    checkVideoCount = false
                videoCountApi()
                }
            }
    }
    // MARK: - Service Method
    func videoCountApi() {
        
       // self.startAnimating()
        let para = ["newsFeedsId": playerDetailDict["id"] as? String ?? ""]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kVideoUpdateCount, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
                if (dict["data"]) != nil
                {
    
                }
            }
            else
            {
                
               // self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        newsFeedDetailApi()
    }
    func newsFeedDetailApi() {
        
        self.startAnimating()
        let para = ["newsFeedId": playerDetailDict["id"] as? String ?? ""]
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kSingleNewsFeed, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                if (dict["data"]) != nil
                {
                    
                let dataDic = dict["data"] as? Dictionary<String, AnyObject>
                let userDetail  = ((dataDic as AnyObject).object(forKey: "userdetails") as! NSDictionary?)
            self.userNameLbl.text = String(format: "%@ %@",((userDetail as AnyObject).object(forKey: "firstName") as! String?)!,((userDetail as AnyObject).object(forKey: "lastName") as! String?)!)
            self.profileImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                    
                    self.totalLike = (dataDic!["totallikes"] as? Int)!
                    let totalCommentInt = dataDic!["totalComments"] as? Int
                    self.likeCountLbl.text  = "\(self.totalLike)"
                     self.commentCountLbl.text  = "\(totalCommentInt!)"
                    if dataDic!["likes"] as? Int == 1{
                        self.likeBtn.setImage(UIImage(named: "heartLike.png"), for: .normal)
                    }else{
                        self.likeBtn.setImage(UIImage(named: "save-circle.png"), for: .normal)
                    }
              
                }
            }
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
        
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        playerViewController.player?.pause(); self.navigationController?.popViewController(animated: false)
    }
    @IBAction func likeBtnClicked(_ sender: Any){
        
        self.startAnimating()
        let para = ["newsFeedsId": playerDetailDict["id"] as? String ?? ""]
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kLikeNewsFeed, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
            let message = dict["message"] as? String
                if (message == "News feed liked successfully")
                {
                    self.totalLike = self.totalLike + 1
                   self.likeCountLbl.text  = "\(self.totalLike)"
            self.likeBtn.setImage(UIImage(named: "heartLike.png"), for: .normal)
                    }
                else{
                    self.totalLike = self.totalLike - 1
                self.likeCountLbl.text  = "\(self.totalLike)"
            self.likeBtn.setImage(UIImage(named: "save-circle.png"), for: .normal)
                }
            }
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                // self.serachListArray = []
                //self.tableView.reloadData()
            }
        }
        
        
    }
    @IBAction func commentbtnClicked(_ sender: Any) {
        DispatchQueue.main.async {
               
                 let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            secondViewController.newsFeedsIdStr = self.playerDetailDict["id"] as? String ?? ""; self.navigationController?.pushViewController(secondViewController, animated: true)
             }
    }
    @IBAction func shareBtnClicked(_ sender: Any) {
        guard let url = URL(string: "Google.com") else { return }
        UIApplication.shared.open(url)
    }
    @IBAction func deletBtnClicked(_ sender: Any) {
        
         // Create the alert controller
         let alertController = UIAlertController(title: "Alert", message: "Are you sure want to delete the post.", preferredStyle: .alert)
         
         // Create the actions
         let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
             UIAlertAction in
            

            self.startAnimating()
            let para = ["newsFeedsId": self.playerDetailDict["id"] as? String ?? ""]
            ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kDeleteNewsFeed, parameters: para) { (dict) in
                print(dict)
                self.stopAnimating()
                let status = dict["status"] as? String
                if(status == "true"){
           self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                    self.navigationController?.popViewController(animated: true)
                }
                else
                {
                    self.stopAnimating()
                    self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                }
            }

         }
         let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
             UIAlertAction in
             NSLog("Cancel Pressed")
         }
         
         // Add the actions
         alertController.addAction(okAction)
         alertController.addAction(cancelAction)
         
         // Present the controller
         self.present(alertController, animated: true, completion: nil)
    
     }
    
   

}
