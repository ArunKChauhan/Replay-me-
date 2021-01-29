//
//  PostNewsViewController.swift
//  ReplayMe
//
//  Created by Krishna on 16/06/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVKit


@available(iOS 13.0, *)
struct Contact {
    var selectImage: UIImage
}
@available(iOS 13.0, *)
class PostNewsViewController: UIViewController {
 @IBOutlet weak var textView: UITextView!
    let placeholder = "Caption.."
    @IBOutlet var scrollBackView: UIView!
     let appDel = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var cancelBtnClicked: UIButton!
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var videoCoverImg: UIImageView!
    var recordedVideoURL: NSURL?
    var videoUrlStr: String = ""
    
    
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
