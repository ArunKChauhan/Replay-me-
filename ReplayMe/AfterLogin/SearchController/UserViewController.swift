//
//  UserViewController.swift
//  ReplayMe
//
//  Created by Krishna on 04/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class UserViewController: UIViewController,NVActivityIndicatorViewable,CollectionViewCellDelegate {
    @IBOutlet var lblPrivate: UILabel!
    @IBOutlet var freindRequestHight: NSLayoutConstraint!
    @IBOutlet var backProfileImgHieght: NSLayoutConstraint!
    
    @IBOutlet var friendRequestView: UIView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userProfileImg: UIImageView!
    @IBOutlet var profileBackImg: UIImageView!
    
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var totlaFollowingLbl: UILabel!
    
    @IBOutlet var unblockBtn: UIButton!
    @IBOutlet var totalFallowersLbl: UILabel!
    @IBOutlet var totalLikeLbl: UILabel!
    @IBOutlet var followBtn: UIButton!
    @IBOutlet var containtLbl: UILabel!
    @IBOutlet var requestUserNameLbl: UILabel!
    @IBOutlet var followingLblAction: UILabel!
    @IBOutlet var followerLblAction: UILabel!
    
    
    // var videoArray = VideoList()
    var tappedCell: CollectionViewCellModel!
    var modelArr = [TableViewCellModel]()
    var videoListArry: [Any] = []
    var favVideoListArry: [Any] = []
    var userIdStr: String = ""
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var blockUserTitle: String = ""
    var checkProfile : String = ""
    @IBOutlet var shadowImgView: UIImageView!
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        // Register the xib for tableview cell
        let cellNib = UINib(nibName: "OtherUserTblCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "tableviewcellid")
        unblockBtn.isHidden = true
        self.blockUserTitle = "Block"
        
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingUserOnTap))
        followingLblAction.isUserInteractionEnabled = true
        followingLblAction.addGestureRecognizer(followingTapGesture)
         let followersCountTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingUserOnTap))
        totlaFollowingLbl.isUserInteractionEnabled = true
        totlaFollowingLbl.addGestureRecognizer(followersCountTapGesture)
        
        let followersTapGesture = UITapGestureRecognizer(target: self, action: #selector(followersOnTap))
        followerLblAction.isUserInteractionEnabled = true
        followerLblAction.addGestureRecognizer(followersTapGesture)
        let followersContTapGesture = UITapGestureRecognizer(target: self, action: #selector(followersOnTap))
        totalFallowersLbl.isUserInteractionEnabled = true
        totalFallowersLbl.addGestureRecognizer(followersContTapGesture)
        self.friendRequestView.isHidden = true
        
    }

    @objc func followingUserOnTap() {
        DispatchQueue.main.async {
            if self.followBtn.currentTitle == "Following" && self.checkProfile == "private" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserFollowViewController") as! UserFollowViewController
                           vc.checkTab = 0
                           vc.userIdStrig = self.userIdStr
                           vc.checkController = "otherProfile"
                vc.navTitleStr = self.userName
                           self.navigationController?.pushViewController(vc, animated: true)
            }
            if self.checkProfile == "public"{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserFollowViewController") as! UserFollowViewController
                                        vc.checkTab = 0
                                        vc.userIdStrig = self.userIdStr
                                        vc.checkController = "otherProfile"
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
           
            
        }
    }
    @objc func followersOnTap() {
 
        if self.followBtn.currentTitle == "Following" && self.checkProfile == "private" {
               let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserFollowViewController") as! UserFollowViewController
                           vc.checkTab = 1
                           vc.userIdStrig = self.userIdStr
                           vc.checkController = "otherProfile"
                           vc.navTitleStr = userName
                           self.navigationController?.pushViewController(vc, animated: true)
             }
        if self.checkProfile == "public"{
               let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserFollowViewController") as! UserFollowViewController
                          vc.checkTab = 1
                          vc.userIdStrig = self.userIdStr
                          vc.checkController = "otherProfile"
                          self.navigationController?.pushViewController(vc, animated: true)
                  
              }
    }
    
    // MARK: - User Detail Service Method
    
    func userDetailListApi() {
        
        self.startAnimating()
        let para = ["userId": userIdStr]
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kOtherUserList, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
                if (dict["data"]) != nil
                {
                    let userDetail  = ((dict as AnyObject).object(forKey: "data") as! NSDictionary?)
                    self.userNameLbl.text = String(format: "%@ %@",((userDetail as AnyObject).object(forKey: "firstName") as! String?)!,((userDetail as AnyObject).object(forKey: "lastName") as! String?)!)
                    self.userName = ((userDetail as AnyObject).object(forKey: "firstName") as! String?)!
                    self.containtLbl.text = ((userDetail as AnyObject).object(forKey: "bio") as! String?)!
                    self.userProfileImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                    self.profileBackImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                    let followers = ((userDetail as AnyObject).object(forKey: "followers") as! Int?)!
                    let following = ((userDetail as AnyObject).object(forKey: "following") as! Int?)!
                    let totalLike = ((userDetail as AnyObject).object(forKey: "likes") as! Int?)!
                    let friendStatus = (((userDetail as AnyObject).object(forKey: "friendStatus") as! String?)!)
                    
                    
                    self.fetchBtnTitle(checkFrindStatus: friendStatus)
                    
                    self.totalLikeLbl.text = "\(totalLike)"
                    self.totlaFollowingLbl.text = "\(following)"
                    self.totalFallowersLbl.text = "\(followers)"
                    if (((userDetail as AnyObject).object(forKey: "privateprofile") as! String?)!) == "No"{
                        self.tableView.isHidden = false
                        self.lblPrivate.isHidden = true
                        self.lblPrivate.text = nil
                        self.checkProfile = "public"
                    }
                    else{
                        self.tableView.isHidden = true
                        self.lblPrivate.isHidden = false
                        self.lblPrivate.text = "The profile is private"
                        self.checkProfile = "private"
                    }
                    if (((userDetail as AnyObject).object(forKey: "requestreceived") as! String?)!) == "no"{
                        self.freindRequestHight.constant = 0
                        self.friendRequestView.isHidden = true
                        self.backProfileImgHieght.constant = 310
                    }
                    else{
                        self.freindRequestHight.constant = 89
                        self.friendRequestView.isHidden = false
                        self.backProfileImgHieght.constant = 406
                        self.requestUserNameLbl.text = ((userDetail as AnyObject).object(forKey: "firstName") as! String?)! + " wants to follow you"
                    }
                    if (((userDetail as AnyObject).object(forKey: "privateprofile") as! String?)!) == "No"{
                        let dataDic = dict["data"] as? Dictionary<String, AnyObject>
                        let videoArr = dataDic!["video"] as? [Any]
                        let favVideoArr = dataDic!["fav_video"] as? [Any]
                        if let videoArrTmp = videoArr, videoArrTmp.count != 0{
                            var innerArr = [CollectionViewCellModel]()
                            for video in videoArrTmp{
                                let videoDic = video as! Dictionary<String, AnyObject>
                                
                                let content = videoDic["content"] as? String ?? ""
                                let _id = videoDic["_id"] as? String ?? ""
                                let videoUrl = videoDic["videoUrl"] as? String ?? ""
                                let videoScreenShotUrl = videoDic["videoScreenShotUrl"] as? String ?? ""
                                let views = videoDic["views"] as? Int ?? 0
                                
                                let inerItem = CollectionViewCellModel(content: content, _id: _id, videoUrl: videoUrl, videoScreenShotUrl: videoScreenShotUrl, views: "\(views)")
                                innerArr.append(inerItem)
                            }
                            let item = TableViewCellModel(
                                category: "My Video",
                                subcategory: "\(innerArr.count)",
                                videos:innerArr
                            )
                            self.modelArr.append(item)
                        }
                        
                        if let favVideoArrTmp = favVideoArr, favVideoArrTmp.count != 0{
                            var innerArr = [CollectionViewCellModel]()
                            for video in favVideoArrTmp{
                                let videoDic = video as! Dictionary<String, AnyObject>
                                
                                let content = videoDic["content"] as? String ?? ""
                                let _id = videoDic["_id"] as? String ?? ""
                                let videoUrl = videoDic["videoUrl"] as? String ?? ""
                                let videoScreenShotUrl = videoDic["videoScreenShotUrl"] as? String ?? ""
                                let views = videoDic["views"] as? Int ?? 0
                                print(views)
                                
                                let inerItem = CollectionViewCellModel(content: content, _id: _id, videoUrl: videoUrl, videoScreenShotUrl: videoScreenShotUrl, views: "\(views)")
                                
                                innerArr.append(inerItem)
                            }
                            let item = TableViewCellModel(
                                category: "Favorite videos",
                                subcategory: "\(innerArr.count)",
                                videos: innerArr
                            )
                            self.modelArr.append(item)
                        }
                        
                    }
                    self.tableView.reloadData()
                 
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
    
   
    
    override func viewWillAppear(_ animated: Bool) {
         self.modelArr = [TableViewCellModel]()
        if (appDel.isLandscape)
        {
            self.containtLbl.textAlignment = .left
            self.userNameLbl.textAlignment = .left
            userDetailListApi()
        }
        else
        {
            self.containtLbl.textAlignment = .center
            self.userNameLbl.textAlignment = .center
            userDetailListApi()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
//                 self.shadowImgView.image = UIImage(named: "shadow_land.png")
                self.freindRequestHight.constant = 0
                self.friendRequestView.isHidden = true
                // self.backProfileImgHieght.constant = 302
                self.modelArr = [TableViewCellModel]()
                self.containtLbl.textAlignment = .left
                self.userNameLbl.textAlignment = .left
                self.userDetailListApi()
            }
        } else {
            print("Portrait")
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                //self.shadowImgView.image = UIImage(named: "shadow.png")
                self.freindRequestHight.constant = 0
                self.friendRequestView.isHidden = true
                self.backProfileImgHieght.constant = 310
                self.modelArr = [TableViewCellModel]()
                self.containtLbl.textAlignment = .center
                self.userNameLbl.textAlignment = .center
                self.userDetailListApi()
            }
            
            
        }
        
    }
    // MARK: - User Accept Follow Service Method
    
    @IBAction func acceptFollowBtnClicked(_ sender: Any) {
        self.startAnimating()
        let para = ["userId":userIdStr]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kAcceptFollowRequest, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                if (self.appDel.isLandscape)
                {
                    self.freindRequestHight.constant = 0
                    self.friendRequestView.isHidden = true
                    self.backProfileImgHieght.constant = 310
                }
                else{
                    self.freindRequestHight.constant = 0
                    self.friendRequestView.isHidden = true
                    //  self.backProfileImgHieght.constant = 310
                }
                self.fetchBtnTitle(checkFrindStatus: (dict["friendStatus"] as? String)!)
            }
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
        
    }
    @IBAction func unblockBtnClicked(_ sender: Any) {
        unBlockUserApi()
    }
    
    @IBAction func requestDeletBtnClicked(_ sender: Any) {
        self.startAnimating()
        let para = ["userId": userIdStr,"type": "receiver"]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kDeletFollowRequest, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                if (self.appDel.isLandscape)
                {
                    self.freindRequestHight.constant = 0
                    self.friendRequestView.isHidden = true
                    self.backProfileImgHieght.constant = 310
                }
                else{
                    self.freindRequestHight.constant = 0
                    self.friendRequestView.isHidden = true
                    //  self.backProfileImgHieght.constant = 310
                }
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.fetchBtnTitle(checkFrindStatus: (dict["friendStatus"] as? String)!)
            }
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
        
    }
    
    
    @IBAction func moreBtnClicked(_ sender: Any) {
        
        if (appDel.isLandscape)
        {
            landscapeMoreBtn()
        }
        else
        {
            portraitMoreBtn()
        }
    }
    func landscapeMoreBtn() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if self.followBtn.currentTitle == "Block"{
            
            alert.addAction(UIAlertAction(title: self.followBtn.currentTitle, style: .default, handler: { (_) in
                if self.followBtn.currentTitle == "Follow"{
                    self.followUserApi()
                }else if self.followBtn.currentTitle == "Following"{
                    self.unFollowUserApi()
                }else if self.followBtn.currentTitle == "Requested"{
                    self.cancelFollowRwquestApi()
                    
                }else if self.followBtn.currentTitle == "Follow back"{
                    self.followUserApi()
                    
                }else if self.followBtn.currentTitle == "Unblock"{
                    self.blockUserApi()
                    self.blockUserTitle = "Block"
                    
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Message", style: .default, handler: { (_) in
            print("User click Edit button")
        }))
        alert.addAction(UIAlertAction(title: blockUserTitle, style: .default, handler: { (_) in
            if self.blockUserTitle == "Block"{
                self.blockUserApi()
            }
            else{
                self.unBlockUserApi()
            }
        }))
        alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { (_) in
            print("User click Edit button")
            self.reportUserApi()
        }))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (_) in
            print("User click Edit button")
            // let text = "This is the text...."
            // let image = UIImage(named: "Product")
            let myWebsite = NSURL(string:"https://stackoverflow.com/users/4600136/mr-javed-multani?tab=profile")
            let shareAll = [myWebsite]
            let activityViewController = UIActivityViewController(activityItems: shareAll as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func portraitMoreBtn() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: blockUserTitle, style: .default, handler: { (_) in
            if self.blockUserTitle == "Block"{
                self.blockUserApi()
            }
            else{
                self.unBlockUserApi()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { (_) in
            print("User click Edit button")
            self.reportUserApi()
        }))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (_) in
            print("User click Edit button")
            let myWebsite = NSURL(string:"https://stackoverflow.com/users/4600136/mr-javed-multani?tab=profile")
            let shareAll = [myWebsite]
            let activityViewController = UIActivityViewController(activityItems: shareAll as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    @IBAction func messageBtnClciked(_ sender: Any) {
    }
    
    @IBAction func backBtnclicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func followBtnClicked(_ sender: Any) {
        if followBtn.currentTitle == "Follow"{
            followUserApi()
        }else if followBtn.currentTitle == "Following"{
            unFollowUserApi()
        }else if followBtn.currentTitle == "Requested"{
            cancelFollowRwquestApi()
            
        }else if followBtn.currentTitle == "Follow back"{
            followUserApi()
            
        }else if followBtn.currentTitle == "Unblock"{
            blockUserApi()
            self.blockUserTitle = "Block"
            
        }
        
    }
    
    // MARK: - follow-user Service Method
    func followUserApi()  {
        self.startAnimating()
        let para = ["userId": userIdStr]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kFollowUser, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.fetchBtnTitle(checkFrindStatus: (dict["friendStatus"] as? String)!)
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    
    // MARK: - Unfollow-user Service Method
    func unFollowUserApi()  {
        self.startAnimating()
        let para = ["userId": userIdStr]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kUnFollowUser, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.fetchBtnTitle(checkFrindStatus: (dict["friendStatus"] as? String)!)
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    
    // MARK: - Cancel Follow Request Service Method
    func cancelFollowRwquestApi()  {
        self.startAnimating()
        let para = ["userId": userIdStr,"type": "sender"]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kDeletFollowRequest, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.fetchBtnTitle(checkFrindStatus: (dict["friendStatus"] as? String)!)
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    
    // MARK: - Block User Service Method
    
    func blockUserApi()  {
        self.startAnimating()
        let para = ["blockUserId": userIdStr]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kUserBlock, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.unblockBtn.isHidden = false
                
                self.blockUserTitle = "Unblock"
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    
    // MARK: - Unblock User Service Method
    func unBlockUserApi()  {
        self.startAnimating()
        let para = ["unblockUserId": userIdStr]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kUserUnblock, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.unblockBtn.isHidden = true
                self.fetchBtnTitle(checkFrindStatus:"follow")
                self.blockUserTitle = "Block"
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    // MARK: - Report User Service Method
    func reportUserApi()  {
        self.startAnimating()
        let para = ["userId": userIdStr]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kUserReport, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    func fetchBtnTitle(checkFrindStatus: String){
        if checkFrindStatus == "follow"{
            self.followBtn.setTitle("Follow", for: [])
            print("device/users/follow-user")
            
        }
        else if checkFrindStatus == "unfollow"{
            self.followBtn.setTitle("Following", for: [])
            print("device/users/unfollow-user")
            
        }
        else if checkFrindStatus == "send"{
            self.followBtn.setTitle("Requested", for: [])
            print("device/users/cancel-follow-request")
            
        }
        else if checkFrindStatus == "followback"{
            self.followBtn.setTitle("Follow back", for: [])
            print("device/users/follow-user")
            return
        }  else if checkFrindStatus == "block"{
            self.followBtn.setTitle("Unblock", for: [])
            unblockBtn.isHidden = false
            self.blockUserTitle = "Unblock"
        }
        
        
    }
}

@available(iOS 13.0, *)
extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return modelArr.count
        // return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        // return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as? OtherUserTblCell {
            
            //  let categoryTitle = modelArr[indexPath.section].category
            let subCategoryTitle = modelArr[indexPath.section].subcategory
            cell.titileLbl.text = modelArr[indexPath.section].category
            cell.totalVideoCount.text = "(\(subCategoryTitle) Videos)"
            //"\(categoryTitle)(\(subCategoryTitle) Videos)"
            
            // Pass the data to colletionview inside the tableviewcell
            let rowArray = modelArr[indexPath.section].videos
            cell.updateCellWith(row: rowArray)
            
            // Set cell's delegate
            cell.cellDelegate = self as? CollectionViewCellDelegate
            
            cell.selectionStyle = .none
            return cell
            return cell
        }
        return UITableViewCell()
    }
    
    func collectionView(collectionviewcell: OtherUserCollectionCell?, index: Int, didTappedInTableViewCell: OtherUserTblCell) {
        if let dataRow = didTappedInTableViewCell.rowWithData {
            self.tappedCell = dataRow[index]
            print(self.tappedCell as Any)
            // let data = tappedCell.content
            
            let detailDict = ["videoScreenShotUrl": tappedCell.videoScreenShotUrl,"videoUrl":tappedCell.videoUrl,"views": tappedCell.views,"content": tappedCell.content ,"_id": tappedCell._id]
            
            let playerVc = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserVideoViewController") as! OtherUserVideoViewController
            playerVc.playerDetailDict = detailDict as [String : AnyObject]
            self.navigationController?.pushViewController(playerVc, animated: true)
            
        }
    }
    
}


