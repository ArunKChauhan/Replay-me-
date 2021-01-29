//
//  PepopleMayKnowViewController.swift
//  ReplayMe
//
//  Created by Krishna on 03/06/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class PepopleMayKnowViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NVActivityIndicatorViewable {
    @IBOutlet var tblView: UITableView!
    var peopleListArray: [Any] = []
    var followRequestArray: [Any] = []
     var activityArray: [Any] = []
     var peopleMayKnowArray: [Any] = []
    var sectionArray: [String] = []
    
    
    @IBOutlet var cameraBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "CustomSectionHeader", bundle: nil)
            self.tblView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        
        let cellNib = UINib(nibName: "PeopleFollowRequestCell", bundle: nil)
                  self.tblView.register(cellNib, forCellReuseIdentifier: "follow")
        
        let cellNib2 = UINib(nibName: "PeopleActivitiesCell", bundle: nil)
              self.tblView.register(cellNib2, forCellReuseIdentifier: "pepopleId")
      
        let cellNib3 = UINib(nibName: "PeopleMayKnowCell", bundle: nil)
                  self.tblView.register(cellNib3, forCellReuseIdentifier: "tableviewcellid")
    }
   
    override func viewDidAppear(_ animated: Bool) {
        AlertListApi()
    }
    
    
    // MARK: - Service Method
    
    func AlertListApi() {
        self.startAnimating()
       
        ServiceClassMethods.AlamoRequest(method: "GET", serviceString: appConstants.kAlertList, parameters: nil) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
         
                self.sectionArray = []
                self.peopleListArray = []
            let followRequestArray = (dict[ "followRequest"] as! [Any])
             let activityListArray = (dict[ "activityList"] as! [Any])
             let peopleyouknownArray = (dict[ "peopleyouknown"] as! [Any])
            if ([followRequestArray.count] != [0]){
            self.peopleListArray.append(followRequestArray)
                self.sectionArray.append("Follow Request")
            }
             if ([activityListArray.count] != [0]){
             self.peopleListArray.append(activityListArray)
             self.sectionArray.append("Activities")
            }
             if ([peopleyouknownArray.count] != [0]){
        self.peopleListArray.append(peopleyouknownArray)
            self.sectionArray.append("People you may know")
                }
                self.tblView.reloadData()
            }
            
            }
            
        }
    
     override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         
         if UIDevice.current.orientation.isLandscape {
             print("Landscape")
             DispatchQueue.main.async {
                 self.cameraBtn.setImage(UIImage(named: "cameral.png"), for: .normal)
               
             }
         } else {
             print("Portrait")
             DispatchQueue.main.async {
                 self.cameraBtn.setImage(UIImage(named: "video-camera.png"), for: .normal)
                
             }
    
         }
         
     }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
       {
          let headerTitleStr = sectionArray[indexPath.section]
        if headerTitleStr == "Follow Request"{
           return 80
        }else if headerTitleStr == "Activities"{
            return  84
        }else if headerTitleStr == "People you may know"{
            return  80
        }
         return 55
       }
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
           return (peopleListArray[section] as! [Any]).count;

        }
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.sectionArray.count
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
          let headerTitleStr = sectionArray[indexPath.section]
        if headerTitleStr == "Follow Request"{
            let  cell = tblView.dequeueReusableCell(withIdentifier: "follow") as! PeopleFollowRequestCell
            
            followRequestArray = peopleListArray[indexPath.section] as! [Any];
            let detailDict = followRequestArray[indexPath.row] as! [String:Any];
            cell.userNameLbl.text = detailDict["name"] as? String;
        cell.userImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((detailDict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
            cell.confirmBtn.tag = indexPath.row
               cell.confirmBtn.addTarget(self, action: #selector(confirmBtn), for: .touchUpInside)
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(deletBtn), for: .touchUpInside)
            
            return cell
        }
        else if headerTitleStr == "Activities"{
            let cell = tblView.dequeueReusableCell(withIdentifier: "pepopleId") as! PeopleActivitiesCell
            activityArray = peopleListArray[indexPath.section] as! [Any];
            let detailDict = activityArray[indexPath.row] as! [String:Any];
            
        cell.userNameLbl.text = detailDict["name"] as? String;
        cell.userImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((detailDict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
            cell.mesgLbl.text =  detailDict["message"] as? String;
             let dateStringUTC = (detailDict["date"] as? String)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let yourDate = dateFormatter.date(from: dateStringUTC)!
                let hoursAgo = yourDate.timeAgoSinceDate()
            cell.timeLbl.text = hoursAgo
              return cell
        }
        else if headerTitleStr == "People you may know"{
            let  cell  = tblView.dequeueReusableCell(withIdentifier: "tableviewcellid") as! PeopleMayKnowCell
        peopleMayKnowArray = peopleListArray[indexPath.section] as! [Any];
            let detailDict = peopleMayKnowArray[indexPath.row] as! [String:Any];
            
            cell.userNameLbl.text = detailDict["name"] as? String;
        cell.userImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((detailDict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
            cell.followBtnLbl.tag = indexPath.row
            cell.followBtnLbl.addTarget(self, action: #selector(followBtn), for: .touchUpInside)
            
              return cell
        }

        return UITableViewCell()
    }
      func tableView(_ tableView: UITableView, didSelectRowAt
     indexPath: IndexPath){
   let headerTitleStr = sectionArray[indexPath.section]
         if headerTitleStr == "Follow Request"{
    let detailDict = followRequestArray[indexPath.row] as! [String:Any];
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
        secondViewController.userIdStr = (detailDict["_id"] as? String)!;
        self.navigationController?.pushViewController(secondViewController, animated: true)
            
            
         }else if headerTitleStr == "People you may know"{
       let detailDict = peopleMayKnowArray[indexPath.row] as! [String:Any];
               let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
           secondViewController.userIdStr = (detailDict["_id"] as? String)!;
  self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        
        let header = self.tblView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! CustomSectionHeader
             let internalArray = peopleListArray[section] as! [Any];
      
        if internalArray.count == 1{
            header.expendButton.isHidden = true
        }
        else{
            header.expendButton.isHidden = false
        }
          let checkData = sectionArray[section]
        header.orderNoLbl?.text = checkData
          header.expendButton.tag = section
         header.expendButton.addTarget(self, action: #selector(viewAll), for: .touchUpInside)
   
        return header
    }
      @objc func viewAll(button: UIButton) {
        print("krishna")
         let section = button.tag
          let headerTitleStr = sectionArray[section]
       let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoreListViewController") as! MoreListViewController
        vc.checkSectionString = headerTitleStr; self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    @objc func confirmBtn(button: UIButton)  {
            let section = button.tag
      let detailDict = followRequestArray[section] as! [String:Any];
        print(detailDict)
        
    self.startAnimating()
        let para = ["userId": detailDict["_id"] as! String]
    ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kAcceptFollowRequest, parameters: para) { (dict) in
        print(dict)
        self.stopAnimating()
        let status = dict["status"] as? String
        if(status == "true"){
     self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            self.AlertListApi()
        }
        else
        {
        self.stopAnimating()
            self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
        }
    }
                
    }
    @objc func deletBtn(button: UIButton)  {
            let section = button.tag
      let detailDict = followRequestArray[section] as! [String:Any];
        print(detailDict)
        
    self.startAnimating()
        let para = ["userId": detailDict["_id"] as! String, "type": "receiver"]
    ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kDeletFollowRequest, parameters: para) { (dict) in
        print(dict)
        self.stopAnimating()
        let status = dict["status"] as? String
        if(status == "true"){
     self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            self.AlertListApi()
        }
        else
        {
        self.stopAnimating()
            self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
        }
    }
                
            
    }

    @objc func followBtn(button: UIButton)  {
            let section = button.tag
      let detailDict = peopleMayKnowArray[section] as! [String:Any];
        print(detailDict)
    self.startAnimating()
        let para = ["userId": detailDict["_id"] as! String]
    ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kFollowUser, parameters: para) { (dict) in
        print(dict)
        self.stopAnimating()
        let status = dict["status"] as? String
        if(status == "true"){
     self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            self.AlertListApi()
        }
        else
        {
        self.stopAnimating()
            self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
        }
    }
                
            
    }
    
    @IBAction func draftBtnClciked(_ sender: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DraftViewController") as! DraftViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
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
    
    @IBAction func profileBtnClicked(_ sender: Any) {
     let playerVc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
           
     self.navigationController?.pushViewController(playerVc, animated: false)
      }
}
