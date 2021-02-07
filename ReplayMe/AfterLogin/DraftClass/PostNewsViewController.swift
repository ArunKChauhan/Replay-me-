//
//  PostNewsViewController.swift
//  ReplayMe
//
//  Created by Krishna on 16/06/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import AssetsLibrary
import AWSCognito
import AWSS3
import AVFoundation
import AVKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos

@available(iOS 13.0, *)
struct Contact {
    var selectImage: UIImage
}
@available(iOS 13.0, *)
class PostNewsViewController: UIViewController,NVActivityIndicatorViewable {
 @IBOutlet weak var textView: UITextView!
    let placeholder = "Caption.."
    @IBOutlet var scrollBackView: UIView!
     let appDel = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var cancelBtnClicked: UIButton!
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var videoCoverImg: UIImageView!
    var recordedVideoURL: NSURL?
    var videoUrlStr: String = ""
    let bucketName = "replaymedemo/NewsFeedVideo"
    let thumbnailBucketName = "replaymedemo/NewsFeedVideo/output/images"
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var typeStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
          print(videoUrlStr)
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           let documentsURL = paths[0] as NSURL
        let myUrl =  URL(string: "\(documentsURL)\(videoUrlStr)")

        do {

            let asset = AVURLAsset(url: myUrl! , options: nil)

            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            videoCoverImg.image = UIImage.init(cgImage: cgImage)

        } catch let error {

            print("*** Error generating thumbnail: \(error.localizedDescription)")
           // return nil

        }
        textView.delegate = self
                    textView.text = placeholder
                   textView.textColor = UIColor.darkGray
                   textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
                 self.appDel.orientationLock = .all
                 
             }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

            if appDel.isLandscape {
                print("Landscape")
                   var newFrame = scrollBackView.frame
                 newFrame.size.height = 410
                self.scrollBackView.frame = newFrame

            } else {
                print("Portrait")
                var newFrame = scrollBackView.frame
                // DispatchQueue.main.async {
                newFrame.size.height = 680
                    self.scrollBackView.frame = newFrame
                //}
               
     
            }
       
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoginStatus"), object: "krishnaTest")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
    }
    @IBAction func galleryBtnClicked(_ sender: Any) {
    }
    @IBAction func chnageCoverBtnClicked(_ sender: Any) {
       // let vc = VideoCoverImgViewController(nibName: "VideoCoverImgViewController", bundle: nil)
        
        let controller = VideoCoverImgViewController()
            controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        controller.videoUrl = videoUrlStr
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func filterBtnClicked(_ sender: Any) {
    }
    @IBAction func canceldBtnClicked(_ sender: Any) {
    }
    @IBAction func postBtnClicked(_ sender: Any) {
        
        saveImage(imageName: "\(Date().timeIntervalSince1970).jpg", image: videoCoverImg.image!)
    }
 
    
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
                self.uploadVidoeNewsFeed(with: "https://replaymedemo.s3.ap-south-1.amazonaws.com/NewsFeedVideo/output/images/\(key)" )
               
            }
            return nil
        }
        
    }
 
 func uploadVidoeNewsFeed(with imgThumbUrl: String){
            
//     if textView.text == "Write your caption.."{
//         textView.text = ""
//     }
     self.startAnimating()
     
    let para = ["videoUrl": videoUrlStr,"videoScreenShotUrl":imgThumbUrl,"content": textView.text!,"videoType": "gallery","title":txtTitle.text!] as [String : Any]
                  print (para)
                  ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kAddNewsFeedVideo, parameters: para as [String : Any]) { (dict) in
                      print(dict)
                      self.stopAnimating()
                      let status = dict["status"] as? String
                   
                      if(status == "true"){
                         self.textView.text = nil
                         self.textView.delegate = self
                          self.textView.text = self.placeholder
                         self.textView.textColor = UIColor.darkGray
                         self.textView.selectedTextRange = self.textView.textRange(from: self.textView.beginningOfDocument, to: self.textView.beginningOfDocument)
                         
                    self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                         self.navigationController?.popViewController(animated: true)
     
                      }
                      else
                      {
                           self.stopAnimating()
                           self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
     
                      }
     }
 }
    
}
@available(iOS 13.0, *)
extension PostNewsViewController: UITextViewDelegate {
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            
            let currentText: NSString = textView.text as NSString
            let updatedText = currentText.replacingCharacters(in: range, with:text)
            
            if updatedText.isEmpty {
                textView.text = placeholder
                textView.textColor = UIColor.darkGray
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                return false
            }
            else if textView.textColor == UIColor.darkGray && !text.isEmpty {
                textView.text = nil
                textView.textColor = UIColor.white
            }
           return updatedText.count <= 100
           // return true
        }
      
        func textViewDidChangeSelection(_ textView: UITextView) {
            if self.view.window != nil {
                if textView.textColor == UIColor.darkGray {
                    textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                }
            }
        }
        
    }

@available(iOS 13.0, *)
extension PostNewsViewController: AddContactDelegate {

func addContact(contact: Contact) {
    self.dismiss(animated: true) {
     print(contact)
        self.videoCoverImg.image = contact.selectImage
    }
}
}
