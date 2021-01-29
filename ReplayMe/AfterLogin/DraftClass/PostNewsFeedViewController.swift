//
//  PostNewsFeedViewController.swift
//  ReplayMe
//
//  Created by Core Techies on 18/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import AWSCognito
import AWSS3
import AVFoundation
import AVKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos


class PostNewsFeedViewController: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var videoPlayerView: AGVideoPlayerView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var userProfileImg: UIImageView!
    
    var videoUrlStr: String = ""
    let placeholder = "Write your caption.."
    let bucketName = "replaymedemo/NewsFeedVideo"
    let thumbnailBucketName = "replaymedemo/NewsFeedVideo/output/images"
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var UploadVideoUrlStr: String = ""
    var typeStr: String = ""
    var recordedVideoURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if typeStr == "gallery"{
            let fileName = recordedVideoURL?.lastPathComponent
            print(fileName)
            videoPlayerView.videoUrl = recordedVideoURL as URL?
        }else{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                       let documentsURL = paths[0] as NSURL
                let searchURL : NSURL = NSURL(string: "\(documentsURL)\(videoUrlStr)")!
                 videoPlayerView.videoUrl = searchURL as URL
        }
        
      
       videoPlayerView.shouldAutoplay = false
       videoPlayerView.shouldAutoRepeat = false
       videoPlayerView.showsCustomControls = false
       videoPlayerView.shouldSwitchToFullscreen = true
        
              textView.delegate = self
             textView.text = placeholder
            textView.textColor = UIColor.darkGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
        self.AWSS3TransferManagerUploadFunction(with: videoUrlStr )
    }
    
       func AWSS3TransferManagerUploadFunction(with resource: String) {
        var key = "\(resource)"
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
              let documentsURL = paths[0] as NSURL
              guard let myUrl =  URL(string: "\(documentsURL)\(resource)") else { return  }
        let request = AWSS3TransferManagerUploadRequest()!
        
        if typeStr == "gallery"{
            print((recordedVideoURL as URL?)!)
            key = (recordedVideoURL?.lastPathComponent)!
            request.bucket = bucketName
                request.key = key
            request.body = (recordedVideoURL as URL?)!
                request.acl = .publicReadWrite
        }
        else{
            request.bucket = bucketName
              request.key = key
              request.body = myUrl
              request.acl = .publicReadWrite
        }
  
        let transferManager = AWSS3TransferManager.default()
            self.startAnimating()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                print(error)
                 self.stopAnimating()
            }
            if task.result != nil {
                print("Uploaded \(key)")
                self.UploadVideoUrlStr = "https://replaymedemo.s3.ap-south-1.amazonaws.com/NewsFeedVideo/\(key)"
               self.stopAnimating()
                if self.typeStr == "gallery"{
                    self.getThumbnailFrom(path: self.recordedVideoURL! as URL)
                }else{
                self.getThumbnailFrom(path: myUrl)
                }
            }
            return nil
        }
    }

    func getThumbnailFrom(path: URL) {

        do {

            let asset = AVURLAsset(url: path , options: nil)
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
               
        if textView.text == "Write your caption.."{
            textView.text = ""
        }
        self.startAnimating()
        
        let para = ["videoUrl": UploadVideoUrlStr,"videoScreenShotUrl":imgThumbUrl,"content": textView.text!,"videoType": typeStr,"title":""]
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
extension PostNewsFeedViewController: UITextViewDelegate {
    
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
