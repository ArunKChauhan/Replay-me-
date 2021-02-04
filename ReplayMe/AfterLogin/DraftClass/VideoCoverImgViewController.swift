//
//  VideoCoverImgViewController.swift
//  ReplayMe
//
//  Created by Krishna on 07/07/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVKit

@available(iOS 13.0, *)
protocol AddContactDelegate {
    func addContact(contact: Contact)
}


@available(iOS 13.0, *)
class VideoCoverImgViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
      var delegate: AddContactDelegate?
    var videoUrl: String = ""
    @IBOutlet var videoThubnailImg: UIImageView!
     @IBOutlet weak var collectionView: UICollectionView!
    var imageArray: [CGImage] = []
    var checkIndex: Int = 0
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName:"VideoThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "VideoThumbnailCell")

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        VideoCoverImgViewController.lockOrientation(.portrait, andRotateTo: .portrait)
        
     
genrateVideoThumb()
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    func genrateVideoThumb()  {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                      let documentsURL = paths[0] as NSURL
                   let myUrl =  URL(string: "\(documentsURL)\(videoUrl)")

                   do {

                       let asset = AVURLAsset(url: myUrl! , options: nil)
                     let totalSeconds =
                         Int(CMTimeGetSeconds(asset.duration))
                let seconds = totalSeconds % 60
                     for i in 1..<(seconds){
                         let imgGenerator = AVAssetImageGenerator(asset: asset)
                                   imgGenerator.appliesPreferredTrackTransform = true
                        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: Int64(seconds), timescale: Int32(i)), actualTime: nil)
                         print(cgImage)
                        imageArray.append(cgImage)
                         if i == 1{
                     videoThubnailImg.image = UIImage.init(cgImage: cgImage)
                            
                         }
                         else{
                          
                        }
                         
                     }
                     
                     

                   } catch let error {

                       print("*** Error generating thumbnail: \(error.localizedDescription)")
                      // return nil

                   }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
          return 1
    }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize  {//size of your item for screen sizes
         return CGSize(width: 130, height: 106)
       }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoThumbnailCell", for: indexPath) as! VideoThumbnailCell
     
        if checkIndex == indexPath.row {
            cell.backgroundColor = #colorLiteral(red: 0.9630439878, green: 0.345115453, blue: 0.6920550466, alpha: 1)
        }
        else{
            cell.backgroundColor = .clear
        }
        let image = self.imageArray[indexPath.item]
        cell.videoThumbImg.image = UIImage.init(cgImage: image )
          return cell
    }
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         videoThubnailImg.image = UIImage.init(cgImage: self.imageArray[indexPath.item])
        checkIndex = indexPath.row
        collectionView.reloadData()
        
           
    }
  
    @IBAction func checkBtnClciked(_ sender: Any) {
        
        let contact = Contact(selectImage: videoThubnailImg.image!)
            
            delegate?.addContact(contact: contact)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
      
        dismiss(animated: true, completion: nil)
    }
    



}
