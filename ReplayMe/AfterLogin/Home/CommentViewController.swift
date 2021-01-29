//
//  CommentViewController.swift
//  ReplayMe
//
//  Created by Core Techies on 02/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import SDWebImage
class CommentViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,NVActivityIndicatorViewable {
    @IBOutlet weak var commentTxtField: PaddedTextField!
    var commentListArray: [Any] = []
    var newsFeedsIdStr: String = ""
    
    @IBOutlet weak var commentTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        CommentListApi()
    }
    // MARK: - Service Method
    
    func CommentListApi() {
        
        self.startAnimating()
        let para = ["newsFeedsId":newsFeedsIdStr]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kCommentList, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
                if (dict["data"]) != nil
                {
                    self.commentListArray  = (dict[ "data"] as! [Any])
                    if ([self.commentListArray.count] != [0]){
                        
                        self.commentTblView.reloadData()
        
                        
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
    // MARK: - UITableViewDelegate Method

    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentListArray.count
       }
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTblCell", for: indexPath) as? CommentTblCell else { return UITableViewCell()
               }
  let userCommentDict = commentListArray[indexPath.row] as! NSDictionary
        
        cell.commentLbl.text = ((userCommentDict as AnyObject).object(forKey: "comment") as! String?)!
        let userDetail  = ((userCommentDict as AnyObject).object(forKey: "userdetails") as! NSDictionary?)
                    cell.userNameLbl.text = String(format: "%@ %@",((userDetail as AnyObject).object(forKey: "firstName") as! String?)!,((userDetail as AnyObject).object(forKey: "lastName") as! String?)!)
                   cell.userImg.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
        let dateStringUTC = (userCommentDict["createdDate"] as? String)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let yourDate = dateFormatter.date(from: dateStringUTC)!
        let hoursAgo = yourDate.timeAgoSinceDate()
      
    cell.commentTimeLbl.text = hoursAgo
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let userCommentDict = commentListArray[indexPath.row] as! NSDictionary
              
         let checkLike = ((userCommentDict as AnyObject).object(forKey: "likes") as! Int?)!
        let likeAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            let para = ["commentId": ((userCommentDict as AnyObject).object(forKey: "_id") as! String?)!]
            print (para)
            self.startAnimating()
            ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kCommentLike, parameters: para as [String : Any]) { (dict) in
                print(dict)
                self.stopAnimating()
                let status = dict["status"] as? String
                if(status == "true"){
                    
                  self.ShowBanner(title: "", subtitle:(dict["message"] as? String)!)
                    self.commentListArray = []
                    self.CommentListApi()
                }
                else
                {
                    self.stopAnimating()
                    self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                    
                }
            }
                success(true)
            })
        if checkLike == 0{
        likeAction.image = UIImage(named: "heartc.png")
        }
        else{
          likeAction.image = UIImage(named: "heart_likedc.png")
        }
         likeAction.backgroundColor = #colorLiteral(red: 0.0431372549, green: 0.07058823529, blue: 0.1019607843, alpha: 1)
        
        let   loginUserDetail = UserDefaults.standard.value(forKey: "userDetailDict") as! NSDictionary;
               let loginUserId =  loginUserDetail["_id"] as! String
        let dataDic1 = self.commentListArray[indexPath.row] as! [String:Any]
              let userDetail  = ((dataDic1 as AnyObject).object(forKey: "userdetails") as! NSDictionary?)
          if loginUserId == ((userDetail as AnyObject).object(forKey: "_id") as! String?)!{
            let deleteAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

              let para = ["commentId": ((userCommentDict as AnyObject).object(forKey: "_id") as! String?)!]
              print (para)
              self.startAnimating()
              ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kCommentdelet, parameters: para as [String : Any]) { (dict) in
                  print(dict)
                  self.stopAnimating()
                  let status = dict["status"] as? String
                  if(status == "true"){
                      
                    self.ShowBanner(title: "", subtitle:(dict["message"] as? String)!)
                      self.commentListArray = []
                      self.CommentListApi()
                  }
                  else
                  {
                      self.stopAnimating()
                      self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                      
                  }
              }

                                success(true)
                            })

                        deleteAction.image = UIImage(named: "cancel.png")
                        deleteAction.backgroundColor = #colorLiteral(red: 0.0431372549, green: 0.07058823529, blue: 0.1019607843, alpha: 1)

                  return UISwipeActionsConfiguration(actions: [deleteAction,likeAction])
        }
      return UISwipeActionsConfiguration(actions: [likeAction])
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func commentBtnClicked(_ sender: Any) {
        
        if commentTxtField.text == ""{
            return
        }
        self.startAnimating()
        let para = ["newsFeedsId":newsFeedsIdStr,"comment":commentTxtField.text!]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kAddComment, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
            
            self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.commentTxtField.text = nil
              
                if (dict["data"]) != nil
                {

                    self.commentListArray = []
                    self.CommentListApi()
                    
                }
 
            }
            else
            {
                
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
            }
        }
        
    }


}

extension Date {

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "min ago" : "\(interval)" + " " + "min ago"
        }

        return "now"
    }
}
