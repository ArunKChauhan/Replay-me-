//
//  HashtagUserViewController.swift
//  ReplayMe
//
//  Created by Krishna on 05/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class HashtagUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NVActivityIndicatorViewable {
    
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    var hashtagUserId: String = ""
    var hashTagUserName: String = ""
     var hashtagArray: [Any] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLbl.text = hashTagUserName
        hashtagListApi()
    }
    func hashtagListApi() {
        
        self.startAnimating()
        let para = ["hashtagId":hashtagUserId]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kHashtagUser, parameters: para) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                if (dict["data"]) != nil
                {
                    self.hashtagArray  = (dict[ "data"] as! [Any])
                    if ([self.hashtagArray.count] != [0]){
                        self.collectionView.reloadData()
                        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.size.width - 20) / 2
        
        
        return CGSize(width: width, height: 159)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return hashtagArray.count
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashTagCollectionViewCell", for: indexPath) as! HashTagCollectionViewCell
        let hashtagDict = hashtagArray[indexPath.row] as! NSDictionary
        cell.contentLbl.text = ((hashtagDict as AnyObject).object(forKey: "content") as! String?)!
        let viewsCount = ((hashtagDict as AnyObject).object(forKey: "views") as! Int?)!
        cell.viewsLbl.text = "\(viewsCount) views"
      cell.videoThumbImg.sd_setImage(with: URL(string: (((hashtagDict as AnyObject).object(forKey: "videoScreenShotUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
 
        return cell
    }
//    private func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
//

//    }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
               // let detailDict = ["videoScreenShotUrl": tappedCell.videoScreenShotUrl,"videoUrl":tappedCell.videoUrl,"views": tappedCell.views,"content": tappedCell.content ,"_id": tappedCell._id]
            let hashtagDict = hashtagArray[indexPath.row] as! NSDictionary
        // let viewsCount = ((hashtagDict as AnyObject).object(forKey: "views") as! Int?)!
        //let detailDict = ["videoScreenShotUrl":((hashtagDict as AnyObject).object(forKey: "videoScreenShotUrl") as! String?)!, "videoUrl": ((hashtagDict as AnyObject).object(forKey: "videoUrl") as! String?)!,"views": "\(viewsCount)","content": ((hashtagDict as AnyObject).object(forKey: "content") as! String?), ""   ]
                   let playerVc = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserVideoViewController") as! OtherUserVideoViewController
        playerVc.playerDetailDict = hashtagDict as! [String : AnyObject]
                self.navigationController?.pushViewController(playerVc, animated: true)
    
       
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
