//
//  HomeViewController.swift
//  ReplayMe
//
//  Created by Core Techies on 28/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.


import AVFoundation
import AVKit
import CoreMedia
import MXSegmentedControl
import SDWebImage
import UIKit
import UILoadControl


@available(iOS 13.0, *)
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, NVActivityIndicatorViewable {
    // MARK: - Outlet Declaration

    @IBOutlet var segmentedControl: MXSegmentedControl!
    @IBOutlet var usersStoryCollectionView: UICollectionView!
    @IBOutlet var collectionviewHieght: NSLayoutConstraint!
    @IBOutlet var collectionviewHieght2: NSLayoutConstraint!
    @IBOutlet var newsFeedTblView: UITableView!
    @IBOutlet var btnAddStory: UIButton!
    @IBOutlet var lblAddStory: UILabel!

    // MARK: - Variable Declaration

    var indexOfTable = IndexPath(row: 0, section: 0)
    var newsFeedListArray: [Any] = []
    var userDetails: [UserDetails] = []
    var storyListArray: [[String: Any]] = []
    var checkIndexPath = IndexPath()
    var updateLikeDict = [String: AnyObject]()
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var getCellHieght: Float = 0.0
    var avPlayer: AVPlayer!
    var visibleIP: IndexPath?
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    var videoURLs = [URL]()
    var playerItemList: [VideoPlayerItem] = []
    var firstLoad = true
    var lastPlayingIndex: IndexPath!
    var checkTopTab: String = "following"
    var listPageCount: Int = 1
    var listTotalPage: Int = 0
    var refreshControl = UIRefreshControl()

    fileprivate var currentAutoPlayCellIdx: IndexPath? = IndexPath(row: 0, section: 0)
    fileprivate var viewTransitionInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        segmentedControl.append(title: "Following")
            .set(titleColor:  colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        segmentedControl.append(title: "Trending")
            .set(titleColor:  colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        
        segmentedControl.indicator.lineView.backgroundColor =  colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)

        segmentedControl.addTarget(self, action: #selector(changeIndex(segmentedControl:)), for: .valueChanged)
        newsFeedTblView.isPagingEnabled = true
        collectionviewHieght.constant = 106
        collectionviewHieght2.constant = 106
        if self.appDel.isLandscape {
            self.newsFeedTblView.isPagingEnabled = true
        } else {
            self.newsFeedTblView.isPagingEnabled = false
        }
        newsFeedTblView.loadControl = UILoadControl(target: self, action: #selector(loadMore(sender:)))
        newsFeedTblView.loadControl?.heightLimit = 100.0
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        newsFeedTblView.addSubview(refreshControl) // not required when using UITableViewController
        segmentedControl?.select(index: 1, animated: true)
        
    }

    @objc func refresh(_: AnyObject) {
        listPageCount = 1
        newsFeedListArray = []
        refreshControl.endRefreshing()
        homeListApi()
    }

    override func viewWillAppear(_: Bool) {
        // newsFeedListArray = []
        if self.appDel.isLandscape {
            self.newsFeedTblView.isPagingEnabled = true
        } else {
            self.newsFeedTblView.isPagingEnabled = false
        }
        DispatchQueue.main.async {
            self.tabBarController?.tabBar.isHidden = false
            self.view.layoutIfNeeded()
            if self.newsFeedListArray.count > 0 {
                if self.appDel.isLandscape {
                    self.newsFeedTblView.isPagingEnabled = true
                    self.storyHide()
                } else {
                    self.newsFeedTblView.isPagingEnabled = false
                }
                self.newsFeedTblView.reloadData()
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(OnOrientationChange),
            name: NSNotification.Name(rawValue: "OnOrientationChange"),
            object: nil
        )
    }

    @objc func OnOrientationChange() {
        print("OnOrientationChange")
        if newsFeedListArray.count > 0 {
            if appDel.isLandscape {
                newsFeedTblView.isPagingEnabled = true
                usersStoryCollectionView.reloadData()
                collectionviewHieght.constant = 0
                collectionviewHieght2.constant = 0
                lblAddStory.isHidden = true
                btnAddStory.isHidden = true
            } else {
                newsFeedTblView.isPagingEnabled = false

                if checkTopTab == "following" {
                    storyShow()
                } else {
                    storyHide()
                }
                newsFeedTblView.reloadData()
                //newsFeedTblView.scrollToRow(at: indexOfTable, at: UITableView.ScrollPosition.top, animated: false)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "OnOrientationChange"), object: nil)
        let visibleCells = newsFeedTblView.visibleCells
        visibleCells.forEach { (cell) in
            if let c = cell as? HomeNewFeedCell{
                c.playerView.player?.pause()
            }
            if let videoCell = (cell as? NewsFeedLandscapeCell) {
                videoCell.playerView.player?.pause()
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // self.appDel.myOrientation = .all
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appDel.showCamera {
            appDel.showCamera = false
            // let cameraVC = storyboard!.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            // self.navigationController?.pushViewController(cameraVC, animated: false)

            // storyUserDataApi()
        } else {
            if appDel.isLandscape {
                storyHide()
            }
            // newsFeedListArray = []
            //  homeListApi()
            // segmentedControl?.select(index:1, animated: true)
            // storyUserDataApi()
        }
    }

    func storyShow() {
        DispatchQueue.main.async {
            self.usersStoryCollectionView.reloadData()
            self.collectionviewHieght.constant = 106
            self.collectionviewHieght2.constant = 106
            self.lblAddStory.isHidden = false
            self.btnAddStory.isHidden = false
            self.usersStoryCollectionView.isHidden = false
            self.storyUserDataApi()
        }
    }

    func storyHide() {
        DispatchQueue.main.async {
            self.collectionviewHieght.constant = 0
            self.collectionviewHieght2.constant = 0
            self.lblAddStory.isHidden = true
            self.btnAddStory.isHidden = true
            self.usersStoryCollectionView.reloadData()
            self.usersStoryCollectionView.isHidden = true
        }
    }

    // MARK: - update loadControl when user scrolls de tableView

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }

    // MARK: - load more tableView data

    @objc func loadMore(sender _: AnyObject?) {
        if listPageCount <= listTotalPage {
            listPageCount = listPageCount + 1
            homeListApi()
        } else {
            ShowBanner(title: "", subtitle: "No page found")
            newsFeedTblView.loadControl?.endLoading()
        }
    }

    // MARK: - Service Method

    func homeListApi(completionHandler: (() -> Void)? = nil) {
        startAnimating()
        let para = ["type": checkTopTab, "page": "\(listPageCount)"]
        print(para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kNewsFeedHomeList, parameters: para) { dict in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String

            if status == "true" {
                self.listTotalPage = (dict["totalpages"] as? Int)!
                if dict["data"] != nil {
                    let newsFeedData = (dict["data"] as! [Any])
                    for i in 0 ..< newsFeedData.count {
                        let newsfeedDict = newsFeedData[i] as! NSDictionary

                        let item = VideoPlayerItem()
                        if let urlStr = newsfeedDict.object(forKey: "videoUrl") as? String
                        {
                            var url: URL!
                            url = URL(string: urlStr)
                            item.url = url!
                        }
                        self.playerItemList.append(item)
                        self.newsFeedListArray.append(newsfeedDict)
                    }
                    self.newsFeedTblView.loadControl?.endLoading() // Update UILoadControl frame to the new UIScrollView bottom.
                    self.newsFeedTblView.reloadData()
                }
            } else {
                self.newsFeedTblView.loadControl?.endLoading()
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
            if completionHandler != nil {
                completionHandler!()
            }
        }
    }

    
    override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
        print("viewWillTransition")
        print("currentAutoPlayCellIdx is nil - \(currentAutoPlayCellIdx == nil)")
        print("currentAutoPlayCellIdx - \(currentAutoPlayCellIdx?.row ?? 0)")
        viewTransitionInProgress = true
        self.newsFeedTblView.isPagingEnabled = false
        if newsFeedListArray.count > 0 {
            if appDel.isLandscape {
                print("Landscape")
                storyHide()
                //newsFeedTblView.reloadData()
                if currentAutoPlayCellIdx != nil {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.viewTransitionInProgress = false
                        self.newsFeedTblView.estimatedRowHeight = self.newsFeedTblView.bounds.height
                        if self.currentAutoPlayCellIdx != nil {
                            print("currentAutoPlayCellIdx After - \(self.currentAutoPlayCellIdx?.row ?? 0)")
                            self.newsFeedTblView.scrollToRow(at: self.currentAutoPlayCellIdx!, at: UITableView.ScrollPosition.middle, animated: false)
                            self.newsFeedTblView.reloadRows(at: [self.currentAutoPlayCellIdx!], with: UITableView.RowAnimation.none)
                        }
                        self.newsFeedTblView.isPagingEnabled = true
                    }
                }
            } else {
                print("Portrait")
                storyShow()
                newsFeedTblView.reloadData()
                
                if currentAutoPlayCellIdx != nil {
//                    if currentAutoPlayCellIdx!.row > 0 {
//                        currentAutoPlayCellIdx = IndexPath(row: (currentAutoPlayCellIdx!.row - 1), section: currentAutoPlayCellIdx!.section)
//                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                        self.viewTransitionInProgress = false
                        self.newsFeedTblView.isPagingEnabled = false
                        //self.newsFeedTblView.estimatedRowHeight = self.view.bounds.width
                        if self.currentAutoPlayCellIdx != nil {
                            print("currentAutoPlayCellIdx After - \(self.currentAutoPlayCellIdx?.row ?? 0)")
                            //self.newsFeedTblView.contentOffset = CGPoint.zero
                            self.newsFeedTblView.scrollToRow(at: self.currentAutoPlayCellIdx!, at: UITableView.ScrollPosition.middle, animated: false)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                self.newsFeedTblView.reloadRows(at: [self.currentAutoPlayCellIdx!], with: UITableView.RowAnimation.none)
                            }
                        }
                        
                    }
                }
                
            }
        }
    }

    // MARK: - Table Cell Action Method

    @objc func viewComment(sender: UIButton) {
        DispatchQueue.main.async {
            let buttonRow = sender.tag
            let dataDic1 = self.newsFeedListArray[buttonRow] as! [String: Any]
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            secondViewController.newsFeedsIdStr = (dataDic1["_id"] as? String)!; self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }

    @objc func landscapeStoryBtn(sender _: UIButton) {
        if checkTopTab == "following" {
            storyShow()
        }
    }

    @objc func likeBtn(sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = newsFeedTblView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }

        print("button is in row \(indexPath.row)")
        let buttonRow = sender.tag
        let dataDic1 = newsFeedListArray[buttonRow] as! [String: Any]
        checkIndexPath = indexPath
        let checkType = (dataDic1["likes"] as? Bool)!
        let postId = (dataDic1["_id"] as? String)!
        if checkType == false {
            updateLikeDict = newsFeedListArray[buttonRow] as! [String: AnyObject]
            var totalLike: Int = Int((dataDic1["totallikes"] as? Int)!)
            totalLike += 1

            updateLikeDict["likes"] = true as AnyObject
            updateLikeDict["totallikes"] = totalLike as AnyObject
            newsFeedListArray[buttonRow] = updateLikeDict
            if let cell = newsFeedTblView.cellForRow(at: checkIndexPath) as? HomeNewFeedCell {
                cell.totalReactCountLbl.text = "\(totalLike) reacted"
                cell.likeBtn.setImage(UIImage(named: "heart_liked"), for: UIControl.State.normal)
                // cell.likeBtn.image = UIImage(named: "heartOutlineCopy")
            }
            if let cell = newsFeedTblView.cellForRow(at: checkIndexPath) as? NewsFeedLandscapeCell {
                cell.totalLikeLbl.text = "\(totalLike)"
                cell.buttonLike.setImage(UIImage(named: "heart_liked"), for: UIControl.State.normal)
                // cell.likeBtn.image = UIImage(named: "heartOutlineCopy")
            }
        } else {
            updateLikeDict = newsFeedListArray[buttonRow] as! [String: AnyObject]
            var totalLike: Int = Int((dataDic1["totallikes"] as? Int)!)
            totalLike -= 1

            updateLikeDict["likes"] = false as AnyObject
            updateLikeDict["totallikes"] = totalLike as AnyObject
            newsFeedListArray[buttonRow] = updateLikeDict
            if let cell = newsFeedTblView.cellForRow(at: checkIndexPath) as? HomeNewFeedCell {
                cell.totalReactCountLbl.text = "\(totalLike) reacted"
                cell.likeBtn.setImage(UIImage(named: "heart"), for: UIControl.State.normal)
                //  cell.likeImage.image = UIImage(named: "heartOutline")
            }
            if let cell = newsFeedTblView.cellForRow(at: checkIndexPath) as? NewsFeedLandscapeCell {
                cell.totalLikeLbl.text = "\(totalLike)"
                cell.buttonLike.setImage(UIImage(named: "heart"), for: UIControl.State.normal)
                // cell.likeBtn.image = UIImage(named: "heartOutlineCopy")
            }
        }
        likePostNewsFeed(with: postId)
    }

    // MARK: LikePostNewsFeed Service Method

    func likePostNewsFeed(with postId: String) {
        let para = ["newsFeedsId": postId]
        print(para)
        startAnimating()
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kLikePost, parameters: para as [String: Any]) { dict in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if status == "true" {
                let checkMessage = dict.object(forKey: "message") as! String
                if checkMessage == "News feed disliked successfully" {
                    self.ShowBanner(title: "", subtitle: "Post unlike successfully")
                } else {
                    self.ShowBanner(title: "", subtitle: "Post like successfully")
                }
            } else {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }

    @objc func userDetailBtn(sender: UIButton) {
        let loginUserDetail = UserDefaults.standard.value(forKey: "userDetailDict") as! NSDictionary
        let loginUserId = loginUserDetail["_id"] as! String

        let buttonRow = sender.tag
        let dataDic1 = newsFeedListArray[buttonRow] as! [String: Any]
        let userDetail = ((dataDic1 as AnyObject).object(forKey: "userdetails") as! NSDictionary?)
        if loginUserId == ((userDetail as AnyObject).object(forKey: "_id") as! String?)! {
            DispatchQueue.main.async {
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
                self.navigationController?.pushViewController(secondViewController, animated: false)
            }
        } else {
            let secondViewController = storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
            secondViewController.userIdStr = ((userDetail as AnyObject).object(forKey: "_id") as! String?)!
            navigationController?.pushViewController(secondViewController, animated: true)
        }
    }

    // MARK: Private func fetch StoryData

    private func storyUserDataApi() {
        startAnimating()

        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kStoryList, parameters: nil) { dict in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String

            if status == "true" {
                if dict["data"] != nil {
                    self.storyListArray = []
                    self.userDetails = []
                    self.storyListArray = (dict["data"] as! [[String: Any]])
                    if let storyListArray = dict["data"] as? [[String: Any]] {
                        for element in self.storyListArray {
                            self.userDetails += [UserDetails(userDetails: element)]
                        }
                    }
                    self.usersStoryCollectionView.reloadData()
                }
            } else {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }

    @IBAction func videoCameraBtnClicked(_: UIButton) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DraftViewController") as! DraftViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }

    // MARK: Custome Tab  Action

    @IBAction func chatBtnClicked(_: Any) {
        
        DispatchQueue.main.async {
                   let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DraftViewController") as! DraftViewController
                   self.navigationController?.pushViewController(secondViewController, animated: true)
               }
        
    }

    @IBAction func tabSearchBtnClicked(_: Any) {
        let secondViewController = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(secondViewController, animated: false)
    }

    @IBAction func tabCameraBtnClicked(_: Any) {
        DispatchQueue.main.async {
            let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            self.navigationController?.pushViewController(cameraVC, animated: false)
        }
    }

    @IBAction func tabBellBtnClicked(_: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PepopleMayKnowViewController") as! PepopleMayKnowViewController
            self.navigationController?.pushViewController(secondViewController, animated: false)
        }
    }

    @IBAction func tabProfileBtnClicked(_: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
            self.navigationController?.pushViewController(secondViewController, animated: false)
        }
    }

    @IBAction func addStoryBtnClicked(_: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DraftViewController") as! DraftViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
}

// MARK: - UICollectionView Delegate Method

@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView,
                        numberOfItemsInSection _: Int) -> Int {
        return userDetails.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! usersCollectionViewCell
        let userDetail = UserDefaults.standard.value(forKey: "userDetailDict") as! NSDictionary

        print(userDetails[indexPath.row].userId)

        if (userDetail["_id"] as! String) == userDetails[indexPath.row].userId {
            cell.imgView.sd_setImage(with: URL(string: appConstants.kBASE_URL + userDetails[indexPath.row].imageUrl), placeholderImage: UIImage(named: "layer35"))
            cell.lblUserName.text = "Your Story"

        } else {
            cell.imgView.sd_setImage(with: URL(string: appConstants.kBASE_URL + userDetails[indexPath.row].imageUrl), placeholderImage: UIImage(named: "layer35"))
            cell.lblUserName.text = userDetails[indexPath.row].name
            cell.imgView.borderColor =  colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
        }
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newsfeedDict = storyListArray[indexPath.row] as! NSDictionary
        let loginUserContentList = (newsfeedDict["content"] as! [Any])

        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentView") as! ContentViewController

            vc.modalPresentationStyle = .overFullScreen
            vc.pages = self.userDetails
            vc.currentIndex = indexPath.row
            self.present(vc, animated: true, completion: nil)
            // }
        }
    }
}

@available(iOS 13.0, *)

// MARK: - Table Delegate Method

extension HomeViewController {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        if appDel.isLandscape {
            return newsFeedTblView.bounds.height
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 0
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return newsFeedListArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexOfTable = indexPath
        if !viewTransitionInProgress {
           currentAutoPlayCellIdx = indexOfTable
        }
        print("cellForRowAt viewTransitionInProgress : - \(viewTransitionInProgress)")
        print("cellForRowAt cell:")
        if appDel.isLandscape {
            let myCell = tableView.dequeueReusableCell(withIdentifier: "newsFeedLandscape", for: indexPath) as! NewsFeedLandscapeCell
            let newsfeedDict = newsFeedListArray[indexPath.row] as! NSDictionary

            myCell.feedDetailLbl.text = ((newsfeedDict as AnyObject).object(forKey: "content") as! String?)!
            let userDetail = ((newsfeedDict as AnyObject).object(forKey: "userdetails") as! NSDictionary?)
            myCell.feedUserNameLbl.text = String(format: "%@ %@", ((userDetail as AnyObject).object(forKey: "firstName") as! String?)!, ((userDetail as AnyObject).object(forKey: "lastName") as! String?)!)
            myCell.feedUserIMg.sd_setImage(with: URL(string: appConstants.kBASE_URL + (((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))

            myCell.buttonComment?.tag = indexPath.row
            myCell.buttonComment?.addTarget(self, action: #selector(viewComment), for: .touchUpInside)
            myCell.buttonLike?.tag = indexPath.row
            myCell.buttonLike?.addTarget(self, action: #selector(likeBtn), for: .touchUpInside)
            myCell.storyBtn?.tag = indexPath.row
            myCell.storyBtn?.addTarget(self, action: #selector(landscapeStoryBtn), for: .touchUpInside)

            myCell.totalLikeLbl.text = "\(((newsfeedDict as AnyObject).object(forKey: "totallikes") as! Int?)!)"
            myCell.totalCommentLbl.text = "\(((newsfeedDict as AnyObject).object(forKey: "totalComments") as! Int?)!)"
            if (((newsfeedDict as AnyObject).object(forKey: "likes") as! Bool?)!) == true {
                myCell.buttonLike.setImage(UIImage(named: "heart_liked"), for: UIControl.State.normal)
            } else {
                myCell.buttonLike?.setImage(UIImage(named: "heart"), for: UIControl.State.normal)
            }

            myCell.playerThumbnailImg.sd_setImage(with: URL(string: ((newsfeedDict as AnyObject).object(forKey: "videoScreenShotUrl") as! String?)!), placeholderImage: UIImage(named: "video"))

            if checkTopTab == "following" {
                myCell.storyLbl.isHidden = false
                myCell.storyBtn.isHidden = false
            } else {
                myCell.storyLbl.isHidden = true
                myCell.storyBtn.isHidden = true
            }
            myCell.indexPath = indexPath
            if let videoURL = newsfeedDict["videoUrl"] as? String {
                myCell.configureCell(videoURL: videoURL)
            }
            return myCell
        } else {

            let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedCell", for: indexPath) as! HomeNewFeedCell
            if newsFeedListArray.count != 0 {
                let newsfeedDict = (newsFeedListArray[indexPath.row] as! NSDictionary)
                let videoUrlList = (newsfeedDict.value(forKey: "videoUrlList") as! NSArray)[0] as! NSDictionary
                if let urlStr = videoUrlList.object(forKey: "videoScreenShotUrl") as? String
                {
                    cell.playerThumb.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage(named: "video"))
                
                }
                cell.descriptionLabel.text = ((newsfeedDict as AnyObject).object(forKey: "content") as! String?)!
                cell.totalReactCountLbl.text = "\(((newsfeedDict as AnyObject).object(forKey: "totallikes") as! Int?)!) reacted"
                if (((newsfeedDict as AnyObject).object(forKey: "likes") as! Bool?)!) == true {
                    cell.likeBtn.setImage(UIImage(named: "heart_liked"), for: UIControl.State.normal)
                } else {
                    cell.likeBtn.setImage(UIImage(named: "heart"), for: UIControl.State.normal)
                }
                let userDetail = ((newsfeedDict as AnyObject).object(forKey: "userdetails") as! NSDictionary?)
                cell.postUserName.text = String(format: "%@ %@", ((userDetail as AnyObject).object(forKey: "firstName") as! String?)!, ((userDetail as AnyObject).object(forKey: "lastName") as! String?)!)

                cell.postUserImg.sd_setImage(with: URL(string: appConstants.kBASE_URL + (((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))

                cell.commentBtn?.tag = indexPath.row
                cell.commentBtn?.addTarget(self, action: #selector(viewComment), for: .touchUpInside)
                cell.likeBtn?.tag = indexPath.row
                cell.likeBtn?.addTarget(self, action: #selector(likeBtn), for: .touchUpInside)
                cell.indexPath = indexPath
                if let urlStr = videoUrlList.object(forKey: "videoUrl") as? String{
                    cell.configureCell(videoURL: urlStr)
                }
            }
            cell.userDetailBtn?.tag = indexPath.row
            cell.userDetailBtn?.addTarget(self, action: #selector(userDetailBtn), for: .touchUpInside)
            return cell
        }
    }

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        if appDel.isLandscape == true {
            storyHide()
        }
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("willDisplay cell:")
       // print("currentAutoPlayCellIdx - \(currentAutoPlayCellIdx?.row ?? 0)")
        if let videoCell = (cell as? HomeNewFeedCell) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                let visibleCells = tableView.visibleCells
                print("Visible Cell count - \(visibleCells.count)")
                visibleCells.forEach { (cell) in
                    if let c = cell as? HomeNewFeedCell, c.indexPath != self.currentAutoPlayCellIdx {
                        c.playerView.player?.pause()
                    }
                }
//                if videoCell.playerView.player != nil {
//                    self.currentAutoPlayCellIdx = indexPath
//                    videoCell.playerView.player?.play()
//                }
            }
        }
        if let videoCell = (cell as? NewsFeedLandscapeCell) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                let visibleCells = tableView.visibleCells
                print("Visible Cell count - \(visibleCells.count)")
                visibleCells.forEach { (cell) in
                    if let c = cell as? NewsFeedLandscapeCell, c.indexPath != self.currentAutoPlayCellIdx {
                        c.playerView.player?.pause()
                    }
                }
//                if videoCell.playerView.player != nil {
//                    self.currentAutoPlayCellIdx = indexPath
//                    videoCell.playerView.player?.play()
//                }
            }
        }
        //print("currentAutoPlayCellIdx - \(currentAutoPlayCellIdx?.row ?? 0)")
    }

    func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        let newsfeedDict = newsFeedListArray[indexPath.row] as! NSDictionary
//        let userDetail = ((newsfeedDict as AnyObject).object(forKey: "userdetails") as! NSDictionary?)
//        let text = String(format: "%@ %@", ((userDetail as AnyObject).object(forKey: "firstName") as! String?)!, ((userDetail as AnyObject).object(forKey: "lastName") as! String?)!)
//        print(text)
//        print("currentAutoPlayCellIdx - \(currentAutoPlayCellIdx?.row ?? -1)")
//        print("indexPath - \(indexPath.row)")
        if let videoCell = cell as? HomeNewFeedCell {
            videoCell.playerView.player?.pause()
            videoCell.playerView.player = nil
            
        }
        if let videoCell = cell as? NewsFeedLandscapeCell {
            videoCell.playerView.player?.pause()
            videoCell.playerView.player = nil
            
        }
    }
}

@available(iOS 13.0, *)
extension HomeViewController {
    // MARK: - MXSegmentedControl Methods

    @objc func changeIndex(segmentedControl: MXSegmentedControl) {
        switch segmentedControl.selectedIndex {
        case 0:
            segmentedControl.indicator.lineView.backgroundColor =  colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            if appDel.isLandscape == false {
                storyShow()
            }
            checkTopTab = "following"
        case 1:
            segmentedControl.indicator.lineView.backgroundColor =  colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            storyHide()
            checkTopTab = "trending"
            
        default:
            break
        }
        usersStoryCollectionView.reloadData()
        playerItemList = []
        newsFeedListArray = []
        newsFeedTblView.reloadData()
        listPageCount = 1
        homeListApi {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                if self != nil {
                    if self!.newsFeedListArray.count > 0 {
                        self!.currentAutoPlayCellIdx = IndexPath(row: 0, section: 0)
                    }
                }
                
            }
        }
        
    }
}

