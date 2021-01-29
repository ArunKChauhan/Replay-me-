//
//  MoreListViewController.swift
//  ReplayMe
//
//  Created by Krishna on 03/06/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class MoreListViewController: UIViewController,NVActivityIndicatorViewable,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblView: UITableView!
    @IBOutlet var navTitleLbl: UILabel!
    
     var listDataArray: [Any] = []
    var checkSectionString: String = ""
    var apiStr: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

            let cellNib = UINib(nibName: "PeopleFollowRequestCell", bundle: nil)
                      self.tblView.register(cellNib, forCellReuseIdentifier: "follow")
            let cellNib2 = UINib(nibName: "PeopleActivitiesCell", bundle: nil)
                  self.tblView.register(cellNib2, forCellReuseIdentifier: "pepopleId")
            let cellNib3 = UINib(nibName: "PeopleMayKnowCell", bundle: nil)
                      self.tblView.register(cellNib3, forCellReuseIdentifier: "tableviewcellid")
        
        if checkSectionString == "Follow Request"{
            apiStr = appConstants.kFollowRequestList
        }else if checkSectionString == "Activities" {
            apiStr = appConstants.kActivityList
        }else if checkSectionString == "People you may know"{
           apiStr = appConstants.kPeopleYouKnow
        }
        navTitleLbl.text = checkSectionString
        ListApi()
    }
    
    // MARK: - Service Method
    
    func ListApi() {
        
        self.startAnimating()
        ServiceClassMethods.AlamoRequest(method: "GET", serviceString: apiStr, parameters: nil) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
                if self.checkSectionString == "Follow Request"{
                    if (dict["followRequest"]) != nil
                    {
                    self.listDataArray  = (dict[ "followRequest"] as! [Any])
                        if ([self.listDataArray.count] != [0]){
                            self.tblView.reloadData()
                        }
                    }
                }else if self.checkSectionString == "Activities" {
                    if (dict["activityList"]) != nil
                    {
                    self.listDataArray  = (dict[ "activityList"] as! [Any])
                        if ([self.listDataArray.count] != [0]){
                            self.tblView.reloadData()
                        }
                    }
                
                }else if self.checkSectionString == "People you may know"{
                    if (dict["peopleyouknown"]) != nil
                    {
                    self.listDataArray  = (dict[ "peopleyouknown"] as! [Any])
                        if ([self.listDataArray.count] != [0]){
                            self.tblView.reloadData()
                        }
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
         {
          if self.checkSectionString == "Follow Request"{
             return 80
          }else if self.checkSectionString == "Activities"{
              return  84
          }else if self.checkSectionString == "People you may know"{
              return  80
          }
           return 55
         }
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return listDataArray.count
         }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
      
    let detailDict = listDataArray[indexPath.row] as! NSDictionary
            if self.checkSectionString == "Follow Request"{
                let  cell = tblView.dequeueReusableCell(withIdentifier: "follow") as! PeopleFollowRequestCell
                cell.userNameLbl.text = detailDict["name"] as? String;
            cell.userImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((detailDict as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                
                return cell
            }
            else if self.checkSectionString == "Activities" {
                let cell = tblView.dequeueReusableCell(withIdentifier: "pepopleId") as! PeopleActivitiesCell
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
            else if self.checkSectionString == "People you may know"{
                let  cell  = tblView.dequeueReusableCell(withIdentifier: "tableviewcellid") as! PeopleMayKnowCell
                
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
   
           if checkSectionString == "Follow Request"{
            
      let detailDict = listDataArray[indexPath.row] as! [String:Any];
              let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
          secondViewController.userIdStr = (detailDict["_id"] as? String)!;
          self.navigationController?.pushViewController(secondViewController, animated: true)
              
              
           }else if checkSectionString == "People you may know"{
         let detailDict = listDataArray[indexPath.row] as! [String:Any];
                 let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "con1") as! UserViewController
             secondViewController.userIdStr = (detailDict["_id"] as? String)!;
    self.navigationController?.pushViewController(secondViewController, animated: true)
          }
      }
    @objc func confirmBtn(button: UIButton)  {
               let section = button.tag
         let detailDict = listDataArray[section] as! [String:Any];
           print(detailDict)
           
       self.startAnimating()
           let para = ["userId": detailDict["_id"] as! String]
       ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kAcceptFollowRequest, parameters: para) { (dict) in
           print(dict)
           self.stopAnimating()
           let status = dict["status"] as? String
           if(status == "true"){
        self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
               self.ListApi()
           }
           else
           {
           self.stopAnimating()
               self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
           }
       }
                   
               
       }
       @objc func followBtn(button: UIButton)  {
               let index = button.tag
         let detailDict = listDataArray[index] as! [String:Any];
           print(detailDict)
       self.startAnimating()
           let para = ["userId": detailDict["_id"] as! String]
       ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kFollowUser, parameters: para) { (dict) in
           print(dict)
           self.stopAnimating()
           let status = dict["status"] as? String
           if(status == "true"){
        self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
              // self.AlertListApi()
            self.ListApi()
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
         let detailDict = listDataArray[section] as! [String:Any];
           print(detailDict)
           
       self.startAnimating()
           let para = ["userId": detailDict["_id"] as! String, "type": "receiver"]
       ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kDeletFollowRequest, parameters: para) { (dict) in
           print(dict)
           self.stopAnimating()
           let status = dict["status"] as? String
           if(status == "true"){
        self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
               self.ListApi()
           }
           else
           {
           self.stopAnimating()
               self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
           }
       }
                   
               
       }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
