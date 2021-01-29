//
//  UserFollowViewController.swift
//  ReplayMe
//
//  Created by Krishna on 12/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import MXSegmentedControl

@available(iOS 13.0, *)
class UserFollowViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,NVActivityIndicatorViewable,UITextFieldDelegate {
    
     @IBOutlet weak var segmentedControl: MXSegmentedControl!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var searchTxtField: UITextField!
    var checkTab: Int = 0
    var followingListArray: [Any] = []
    var checkTabApi: String = ""
    var commonArray: [Any] = []
    var sortArray: [Any] = []
    var checkIndexPath = IndexPath()
    var userIdStrig : String = ""
    var checkController: String = ""
   var updateFriendStatusDict = [String:AnyObject]()
    
    @IBOutlet var navigationTitle: UILabel!
    var navTitleStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        navigationTitle.text = navTitleStr
      segmenterLoad()
     
    }
    
    //MARK: - segmenterLoad Methods
    func segmenterLoad(){
        //segmentedControl.selectedIndex = 0
        segmentedControl.append(title: "Following")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        
        segmentedControl.append(title: "Followers")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
        segmentedControl.addTarget(self, action: #selector(changeIndex(segmentedControl:)), for: .valueChanged)
        print(checkTab)
        segmentedControl?.select(index:checkTab, animated: true)
        
        
    }
    // MARK: - Service Method
    
    func followersListApi() {
    
        if checkTab == 0 {
            checkTabApi = appConstants.kFollowingList
        }
        else{
            checkTabApi = appConstants.kFollowersList
        }
        
        self.startAnimating()
        let para = ["userId": userIdStrig]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: checkTabApi, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            self.followingListArray = []
            self.commonArray = []
            if(status == "true"){
                if (dict["data"]) != nil
                {
                    self.followingListArray  = (dict[ "data"] as! [Any])
                    if ([self.followingListArray.count] != [0]){
                        self.commonArray = self.followingListArray
                        self.tblView.reloadData()
                    }
                    else{
                        self.followingListArray = []
                        self.commonArray = []
                        self.tblView.reloadData()
                    }
                }
                else{
                    self.followingListArray = []
                    self.commonArray = []
                    self.tblView.reloadData()
                }

            }
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        sortArray.removeAll()
        let dataStr = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        let searchStr = dataStr?.capitalized
        for i in 0..<followingListArray.count {
            let dic = followingListArray[i] as? [AnyHashable : Any]
            let title = dic?["name"] as? String
            let titleCaps = title?.capitalized
            if titleCaps?.contains(searchStr ?? "") ?? false
            {
                if let aDic = dic
                {
                    sortArray.append(aDic)
                }
            }
        }
        if (searchStr?.count ?? 0) == 0 {
            commonArray = followingListArray
        } else {
            commonArray = sortArray
        }
        tblView.reloadData()
        return true
    }

      // MARK: - UITableViewDelegate Method
      
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
       {
          
               return 62
  
       }
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commonArray.count
        
    }
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
      
        if checkTab == 0{

          guard let cell = tableView.dequeueReusableCell(withIdentifier: "following", for: indexPath) as? FollowUserCell else { return UITableViewCell()
          }
            let followingDict = commonArray[indexPath.row] as! NSDictionary
        cell.followingUserName.text = ((followingDict as AnyObject).object(forKey: "name") as! String?)!
        cell.followingProfileImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((followingDict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
            let status = ((followingDict as AnyObject).object(forKey: "status") as! String?)!
             if checkController == "otherProfile"{
                if status == "follow"{
            cell.followingBtn.setTitle("Follow", for: .normal)
                
                }else if status == "unfollow"{
                cell.followingBtn.setTitle("Following", for: .normal)
                 
                }else if status == "send"{
                cell.followingBtn.setTitle("Requested", for: .normal)
                    
                }else if status == "requested"{
               cell.followingBtn.setTitle("Requested", for: .normal)
                    
                }else if status == "followback"{
              cell.followingBtn.setTitle("Follow back", for: .normal)
                }else if status == "block"{
                cell.followingBtn.setTitle("Unblock", for: .normal)
                }
            cell.followingBtn?.tag = indexPath.row
            cell.followingBtn?.addTarget(self, action: #selector(otherUserFollowBtn), for: .touchUpInside)
            }
             else{
             if status == "follow"{
                         print("unfollow unfollow-user api")
                          cell.followingBtn.setTitle("Follow", for: .normal)
                cell.followingBtn?.addTarget(self, action: #selector(followingBtn), for: .touchUpInside)

                     }
             else if status == "following"{
                
                 cell.followingBtn.setTitle("Following", for: .normal)
                cell.followingBtn?.tag = indexPath.row
                    cell.followingBtn?.addTarget(self, action: #selector(followingBtn), for: .touchUpInside)
                
                }
                else if status == "send"{
                            
                    cell.followingBtn.setTitle("Requested", for: .normal)
                    cell.followingBtn?.tag = indexPath.row
                cell.followingBtn?.addTarget(self, action: #selector(followingBtn), for: .touchUpInside)
                            
                        }
                
                   
            }
        
          return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "followers", for: indexPath) as? FollowUserCell else { return UITableViewCell()
                   }
            let followerDict = commonArray[indexPath.row] as! NSDictionary
                                  
              cell.followerUserNameLbl.text = ((followerDict as AnyObject).object(forKey: "name") as! String?)!
              cell.followerProfileImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((followerDict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
            let status = ((followerDict as AnyObject).object(forKey: "status") as! String?)!
            
            if checkController == "otherProfile"{
                     if status == "follow"{
                 cell.followerBtn.setTitle("Follow", for: .normal)
                     
                     }else if status == "unfollow"{
                     cell.followerBtn.setTitle("Following", for: .normal)
                      
                     }else if status == "send"{
                     cell.followerBtn.setTitle("Requested", for: .normal)
                         
                     }else if status == "requested"{
                    cell.followerBtn.setTitle("Requested", for: .normal)
                         
                     }else if status == "followback"{
                   cell.followerBtn.setTitle("Follow back", for: .normal)
                     }else if status == "block"{
                     cell.followerBtn.setTitle("Unblock", for: .normal)
                     }
                cell.followerBtn?.tag = indexPath.row
                cell.followerBtn?.addTarget(self, action: #selector(otherUserFollowBtn), for: .touchUpInside)
            }else{
            
                    if status == "unfollow"{
                    cell.followerBtn.setTitle("Remove", for: .normal)
                    }
            
            cell.followerBtn?.tag = indexPath.row
                      cell.followerBtn?.addTarget(self, action: #selector(followerBtn), for: .touchUpInside)
            }
                   return cell

        }
     
       return UITableViewCell()
     }
    func tableView(_ tableView: UITableView, didSelectRowAt
     indexPath: IndexPath){
        
         let   loginUserDetail = UserDefaults.standard.value(forKey: "userDetailDict") as! NSDictionary;
          let userDetailDict = commonArray[indexPath.row] as! NSDictionary
        if (userDetailDict["_id"] as? String)! != loginUserDetail["_id"] as! String{
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
                 secondViewController.userIdStr = (userDetailDict["_id"] as? String)!;
           self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
     // MARK: - Following list buttonAction
    @objc func otherUserFollowBtn(sender: UIButton){
        
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cellw = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tblView.indexPath(for: cellw) else {
            print("failed to get index path for cell containing button")
            return
        }
        print("button is in row \(indexPath.row)")
        let buttonRow = sender.tag
        let dataDic1 = self.commonArray[buttonRow] as! [String:Any]
        print(dataDic1)
        checkIndexPath = indexPath
         let status = (dataDic1["status"] as? String)!
          let checkId = (dataDic1["_id"] as? String)!
        var apiUrlStr: String = ""
        var param  = [:] as Dictionary

       if status == "follow"{
        apiUrlStr = appConstants.kFollowUser
        param = ["userId": checkId]
        }
       else if status == "unfollow"{
          apiUrlStr = appConstants.kUnFollowUser
         param = ["userId": checkId]
             }
       else if status == "send"{
            param = ["userId": checkId,"type": "sender"]
            apiUrlStr = appConstants.kDeletFollowRequest
                 
             }
       else if status == "requested"{
            param = ["userId": checkId,"type": "sender"]
            apiUrlStr = appConstants.kDeletFollowRequest
      
                 
             }
       else if status == "followback"{
         apiUrlStr = appConstants.kFollowUser
          param = ["userId": checkId]
          
             }
       else if status == "block"{
        apiUrlStr = appConstants.kUserUnblock
         param = ["unblockUserId": checkId]
            
             }
        print(param)
        print(apiUrlStr)
        print(status)
               self.startAnimating()
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: apiUrlStr, parameters: param as? [String : Any]) { (dict) in
                   print(dict)
                   self.stopAnimating()
                   let status = dict["status"] as? String
                   if(status == "true"){
                       self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                    
                 let  friendStatus = (dict["friendStatus"] as? String)!
            self.updateFriendStatusDict = self.commonArray[buttonRow] as! [String : AnyObject]
              self.updateFriendStatusDict["status"] = friendStatus as AnyObject
                    self.commonArray[buttonRow] = self.updateFriendStatusDict
                    self.tblView.reloadData()
                   }
                   else
                   {
                       self.stopAnimating()
                       self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                   }
               }
    
        
    }
    
   
    
    @objc func followingBtn(sender: UIButton)
    {
        
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tblView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        
        print("button is in row \(indexPath.row)")
        let buttonRow = sender.tag
        let dataDic1 = self.commonArray[buttonRow] as! [String:Any]
        checkIndexPath = indexPath
      
         let status = (dataDic1["status"] as? String)!
          let checkId = (dataDic1["_id"] as? String)!
     
            for index in 0..<followingListArray.count {
                
                
                
                
                let detailDict = followingListArray[index]
                let id = ((detailDict as AnyObject).object(forKey: "_id") as! String?)!
                
                if checkId == id{
                    var apiUrlStr: String = ""
                    var param  = [:] as Dictionary
                    if status == "following"{
                        apiUrlStr =  appConstants.kUnFollowUser
                        param = ["userId": checkId]
                                          
                    }
                    else if status == "follow"{
                apiUrlStr =  appConstants.kFollowUser
                param = ["userId": checkId]

                    }
                    else if status == "send"{
                    apiUrlStr =  appConstants.kDeletFollowRequest
                        param = ["userId": checkId,"type": "sender"]

                        }
                    
        self.startAnimating()
      
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: apiUrlStr, parameters: (param as! [String : Any])) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
                
        var updateStatusDict = [String:AnyObject]()
        updateStatusDict = self.commonArray[buttonRow] as! [String : AnyObject]
       let  friendRequestStatus =  dict["friendStatus"] as? String
            updateStatusDict["status"] = friendRequestStatus as AnyObject
                self.commonArray[buttonRow] = updateStatusDict
                
            self.tblView.reloadData()
         self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
                    
                }
           
            }
    }
    
     // MARK: - Follower list buttonAction
    @objc func followerBtn(sender: UIButton)
      {

          var superview = sender.superview
          while let view = superview, !(view is UITableViewCell) {
              superview = view.superview
          }
          guard let cell = superview as? UITableViewCell else {
              print("button is not contained in a table view cell")
              return
          }
          guard let indexPath = tblView.indexPath(for: cell) else {
              print("failed to get index path for cell containing button")
              return
          }
          print("button is in row \(indexPath.row)")
          let buttonRow = sender.tag
          let dataDic1 = self.commonArray[buttonRow] as! [String:Any]
          checkIndexPath = indexPath
          var updateStatusDict = [String:AnyObject]()
          updateStatusDict = self.commonArray[buttonRow] as! [String : AnyObject]
          let status = (dataDic1["status"] as? String)!
          let checkId = (dataDic1["_id"] as? String)!
          if status == "unfollow"{
              for index in 0..<followingListArray.count {
                  let detailDict = followingListArray[index]
                  let id = ((detailDict as AnyObject).object(forKey: "_id") as! String?)!
                  if checkId == id{
          self.startAnimating()
          let para = ["userId": checkId]
          ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kRemoveUser, parameters: para) { (dict) in
              print(dict)
              self.stopAnimating()
              let status = dict["status"] as? String
              
              if(status == "true"){
                  self.followingListArray.remove(at: index)
                  self.commonArray.remove(at: buttonRow)
                  self.tblView.reloadData()
           self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
              }
              else
              {
                  self.stopAnimating()
                  self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
              }
          }
                      
        }
             
              }
      }

      }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

@available(iOS 13.0, *)
extension UserFollowViewController {
    
    //MARK: - MXSegmentedControl Methods
    @objc func changeIndex(segmentedControl: MXSegmentedControl) {
        
        switch segmentedControl.selectedIndex {
        case 0:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            checkTab = 0
            searchTxtField.text = nil
            followersListApi()
        case 1:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
           checkTab = 1
            searchTxtField.text = nil
           followersListApi()
        default:
            break
        }
    }
}
