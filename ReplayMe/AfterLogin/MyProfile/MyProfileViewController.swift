//
//  MyProfileViewController.swift
//  ReplayMe
//
//  Created by Krishna on 11/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import MXSegmentedControl
//import AlamofireImage

@available(iOS 13.0, *)
class MyProfileViewController: UIViewController,NVActivityIndicatorViewable,CollectionViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
     var recordedVideoURL: NSURL?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userProfileImg: UIImageView!
    @IBOutlet var profileBackImg: UIImageView!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var userNickNameLbl: UILabel!
    @IBOutlet var userEmail: UILabel!
    @IBOutlet var bioLbl: UILabel!
    @IBOutlet var userWebsite: UILabel!

    @IBOutlet var totlaFollowingLbl: UILabel!
    @IBOutlet var totalFallowersLbl: UILabel!
    @IBOutlet var totalLikeLbl: UILabel!
    @IBOutlet var followingLbl: UILabel!
    @IBOutlet var followerLbl: UILabel!
    @IBOutlet var ProfilesegmentedControl: MXSegmentedControl!

    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    // var videoArray = VideoList()
    var tappedCell: CollectionViewCellModel!
    var modelArr = [TableViewCellModel]()
    var userIdStr: String = ""
     let appDel = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var tabCameraBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        ProfilesegmentedControl.append(title: "Recents")
            .set(titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .selected)
        ProfilesegmentedControl.append(title: "Favorite")
        ProfilesegmentedControl.append(title: "Events")

            .set(titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .selected)
        
        ProfilesegmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)

        ProfilesegmentedControl.addTarget(self, action: #selector(changeIndex(segmentedControl:)), for: .valueChanged)
      
    }
    
    
    @objc func changeIndex(segmentedControl: MXSegmentedControl) {
           switch segmentedControl.selectedIndex {
           case 0:
               segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 0.5490196078, green: 0.3215686275, blue: 1, alpha: 1)
               if appDel.isLandscape == false {
               }
           case 1:
               segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 0.5490196078, green: 0.3215686275, blue: 1, alpha: 1)
             
               
           default:
               break
           }
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
        self.appDel.orientationLock = .all
                 
             }
         self.modelArr = [TableViewCellModel]()
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.separatorStyle = .none
        
        // Register the xib for tableview cell
        let cellNib = UINib(nibName: "OtherUserTblCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "tableviewcellid")
        tableView.backgroundColor = .clear
        userDetailListApi()
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(totalFollowingUserOnTap))
        followingLbl.isUserInteractionEnabled = true
    followingLbl.addGestureRecognizer(followingTapGesture)
        
        let totalFolowingTap = UITapGestureRecognizer(target: self, action: #selector(totalFollowingUserOnTap))
             totlaFollowingLbl.isUserInteractionEnabled = true
           totlaFollowingLbl.addGestureRecognizer(totalFolowingTap)
        
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(totalFollower))
           followerLbl.isUserInteractionEnabled = true
           followerLbl.addGestureRecognizer(followerTap)
        
        let totalFollowerTap = UITapGestureRecognizer(target: self, action: #selector(totalFollower))
            totalFallowersLbl.isUserInteractionEnabled = true
         totalFallowersLbl.addGestureRecognizer(totalFollowerTap)
        
    }
    
    @objc func totalFollower() {
 DispatchQueue.main.async {
    let   loginUserDetail = UserDefaults.standard.value(forKey: "userDetailDict") as! NSDictionary;
    if self.totlaFollowingLbl.text != "0"{
              let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserFollowViewController") as! UserFollowViewController
                         vc.checkTab = 1
                            vc.userIdStrig = loginUserDetail["_id"] as! String
                            vc.checkController = "MyProfile"
              vc.navTitleStr = loginUserDetail["firstName"] as! String
              self.navigationController?.pushViewController(vc, animated: true)
    }
          }
     }
    
     @objc func totalFollowingUserOnTap() {
     
        DispatchQueue.main.async {
        let loginUserDetail = UserDefaults.standard.value(forKey: "userDetailDict") as! NSDictionary;
             if self.totalFallowersLbl.text != "0"{
                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserFollowViewController") as! UserFollowViewController
                             vc.checkTab = 0
                                vc.userIdStrig = loginUserDetail["_id"] as! String
                vc.navTitleStr = loginUserDetail["firstName"] as! String
                                vc.checkController = "MyProfile"
                  self.navigationController?.pushViewController(vc, animated: true)
            }
              }

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            DispatchQueue.main.async {
                self.tabCameraBtn.setImage(UIImage(named: "cameral.png"), for: .normal)
              //  self.bioLbl.textAlignment = .left
                self.userNameLbl.textAlignment = .left
            }
        } else {
            print("Portrait")
            DispatchQueue.main.async {
                self.tabCameraBtn.setImage(UIImage(named: "video-camera.png"), for: .normal)
                self.bioLbl.textAlignment = .center
                self.userNameLbl.textAlignment = .center
            }
   
        }
        
    }
    
    func userDetailListApi() {
        
        self.startAnimating()
        //let para = ["userId": userIdStr]
        ServiceClassMethods.AlamoRequest(method: "GET", serviceString: appConstants.kmyProfile, parameters: nil) { (dict) in
            print(dict)
            self.stopAnimating()
            if let status = dict["status"] as? String
            {
                if(status == "true"){
                    if let userDetail  = dict.object(forKey: "data") as? NSDictionary
                    {
                        
                        
                          self.userNameLbl.text = (userDetail.object(forKey: "userName") as! String?)
                        self.userNickNameLbl.text = String(format: "%@ %@",(userDetail.object(forKey: "firstName") as! String?)!,(userDetail.object(forKey: "lastName") as! String?)!)
                        self.userEmail.text = (userDetail.object(forKey: "email") as! String?)

                        //Arun
                        self.userWebsite.text = (userDetail.object(forKey: "email") as! String?)

                        self.bioLbl.text = (userDetail.object(forKey: "bio") as! String?)
                        self.userProfileImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+((userDetail.object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                        //ARUN
                     //   self.profileBackImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+((userDetail.object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                        let followers = (userDetail.object(forKey: "followers") as! Int?)!
                        let following = (userDetail.object(forKey: "following") as! Int?)!
                        let totalLike = (userDetail.object(forKey: "likes") as! Int?)!
                        
                        self.totalLikeLbl.text = "\(totalLike)"
                        self.totlaFollowingLbl.text = "\(following)"
                        self.totalFallowersLbl.text = "\(followers)"
                        
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
                              //  category: "My Videos",
                                category: "",

                                subcategory: "",
                              //  subcategory: "\(innerArr.count)",

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
                                category: "Favorite Videos",
                                subcategory: "\(innerArr.count)",
                                videos: innerArr
                            )
                            self.modelArr.append(item)
                        }
                        
                        
                        self.tableView.reloadData()
                        self.blureImage()
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
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                // self.serachListArray = []
                //self.tableView.reloadData()
            }
            
        }
        
    }
    func blureImage(){
//         1
//          let darkBlur = UIBlurEffect(style: .extraLight)
//          // 2
//          let blurView = UIVisualEffectView(effect: darkBlur)
//          blurView.frame = profileBackImg.bounds
//          // 3
//          profileBackImg.addSubview(blurView)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Got a video")
         
               // MKProgress.show(animated: true)
                recordedVideoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! NSURL?
                let asset1 = AVURLAsset(url: videoURL! as URL, options: nil)

                let data = NSData(contentsOf: videoURL! as URL)!
                print("File size before compression: \(Double(data.length / 1048576)) mb")
    
                    
                     self.dismiss(animated: true, completion: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostNewsFeedViewController") as! PostNewsFeedViewController
        secondViewController.recordedVideoURL = videoURL!
              secondViewController.typeStr = "gallery"; self.navigationController?.pushViewController(secondViewController, animated: true)
                }

    @IBAction func draftBtnClciked(_ sender: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DraftViewController") as! DraftViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    @IBAction func editBtnClicked(_ sender: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileViewController") as! UpdateProfileViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    @IBAction func moreBtnClicked(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (_) in
            self.imagePicker.sourceType = .photoLibrary
                     self.imagePicker.mediaTypes = ["public.movie"]
                     self.imagePicker.allowsEditing = true
                     self.imagePicker.videoQuality = . typeLow
                     self.imagePicker.videoMaximumDuration = 59.0
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (_) in
          
    
            
        }))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
          
            DispatchQueue.main.async {
                 let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
                 self.navigationController?.pushViewController(secondViewController, animated: true)
             }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
            print("User click Delete button")
            UserDefaults.standard.set("Logout", forKey: "login")
            let loginManager = LoginManager()
            loginManager.logOut()
            let sessionStore = TWTRTwitter.sharedInstance().sessionStore
            if let userID = sessionStore.session()?.userID {
                sessionStore.logOutUserID(userID)
            }
            
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        alert.view.tintColor = #colorLiteral(red: 0.0431372549, green: 0.07058823529, blue: 0.1019607843, alpha: 1)
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    @IBAction func chatBtnClicked(_ sender: Any) {
    }
    @IBAction func homeBtnClicked(_ sender: Any) {

        let dashboardVC = navigationController!.viewControllers.filter { $0 is HomeViewController }.first!
        navigationController!.popToViewController(dashboardVC, animated: false)
    }
    
    @IBAction func searchBtnClicked(_ sender: Any) {
   let playerVc = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
         
   self.navigationController?.pushViewController(playerVc, animated: false)
    }
    @IBAction func cameraBtnClicked(_ sender: Any) {
        DispatchQueue.main.async {
              let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
              self.navigationController?.pushViewController(cameraVC, animated: false)
          }
    }
    @IBAction func bellBtnClciked(_ sender: Any) {
        DispatchQueue.main.async {
                  let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "PepopleMayKnowViewController") as! PepopleMayKnowViewController
                  self.navigationController?.pushViewController(cameraVC, animated: false)
              }
    }
    
}
@available(iOS 13.0, *)
extension MyProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return modelArr.count
        // return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        // return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as? OtherUserTblCell {
            
            //  let categoryTitle = modelArr[indexPath.section].category
            cell.backgroundColor = .clear
            let subCategoryTitle = modelArr[indexPath.section].subcategory
            cell.titileLbl.text = modelArr[indexPath.section].category
            cell.totalVideoCount.text = "(\(subCategoryTitle) Videos)"
            //"\(categoryTitle)(\(subCategoryTitle) Videos)"
            
            // Pass the data to colletionview inside the tableviewcell
            let rowArray = modelArr[indexPath.section].videos
            cell.updateCellWith(row: rowArray)
            
            // Set cell's delegate
           // cell.cellDelegate = self as? CollectionViewCellDelegate
            cell.cellDelegate = self
            
            cell.selectionStyle = .none
            return cell
          
        }
        return UITableViewCell()
    }
    func collectionView(collectionviewcell: OtherUserCollectionCell?, index: Int, didTappedInTableViewCell: OtherUserTblCell) {
        if let dataRow = didTappedInTableViewCell.rowWithData {
            self.tappedCell = dataRow[index]
            print(self.tappedCell as Any)
           // let data = tappedCell.content
           
            let detailDict = ["videoScreenShotUrl": tappedCell.videoScreenShotUrl,"videoUrl":tappedCell.videoUrl,"views": tappedCell.views,"content": tappedCell.content ,"id": tappedCell._id]
            
             let playerVc = self.storyboard?.instantiateViewController(withIdentifier: "FullScreenVideoPlayerController") as! FullScreenVideoPlayerController
           playerVc.playerDetailDict = detailDict as [String : AnyObject]
  self.navigationController?.pushViewController(playerVc, animated: true)
          
        }
    }
}


