//
//  SearchViewController.swift
//  ReplayMe
//
//  Created by Krishna on 28/04/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import MXSegmentedControl
import IQKeyboardManagerSwift

@available(iOS 13.0, *)
class SearchViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NVActivityIndicatorViewable,UITextFieldDelegate {
     @IBOutlet var tabCameraBtn: UIButton!
    @IBOutlet weak var segmentedControl: MXSegmentedControl!
    @IBOutlet var topSearchCollectionView: UICollectionView!
    @IBOutlet var searchTxtField: UITextField!
      let appDel = UIApplication.shared.delegate as! AppDelegate
    var label = UILabel()
    var headerMoreBtn = UIButton()
   // var topListDataArray: [Any] = []
    var topUserListDataArray: [Any] = []
    var userListDataArray: [Any] = []
    var hashtagListDataArray: [Any] = []
    var videoListDataArray: [Any] = []
    var sectionArray: [String] = []
    var checkTabIndex: Int = 0
    var apiUrlStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmenterLoad()
        customeCellRegisterd()
    //searchListApi(searchKey: "A")
        if searchTxtField.text == ""{
        segmentedControl.isHidden = true
        }
          UserDefaults.standard.set("", forKey: "search")
        let searchVc = storyboard!.instantiateViewController(withIdentifier: "SearchListController") as! SearchListController
        self.navigationController?.pushViewController(searchVc, animated: false)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        searchTxtField.delegate = self
    }
    //MARK: - CustomeCellRegisterd Methods
    func customeCellRegisterd()  {
        topSearchCollectionView?.register(UINib.init(nibName: "ListeUserCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ListeUserCollectionCell")
        topSearchCollectionView?.register(UINib.init(nibName: "GridVideoCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GridVideoCollectionCell")
        topSearchCollectionView?.register(UINib.init(nibName: "ListHashTagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ListHashTagCollectionCell")
        self.topSearchCollectionView?.register(HeaderCollectionViewCell.self,forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,withReuseIdentifier: "HeaderCollectionViewCell")
       // IQKeyboardManager.shared.enableAutoToolbar = false
         // IQKeyboardManager.shared.enable = false
    }
    //MARK: - segmenterLoad Methods
    func segmenterLoad(){
        segmentedControl.append(title: "Top")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        segmentedControl.append(title: "Users")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
        segmentedControl.append(title: "Hashtags")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
        segmentedControl.append(title: "Videos")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
        segmentedControl.addTarget(self, action: #selector(changeIndex(segmentedControl:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        DispatchQueue.main.async {
        self.appDel.orientationLock = .all
        if let searchText =  UserDefaults.standard.string(forKey: "search")
        {
            self.searchListApi(searchKey:searchText)
            self.searchTxtField.text = searchText
            }
                 
             }
         
    }
    // MARK: - Service Method
    
    func searchListApi(searchKey:String) {
       
        segmentedControl.isHidden = false
       
        if checkTabIndex == 0{
         apiUrlStr = appConstants.kSearchTopList
        }
        else if checkTabIndex == 1{
        apiUrlStr = appConstants.kSearchUserList
        }else if checkTabIndex == 2{
        apiUrlStr = appConstants.kSearcHashtagList
        }else if checkTabIndex == 3{
         apiUrlStr = appConstants.kSearcVideoList
        }
        
        self.startAnimating()
        let para = ["keyword": searchKey]
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: apiUrlStr, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
            if self.checkTabIndex == 0{
                self.topUserListDataArray = []
                self.sectionArray = []
            let userDataArray = (dict[ "userData"] as! [Any])
             let hashtagDataArray = (dict[ "hashtagData"] as! [Any])
             let videoDataArray = (dict[ "videoData"] as! [Any])
            if ([userDataArray.count] != [0]){
                self.topUserListDataArray.append(userDataArray)
                self.sectionArray.append("Users")
            }
             if ([hashtagDataArray.count] != [0]){
             self.topUserListDataArray.append(hashtagDataArray)
             self.sectionArray.append("Hashtags")
            }
             if ([videoDataArray.count] != [0]){
            self.topUserListDataArray.append(videoDataArray)
            self.sectionArray.append("Videos")
                }
                
            }
            else if self.checkTabIndex == 1{
                
                self.userListDataArray = (dict[ "data"] as! [Any])
                }
            else if self.checkTabIndex == 2 {
            self.hashtagListDataArray = (dict[ "data"] as! [Any])
                }
            else if self.checkTabIndex == 3{
                self.videoListDataArray = (dict[ "videoData"] as! [Any])
                }
        self.topSearchCollectionView.reloadData()
            }
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
        self.userListDataArray = []
        self.topUserListDataArray = []
       self.hashtagListDataArray = []
      self.videoListDataArray = []
                //self.tableView.reloadData()
    self.topSearchCollectionView.reloadData()
            }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
       
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
                topSearchCollectionView.reloadData()
                  self.tabCameraBtn.setImage(UIImage(named: "cameral.png"), for: .normal)
              
            } else {
                print("Portrait")
                   topSearchCollectionView.reloadData()
                   self.tabCameraBtn.setImage(UIImage(named: "video-camera.png"), for: .normal)
          
            }
       
    }


    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let dataStr = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if dataStr != ""{
        searchListApi(searchKey:dataStr!)
        }else{
              UserDefaults.standard.set("", forKey: "search")
            self.view.endEditing(true)
      let searchVc = storyboard!.instantiateViewController(withIdentifier: "SearchListController") as! SearchListController
            self.navigationController?.pushViewController(searchVc, animated: false)
        }
        return true
    }
    //MARK: - collectionView Delegte Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if checkTabIndex == 0{
              if ([topUserListDataArray.count] != [0]){
            return (topUserListDataArray[section] as! [Any]).count;
            }
        }
        else if checkTabIndex == 1{
            return userListDataArray.count
        }
        else if checkTabIndex == 2{
            return hashtagListDataArray.count
        }
        else if checkTabIndex == 3 {
            return videoListDataArray.count
        }
        return 0
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if checkTabIndex == 0{
            return self.sectionArray.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath.section)
        if checkTabIndex == 0{
            let sectionTitle  = sectionArray[indexPath.section]
           
            if sectionTitle == "Users"{
                let cell = topSearchCollectionView.dequeueReusableCell(withReuseIdentifier: "ListeUserCollectionCell", for: indexPath) as! ListeUserCollectionCell
        let topUser = topUserListDataArray[indexPath.section] as! [Any];
            let dict = topUser[indexPath.row] as! [String:Any];
                cell.nameLbl.text = String(format: "%@ %@",((dict as AnyObject).object(forKey: "firstName") as! String?)!,((dict as AnyObject).object(forKey: "lastName") as! String?)!)
                cell.userNameLbl.text = dict["userName"] as? String;
             cell.userImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((dict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                return cell
                
            }
            else if sectionTitle == "Hashtags"{
                let cell = topSearchCollectionView.dequeueReusableCell(withReuseIdentifier: "ListHashTagCollectionCell", for: indexPath) as! ListHashTagCollectionCell
         let topUser = topUserListDataArray[indexPath.section] as! [Any];
          let dict = topUser[indexPath.row] as! [String:Any];
            cell.hashtagUserNameLbl.text = dict["hashtagName"] as? String;
                let videoCount = (dict["count"] as? Int)
                cell.totalPosts!.text = "\(videoCount!) posts"
              
                return cell
                
            }
            else {
                let cell = topSearchCollectionView.dequeueReusableCell(withReuseIdentifier: "GridVideoCollectionCell", for: indexPath) as! GridVideoCollectionCell
    let topUser = topUserListDataArray[indexPath.section] as! [Any];
    let dict = topUser[indexPath.row] as! [String:Any];
   cell.videoThombImg.sd_setImage(with: URL(string: (((dict as AnyObject).object(forKey: "videoScreenShotUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
        let videoCount = (dict["likes"] as? Int)
        cell.totalLikeLbl!.text = "\(videoCount!)"
        let userDetail  = ((dict as AnyObject).object(forKey: "profiledetails") as! NSDictionary?)
        cell.userNameLbl.text =  ((userDetail as AnyObject).object(forKey: "userName") as! String?)!
    cell.profileImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                
                return cell
            }
        }
        else if checkTabIndex == 1{
            let cell = topSearchCollectionView.dequeueReusableCell(withReuseIdentifier: "ListeUserCollectionCell", for: indexPath) as! ListeUserCollectionCell
            
            let dict = userListDataArray[indexPath.row] as! [String:Any];
        cell.nameLbl.text = String(format: "%@ %@",((dict as AnyObject).object(forKey: "firstName") as! String?)!,((dict as AnyObject).object(forKey: "lastName") as! String?)!)
       cell.userNameLbl.text = dict["userName"] as? String;
    cell.userImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((dict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
            
            return cell
            
        }
        else if checkTabIndex == 2{
            let cell = topSearchCollectionView.dequeueReusableCell(withReuseIdentifier: "ListHashTagCollectionCell", for: indexPath) as! ListHashTagCollectionCell
            let dict = hashtagListDataArray[indexPath.row] as! [String:Any];
            cell.hashtagUserNameLbl.text = dict["hashtagName"] as? String;
            let videoCount = (dict["count"] as? Int)
             cell.totalPosts!.text = "\(videoCount!) posts"
            return cell
        }
        else if checkTabIndex == 3 {
            let cell = topSearchCollectionView.dequeueReusableCell(withReuseIdentifier: "GridVideoCollectionCell", for: indexPath) as! GridVideoCollectionCell
             let dict = videoListDataArray[indexPath.row] as! [String:Any];
            cell.videoThombImg.sd_setImage(with: URL(string: (((dict as AnyObject).object(forKey: "videoScreenShotUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
              let videoCount = (dict["likes"] as? Int)
                cell.totalLikeLbl!.text = "\(videoCount!)"
                let userDetail  = ((dict as AnyObject).object(forKey: "profiledetails") as! NSDictionary?)
                cell.userNameLbl.text =  ((userDetail as AnyObject).object(forKey: "userName") as! String?)!
            cell.profileImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
            return cell
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = topSearchCollectionView.frame.width
        if checkTabIndex == 0 {
            let sectionTitle  = sectionArray[indexPath.section]
                
            if sectionTitle == "Users" || sectionTitle == "Hashtags" {
                return CGSize(width: width, height: 61)
            }else {
                return CGSize(width: (width - 15)/2, height: (width - 15)/2)
            }
        }
        else if checkTabIndex == 1 || checkTabIndex == 2{
            return CGSize(width: width, height: 61)
            
        }
        else if checkTabIndex == 3{
            return CGSize(width: (width - 15)/2, height: (width - 15)/2)
        }
        return CGSize(width: width, height: 61)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if checkTabIndex == 0{
            
            return CGSize(width: collectionView.bounds.width, height: 60)
        }
        return CGSize(width: 0, height: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionViewCell", for: indexPath) as! HeaderCollectionViewCell
            
              headerView.subviews.forEach { $0.removeFromSuperview() }
           // var bounds = UIScreen.main.bounds
            //var width = bounds.size.width
            label = UILabel(frame: CGRect(x: 16, y: 15, width: 80, height: 25))
            headerMoreBtn = UIButton(frame: CGRect(x: collectionView.bounds.width - 100, y: 15, width: 80, height: 25))
           // headerMoreBtn.title(for: UIControl.State)
            headerMoreBtn.setTitle("More >", for: .normal)
            headerMoreBtn.setTitleColor(#colorLiteral(red: 0.6039215686, green: 0.6705882353, blue: 0.7647058824, alpha: 1), for: .normal)
            headerMoreBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            headerView.addSubview(headerMoreBtn)
            let sectionTitle  = sectionArray[indexPath.section]
             if sectionTitle == "Users"{
                label.text = ""
                label.text = "Users"
                label.font = UIFont.boldSystemFont(ofSize: 22)
                label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                headerView.addSubview(label)
                
            }
            else if sectionTitle == "Hashtags"{
                
                label = UILabel(frame: CGRect(x: 16, y: 15, width: headerView.frame.width, height: 25))
                label.text = "Hashtags"
                label.font = UIFont.boldSystemFont(ofSize: 22)
                label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                headerView.addSubview(label)
                
            }
            else if sectionTitle == "Videos"{
          
                label.text = "Videos"
                label.font = UIFont.boldSystemFont(ofSize: 22)
                label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                headerView.addSubview(label)
            }
            headerMoreBtn.tag = indexPath.section
            headerMoreBtn.addTarget(self, action: #selector(performTask), for: .touchUpInside)
            return headerView
        }
        
        fatalError("Unexpected element kind")
    }
    @objc func performTask(sender:UIButton){
         let sectionTitle  = sectionArray[sender.tag]
        if sectionTitle == "Users"{
       segmentedControl?.select(index:1, animated: true)
        }
        else if sectionTitle == "Hashtags"{
           segmentedControl?.select(index:2, animated: true)
        }
        else if sectionTitle == "Videos"{
            segmentedControl?.select(index:3, animated: true)
        }
       
    }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
       if checkTabIndex == 0 {
        
         let sectionTitle  = sectionArray[indexPath.section]
        let topUser = topUserListDataArray[indexPath.section] as! [Any];
        let dict = topUser[indexPath.row] as! [String:Any];
        print(dict)
        
         if sectionTitle == "Users"{
            
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
            secondViewController.userIdStr = (dict["_id"] as? String)!;
      self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        if sectionTitle == "Hashtags"{
            let hashtagVc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagUserViewController") as! HashtagUserViewController
            hashtagVc.hashtagUserId = (dict["_id"] as? String)!;
            hashtagVc.hashTagUserName = (dict["hashtagName"] as? String)!;
            self.navigationController?.pushViewController(hashtagVc, animated: true)
        }
        if sectionTitle == "Videos"{
         let hashtagVc = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserVideoViewController") as! OtherUserVideoViewController
            hashtagVc.playerDetailDict = dict as [String : AnyObject]
            self.navigationController?.pushViewController(hashtagVc, animated: true)
        }
        }
        else if checkTabIndex == 1{
          let dict = userListDataArray[indexPath.row] as! [String:Any];
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
            secondViewController.userIdStr = (dict["_id"] as? String)!;
        self.navigationController?.pushViewController(secondViewController, animated: true)
            
        }
       else if checkTabIndex == 2{
         let dict = hashtagListDataArray[indexPath.row] as! [String:Any];
        let hashtagVc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagUserViewController") as! HashtagUserViewController
            hashtagVc.hashtagUserId = (dict["_id"] as? String)!;
            hashtagVc.hashTagUserName = (dict["hashtagName"] as? String)!;
            self.navigationController?.pushViewController(hashtagVc, animated: true)
        
        }
        else if checkTabIndex == 3{
                let dict = videoListDataArray[indexPath.row] as! [String:Any];
                 let hashtagVc = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserVideoViewController") as! OtherUserVideoViewController
                      hashtagVc.playerDetailDict = dict as [String : AnyObject]
                      self.navigationController?.pushViewController(hashtagVc, animated: true)
               
               }

       
    }
    //MARK: - Button Action Methods
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func searchBtnClicked(_ sender: Any) {
        let searchVc = storyboard!.instantiateViewController(withIdentifier: "SearchListController") as! SearchListController
        searchVc.modalPresentationStyle = .fullScreen
        searchVc.delegate = self
        self.present(searchVc, animated: true, completion: nil)
        
    }
    @IBAction func homeTabBtnClicked(_ sender: Any) {
//        self.navigationController?.popViewController(animated: false)
        let dashboardVC = navigationController!.viewControllers.filter { $0 is HomeViewController }.first!
    navigationController!.popToViewController(dashboardVC, animated: false)
    }
    @IBAction func cameraTabBtnClicke(_ sender: Any) {
        DispatchQueue.main.async {
              let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
              self.navigationController?.pushViewController(cameraVC, animated: false)
          }
    }
    @IBAction func bellTabBtnClicked(_ sender: Any) {
        DispatchQueue.main.async {
                      
                      let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PepopleMayKnowViewController") as! PepopleMayKnowViewController
                      self.navigationController?.pushViewController(secondViewController, animated: false)
                  }
    }
    @IBAction func profileTabBtnClicked(_ sender: Any) {
        let hashtagVc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
self.navigationController?.pushViewController(hashtagVc, animated: false)
    }
    
    
}



@available(iOS 13.0, *)
extension SearchViewController {
    
    //MARK: - MXSegmentedControl Methods
    @objc func changeIndex(segmentedControl: MXSegmentedControl) {
        
        switch segmentedControl.selectedIndex {
        case 0:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            checkTabIndex = 0
           searchListApi(searchKey:searchTxtField.text!)
        case 1:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            checkTabIndex = 1
            searchListApi(searchKey:searchTxtField.text!)
        case 2:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            checkTabIndex = 2
           searchListApi(searchKey:searchTxtField.text!)
        case 3:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            checkTabIndex = 3
            searchListApi(searchKey:searchTxtField.text!)
            
        default:
            break
        }
    }
}
@available(iOS 13.0, *)
extension SearchViewController: CustomAlertViewDelegate {
    
    func okButtonTapped(textFieldValue: String) {
        print("TextField has value: \(textFieldValue)")
        searchTxtField.text = textFieldValue
        searchListApi(searchKey:textFieldValue)
        
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}
