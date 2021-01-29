//
//  SearchListController.swift
//  ReplayMe
//
//  Created by Krishna on 29/04/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@available(iOS 13.0, *)
class SearchListController: UIViewController,UITableViewDelegate, UITableViewDataSource,NVActivityIndicatorViewable,UITextFieldDelegate,CollectionViewCellDelegates {
    
  var delegate: CustomAlertViewDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchTxtField: UITextField!
    @IBOutlet var draftBtn: UIButton!
    
 var tappedCell: CollectionViewCellModel!
  var modelArr = [TableViewCellModel]()
  var serachListArray: [Any] = []
 @IBOutlet var tabCameraBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
     // IQKeyboardManager.shared.enable = false
    IQKeyboardManager.shared.enableAutoToolbar = false
        searchTxtField.delegate = self
        tableView.dataSource = self
    }
        override func viewDidAppear(_ animated: Bool) {
            tableView.separatorStyle = .none
              self.view.endEditing(true)
            
            // Register the xib for tableview cell
            let cellNib = UINib(nibName: "TrendingVideoCell", bundle: nil)
            self.tableView.register(cellNib, forCellReuseIdentifier: "tableviewcellid")
            //tableView.backgroundColor = .clear
      searchListApi()
            
        }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
             if UIDevice.current.orientation.isLandscape {
                 print("Landscape")
             
                   self.tabCameraBtn.setImage(UIImage(named: "cameral.png"), for: .normal)
               
             } else {
                 print("Portrait")
           
                    self.tabCameraBtn.setImage(UIImage(named: "video-camera.png"), for: .normal)
           
             }
        
     }
    // MARK: - Service Method
    
    func searchListApi() {
        
        self.startAnimating()
       // let para = ["keyword":""]
        ServiceClassMethods.AlamoRequest(method: "Get", serviceString: appConstants.kTrendingVideoList, parameters: nil) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            
            if(status == "true"){
                if (dict["data"]) != nil
                {
          let dataArrar  = (dict[ "data"] as! [Any])
            var innerArr = [CollectionViewCellModel]()
                     self.modelArr = []
                    for i in 0..<dataArrar.count {
        let DetailDict = dataArrar[i] as! NSDictionary
        let videoListArray = DetailDict["video"] as? [Any]
         
                        for video in videoListArray!{
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
                                                 category: DetailDict["hashtagName"] as? String ?? "",
                                                 subcategory: "\(innerArr.count)",
                                                 videos:innerArr
                                             )
                                             self.modelArr.append(item)
                   
                    }
                    self.tableView.reloadData()
           
            }
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                self.serachListArray = []
                  self.tableView.reloadData()
            }
        }
    }
    @IBAction func draftBtnClicked(_ sender: Any) {
        if draftBtn.currentImage!.isEqual(UIImage(named: "Close")) {
            //do something here
            searchTxtField.text = nil
            self.view.endEditing(true)
            draftBtn.setImage(UIImage(named: "camera1"), for: .normal)
             
        }
        else{
        let searchVc = storyboard!.instantiateViewController(withIdentifier: "DraftViewController") as! DraftViewController
            IQKeyboardManager.shared.enableAutoToolbar = true
                self.navigationController?.pushViewController(searchVc, animated: true)
            
        }
    }
    @IBAction func homeBtnClicked(_ sender: Any) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        let dashboardVC = navigationController!.viewControllers.filter { $0 is HomeViewController }.first!
               navigationController!.popToViewController(dashboardVC, animated: false)
    }
    @IBAction func cameraBtnClicked(_ sender: Any) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        DispatchQueue.main.async {
              let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
              self.navigationController?.pushViewController(cameraVC, animated: false)
          }
    }
    @IBAction func notificationBtnClicked(_ sender: Any) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        DispatchQueue.main.async {
                      
                      let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PepopleMayKnowViewController") as! PepopleMayKnowViewController
                      self.navigationController?.pushViewController(secondViewController, animated: false)
                  }
    }
    @IBAction func profileBtnClicked(_ sender: Any) {
        let searchVc = storyboard!.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
        self.navigationController?.pushViewController(searchVc, animated: false)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let dataStr = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if dataStr != ""{
          draftBtn.setImage(UIImage(named: "Close"), for: .normal)
        }else{
          draftBtn.setImage(UIImage(named: "camera1"), for: .normal)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         // your Action According to your textfield
        if searchTxtField.text != ""{
          IQKeyboardManager.shared.enableAutoToolbar = true
            UserDefaults.standard.set(searchTxtField.text!, forKey: "search")
            self.navigationController?.popViewController(animated: false)
        self.view.endEditing(true)
        }
         //textField.resignFirstResponder()
        return true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
         return modelArr.count
         // return 1
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
         // return 2
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 180
     }
    
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as? TrendingVideoCell {
            
            cell.backgroundColor = .clear
            cell.titileLbl.text = modelArr[indexPath.section].category
            let rowArray = modelArr[indexPath.section].videos
            cell.updateCellWith(row: rowArray)
            // Set cell's delegate
        cell.cellDelegate = self as? CollectionViewCellDelegates
        cell.cellDelegate = self
            
            cell.selectionStyle = .none
            return cell
           
        }
        return UITableViewCell()
    }

     func collectionView(collectionviewcell: TrendingVideoCollectionCell?, index: Int, didTappedInTableViewCell: TrendingVideoCell) {
         if let dataRow = didTappedInTableViewCell.rowWithData {
             self.tappedCell = dataRow[index]
             print(self.tappedCell as Any)
            // let data = tappedCell.content
            IQKeyboardManager.shared.enableAutoToolbar = true
             let detailDict = ["videoScreenShotUrl": tappedCell.videoScreenShotUrl,"videoUrl":tappedCell.videoUrl,"views": tappedCell.views,"content": tappedCell.content ,"_id": tappedCell._id]
             
              let playerVc = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserVideoViewController") as! OtherUserVideoViewController
         playerVc.playerDetailDict = detailDict as [String : AnyObject]
   self.navigationController?.pushViewController(playerVc, animated: true)
           
         }
     }
   
}
