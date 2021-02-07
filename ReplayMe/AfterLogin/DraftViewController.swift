//
//  DraftViewController.swift
//  ReplayMe
//  Created by Core Techies on 04/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.


import UIKit
import MXSegmentedControl
import CoreData
import AVKit
import AVFoundation
import AWSCognito
import AWSS3
import AssetsLibrary
import Photos


@available(iOS 13.0, *)
class DraftViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,NVActivityIndicatorViewable {
    @IBOutlet weak var segmentedControl: MXSegmentedControl!
    @IBOutlet weak var draftTblView: UITableView!
    
    var list:[Any] = []
    var player:AVPlayer?
    var checkControler: Int = 0
    let appDel = UIApplication.shared.delegate as! AppDelegate
    let bucketName = "replaymedemo/StoryVideo"
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var shareVideoUrlStr: String = ""
     let thumbnailBucketName = "replaymedemo/NewsFeedVideo/output/images"
       var UploadVideoUrlStr: String = ""
    var uploadType: Int = 0
    var videoDuration: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostNewsViewController") as! PostNewsViewController
//                //secondViewController.videoUrlStr = shareVideoUrlStr
//        self.navigationController?.pushViewController(secondViewController, animated: true)
        
        
        segmentedControl.append(title: "My Drafts")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        
        segmentedControl.append(title: "Event Drafts")
            .set(titleColor: #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1), for: .selected)
        segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
        segmentedControl.addTarget(self, action: #selector(changeIndex(segmentedControl:)), for: .valueChanged)
        retrieveData()
        DispatchQueue.main.async {
            self.appDel.orientationLock = .all
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Hide the Navigation Bar
        //self.player.removeAll()
        if checkControler == 1{
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        DispatchQueue.main.async {
            self.appDel.orientationLock = .portrait
             UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//            self.appDel.orientationLock = .all
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        
    }
    // MARK: -fetch coredata base data
    func retrieveData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Store")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let arrReverse = Array(result.reversed())

            for data in arrReverse as! [NSManagedObject] {
                print(data.value(forKey: "videoClip") as! NSString)
               // list.append(data.value(forKey: "videoClip") as! NSString)
                let draftDataDict = ["videoClip":data.value(forKey: "videoClip") as! NSString, "dateTime": data.value(forKey: "dateTime") as! Double] as [String : Any]
                print(draftDataDict)
                list.append(draftDataDict)
                
                
            }
            
        } catch {
            
            print("Failed")
        }
        draftTblView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBarController?.tabBar.isHidden = true
      //  draftTblView.register(UINib(nibName: "DraftsTblCell", bundle: nil), forCellReuseIdentifier: "DraftsTblCell")
        
        
    }
    // MARK: - UITableViewDelegate Method
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
     {
          if appDel.isLandscape {
             return draftTblView.bounds.height
         }
         else{
             return 256
         }
     }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
       // return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
  

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DraftTableCell", for: indexPath) as? DraftTableCell else { return UITableViewCell()
        }
        let count = indexPath.row + 1
        cell.draftNameLbl.text = "Draft \(count)"
        let listDetailDict = list[indexPath.row]
    let urlStr = (listDetailDict as AnyObject).value(forKey: "videoClip") as! NSString

           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           let documentsURL = paths[0] as NSURL
        let myUrl =  URL(string: "\(documentsURL)\(urlStr)")

        do {

            let asset = AVURLAsset(url: myUrl! , options: nil)

            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            cell.thumbImg.image = UIImage.init(cgImage: cgImage)


       //  saveImage(imageName: fileNames, image: image)

        } catch let error {

            print("*** Error generating thumbnail: \(error.localizedDescription)")
           // return nil

        }
        let unixTimeStamp = ((listDetailDict as AnyObject).value(forKey: "dateTime") as! Double?)!
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)as Date
        let dateFormatt = DateFormatter();
                  dateFormatt.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatt.string(from: exactDate as Date)


        let dateFormatTime = DateFormatter();
        dateFormatTime.dateFormat = "hh:mm a"
        let uploadTime = dateFormatTime.string(from: exactDate as Date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formatedStartDate = dateFormatter.date(from: startDate)
        let currentDate = Date()
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: formatedStartDate!, to: currentDate)

        print (differenceOfDate.day as Any)
        if differenceOfDate.day == 0 {

          cell.draftTimeLbl.text = "Today \(uploadTime)"

        }
        else if differenceOfDate.day == 1 {
          cell.draftTimeLbl.text = "Yesterday \(uploadTime)"
        }
        else{
            let dateFormatTime = DateFormatter();
                   dateFormatTime.dateFormat = "yyyy-MM-dd hh:mm a"
                   cell.draftTimeLbl.text = dateFormatTime.string(from: exactDate as Date)
        }
//        cell.deletBtnl?.tag = indexPath.row
//        cell.deletBtnl?.addTarget(self, action: #selector(deletVideoBtnPressed), for: .touchUpInside)
//
//
//        cell.sendBtn?.tag = indexPath.row
//        cell.sendBtn?.addTarget(self, action: #selector(sendVideoBtnPressed), for: .touchUpInside)
        cell.deletBtn?.tag = indexPath.row
        cell.deletBtn?.addTarget(self, action: #selector(deletVideoBtnPressed), for: .touchUpInside)
        cell.nextBtn?.tag = indexPath.row
        cell.nextBtn?.addTarget(self, action: #selector(sendBtnPressed), for: .touchUpInside)
//        cell.saveGallaryBtn?.tag = indexPath.row
//        cell.saveGallaryBtn?.addTarget(self, action: #selector(saveVideoGallaryBtnPressed), for: .touchUpInside)
//        cell.shareBtn?.tag = indexPath.row
//               cell.shareBtn?.addTarget(self, action: #selector(shareVideoBtnPressed), for: .touchUpInside)
//        cell.sendBtnl?.tag = indexPath.row
//               cell.sendBtnl?.addTarget(self, action: #selector(sendVideoBtnPressed), for: .touchUpInside)
             
//               cell.saveGallaryBtnl?.tag = indexPath.row
//               cell.saveGallaryBtnl?.addTarget(self, action: #selector(saveVideoGallaryBtnPressed), for: .touchUpInside)
//               cell.shareBtnl?.tag = indexPath.row
//                      cell.shareBtnl?.addTarget(self, action: #selector(shareVideoBtnPressed), for: .touchUpInside)
        
        return cell
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
         let listDetailDict = list[indexPath.row]
         let urlStr = (listDetailDict as AnyObject).value(forKey: "videoClip") as! NSString
        
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths[0] as NSURL
        guard let myUrl =  URL(string: "\(documentsURL)\(urlStr)") else { return  }
        //        ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: myUrl, completionBlock: nil)
        player = AVPlayer(url: myUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController,animated:true)
        {
            playerViewController.view.contentMode = .scaleToFill
            playerViewController.player!.play()
            
        }
        
    }
    
    // MARK: - UITableView Buton Action
    // MARK: - UITableView Buton Action
    @objc func shareVideoBtnPressed(sender: UIButton)
       {
        let buttonRow = sender.tag
        let listDetailDict = list[buttonRow]

         let urlStr = (listDetailDict as AnyObject).value(forKey: "videoClip") as! NSString
                 print(urlStr)
                 let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                 let documentsURL = paths[0] as NSURL
                 guard let myUrl =  URL(string: "\(documentsURL)\(urlStr)") else { return  }

       // let yourPath = ""
      //  let yourUrl = URL(fileURLWithPath: yourPath)
        let activity: [Any] = [myUrl, "Your custom message here…"]
        let actController = UIActivityViewController(activityItems: activity, applicationActivities: nil)
        actController.popoverPresentationController?.sourceView = view
        actController.popoverPresentationController?.sourceRect = view.frame
        self.present(actController, animated: true, completion: nil)


    }
    @objc func saveVideoGallaryBtnPressed(sender: UIButton)
    {

        let alertController = UIAlertController(title: "Alert", message: "Are you sure want to Saved  the video Gallary", preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in

            let buttonRow = sender.tag
            let listDetailDict = self.list[buttonRow]
                 let urlStr = (listDetailDict as AnyObject).value(forKey: "videoClip") as! NSString


            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsURL = paths[0] as NSURL

            guard let myUrl =  URL(string: "\(documentsURL)\(urlStr)") else { return  }
ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: myUrl, completionBlock: nil)


        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func sendBtnPressed(sender: UIButton)
       {
        let buttonRow = sender.tag
        let listDetailDict = list[buttonRow]
        let urlStr = (listDetailDict as AnyObject).value(forKey: "videoClip") as! NSString
             let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostNewsViewController") as! PostNewsViewController
        secondViewController.videoUrlStr = urlStr as String
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    @objc func deletVideoBtnPressed(sender: UIButton)
    {
        let buttonRow = sender.tag
        
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Alert", message: "Are you sure want to delete the video", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let requestDel = NSFetchRequest<NSFetchRequestResult>(entityName: "Store")
            requestDel.returnsObjectsAsFaults = false
            
            do {
                let arrUsrObj = try context.fetch(requestDel)
                let eventArrayItem = arrUsrObj[buttonRow]
                context.delete(eventArrayItem as! NSManagedObject)
                self.list.remove(at: buttonRow)
                self.draftTblView.reloadData()
            } catch {
                print("Failed")
            }
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }

            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
   
    }
    @objc func sendVideoBtnPressed(sender: UIButton)
    {
        let buttonRow = sender.tag
        let listDetailDict = list[buttonRow]
        shareVideoUrlStr = ((listDetailDict as AnyObject).value(forKey: "videoClip") as! NSString) as String
      //`  shareVideoUrlStr = self.list[buttonRow] as! String
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! DraftCustomeAlert
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)



    }
     

    func AWSS3TransferManagerUploadFunction(with resource: String) {
        let key = "\(resource)"

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths[0] as NSURL
        guard let myUrl =  URL(string: "\(documentsURL)\(resource)") else { return  }
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = bucketName
        request.key = key
        request.body = myUrl
        request.acl = .publicReadWrite
        let transferManager = AWSS3TransferManager.default()
        self.startAnimating()
   transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                print(error)
                self.stopAnimating()
            }
            if task.result != nil {
                  self.stopAnimating()
                print("Uploaded \(key)")
                self.UploadVideoUrlStr = "https://replaymedemo.s3.ap-south-1.amazonaws.com/NewsFeedVideo/\(key)"

                self.getThumbnailFrom(path: myUrl)

            }
            return nil
        }

    }
     
    func getThumbnailFrom(path: URL) {

        do {

            let asset = AVURLAsset(url: path , options: nil)
             videoDuration = "\(asset.duration.seconds)"
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
           let image:UIImage = UIImage.init(cgImage: cgImage)
           let fileNames = "\(Date().timeIntervalSince1970).jpg"

         saveImage(imageName: fileNames, image: image)

        } catch let error {

            print("*** Error generating thumbnail: \(error.localizedDescription)")
           // return nil

        }

    }
     // MARK: - thumbnailImage Save function
            func saveImage(imageName: String, image: UIImage) {


             guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

                let fileURL = documentsDirectory.appendingPathComponent(imageName)
                guard let data = image.jpegData(compressionQuality: 1) else { return }

                //Checks if file exists, removes it if so.
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    do {
                        try FileManager.default.removeItem(atPath: fileURL.path)
                        print("Removed old image")
                    } catch let removeError {
                        print("couldn't remove file at path", removeError)
                    }

                }

                do {
                    try data.write(to: fileURL)
                } catch let error {
                    print("error saving file with error", error)
                }
        loadImageFromDiskWith(fileName: imageName)
            }

     // MARK: - fetch thumbnail Url
    func loadImageFromDiskWith(fileName: String) -> UIImage? {

      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
           // userProfileImg.image = image
            AWSS3TransferManagerUploadImageFunction(with: imageUrl,fileName:fileName )
            return image

        }

        return nil
    }
     // MARK: - AWSS3TransferManager Upload Image
    func AWSS3TransferManagerUploadImageFunction(with resource: URL,fileName: String) {

           self.startAnimating()

           let key = "\(fileName)"
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                 let documentsURL = paths[0] as NSURL
                 guard let myUrl =  URL(string: "\(documentsURL)\(resource)") else { return  }
           let request = AWSS3TransferManagerUploadRequest()!
           request.bucket = thumbnailBucketName
           request.key = key
           request.body = resource
           request.acl = .publicReadWrite
           request.contentType = "image"

           let transferManager = AWSS3TransferManager.default()
               self.startAnimating()
           transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
               if let error = task.error {
                   print(error)
                    self.stopAnimating()
               }
               if task.result != nil {
                   print("Uploaded \(key)")
                  self.stopAnimating()
                   self.uploadAddStory(with: "https://replaymedemo.s3.ap-south-1.amazonaws.com/NewsFeedVideo/output/images/\(key)" )

               }
               return nil
           }

       }
     // MARK: - Upload story function
    func uploadAddStory(with imageThumb: String){

        let para = ["videoUrl": UploadVideoUrlStr,"videoScreenShotUrl": imageThumb,"videoLength": videoDuration]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kAddStory, parameters: para as [String : Any]) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            if(status == "true"){
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                if self.uploadType == 2{
                self.uploadVidoeNewsFeed(with: imageThumb)
                }
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)

            }
        }
    }
     // MARK: - Upload newsFeed function
    func uploadVidoeNewsFeed(with imgThumbUrl: String){

        self.startAnimating()
        let para = ["videoUrl": UploadVideoUrlStr,"videoScreenShotUrl":imgThumbUrl,"content": ""]
                     print (para)
                     ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kAddNewsFeedVideo, parameters: para as [String : Any]) { (dict) in
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
  
    
    
    @IBAction func backBtnClicked(_ sender: Any) {
       
        if checkControler == 1
        {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            //self.navigationController?.popViewController(animated: true)
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
//        else{
//            DispatchQueue.main.async {
//                
//                DispatchQueue.main.async {
//                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//                    self.navigationController?.pushViewController(secondViewController, animated: true)
////                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    
    
}
@available(iOS 13.0, *)
extension DraftViewController {
    
    //MARK: - MXSegmentedControl Methods
    @objc func changeIndex(segmentedControl: MXSegmentedControl) {
        
        switch segmentedControl.selectedIndex {
        case 0:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            //collectionviewHieght.constant = 106
            //usersStoryCollectionView.reloadData()
            draftTblView.isHidden = false
            
        case 1:
            segmentedControl.indicator.lineView.backgroundColor = #colorLiteral(red: 1, green: 0.07843137255, blue: 0.5803921569, alpha: 1)
            //collectionviewHieght.constant = 0
            //usersStoryCollectionView.reloadData()
        // retrieveData()
            draftTblView.isHidden = true
        default:
            break
        }
    }
}

@available(iOS 13.0, *)
extension DraftViewController: CustomAlertViewDelegate {
    
    func okButtonTapped(textFieldValue: String) {
        print("TextField has value: \(textFieldValue)")
        if textFieldValue == "Story"{
           // self.AWSS3TransferManagerUploadFunction(with: shareVideoUrlStr )
        }
        else if textFieldValue == "Feed"{
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostNewsFeedViewController") as! PostNewsFeedViewController
            secondViewController.videoUrlStr = shareVideoUrlStr
            secondViewController.typeStr = "feeds"; self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        else{
           // self.AWSS3TransferManagerUploadFunction(with: shareVideoUrlStr )
           uploadType = 2
        }
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}
