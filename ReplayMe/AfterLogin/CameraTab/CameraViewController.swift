//
//  CameraViewController.swift
//  ReplayMe
//
//  Created by Mahendra Singh on 26/03/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos
import CoreData
@available(iOS 13.0, *)
class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    @IBOutlet weak var captureButton    : SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton : UIButton!
    @IBOutlet weak var flashButton      : UIButton!
    
    @IBOutlet var settingBackView: UIView!
    @IBOutlet weak var recordingTimerLbl: UILabel!
    @IBOutlet var startTimeSlide: UISlider!
    @IBOutlet var endTimeSlide: UISlider!
    @IBOutlet var startTimeLbl: UILabel!
    @IBOutlet var endTimeLbl: UILabel!
    
    var videoFileOutput:AVCaptureMovieFileOutput?
    var startSliderValue: Int = 0
    var endSliderValue: Int = 0
    var videoFileNameStr: String = ""
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var counter = 0
    var timer = Timer()
    var checkSave: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        settingBackView.isHidden = true //UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        shouldPrompToAppSettings = true
        cameraDelegate = self
        maximumVideoDuration = 10.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
        flashMode = .auto
        //flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        captureButton.buttonEnabled = false
        captureButton.delegate = self
              CameraViewController.lockOrientation(.landscape, andRotateTo: .landscapeRight)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        CameraViewController.lockOrientation(.all)
        appDel.isLandscape = true
    }
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
    }
    
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did start running")
        captureButton.buttonEnabled = true
        
        startVideoRecording()
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did stop running")
        captureButton.buttonEnabled = false
    }
    

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        //let newVC = PhotoViewController(image: photo)
        //self.present(newVC, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
        captureButton.growButton()
        //hideButtons()
        self.timer.invalidate() // just in case this button is tapped multiple times
        // start the timer
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
        captureButton.shrinkButton()
        self.timer.invalidate()
        //showButtons()
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        if checkSave == true{
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        let totalVideoDurationSec = Int(durationTime)
            
    let   thresholdSetting = UserDefaults.standard.value(forKey: "thresHoldSetting") as! NSDictionary;
    let startCamTime =  thresholdSetting["startCamera"] as! Float
      let endCamTime =  thresholdSetting["endCamera"] as! Float
     let thresholdTime = startCamTime + endCamTime
            if totalVideoDurationSec <= Int(thresholdTime)
        {
            cropVideo(sourceURL1: url as NSURL, startTime: Float(0), endTime: Float(totalVideoDurationSec))
        }
        else{
            let startTime = totalVideoDurationSec - Int(thresholdTime)
            cropVideo(sourceURL1: url as NSURL, startTime: Float(startTime), endTime: Float(totalVideoDurationSec))
        }
            counter = 0
        self.unloadCameraData()
        self.loadCameraData()
        }
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        print("Did focus at point: \(point)")
        focusAnimationAt(point)
    }
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print("Zoom level did change. Level: \(zoom)")
        print(zoom)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print("Camera did change to \(camera.rawValue)")
        print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTapCaptureClipBtn vale:Bool){
        captureButton.disableButton()
    }
    @IBAction func settingCloseBtnClicked(_ sender: Any) {
        UIView.transition(with: settingBackView, duration: 0.4,
                 options: .transitionCrossDissolve,
                 animations: {
                     self.settingBackView.isHidden = true
             })
    }
    @IBAction func startTimeSlider(_ sender: UISlider)
    {
        print(startTimeSlide.value)
       startSliderValue  = Int(startTimeSlide.value)
       endSliderValue  = Int(endTimeSlide.value)
       let addSliderValue = endSliderValue + startSliderValue
        if  addSliderValue <= 60{
         print("krishna")
        }
        else{
             let valueUpdate: Float = Float(addSliderValue) - 60.0
            
            endTimeSlide.setValue(endTimeSlide.value - valueUpdate, animated: true)
              endTimeLbl.text = "\(Int(endTimeSlide.value)) Sec"
        }
        let thresholdDict = ["startCamera": startTimeSlide.value,"endCamera": endTimeSlide.value]
                UserDefaults.standard.set(thresholdDict, forKey: "thresHoldSetting")
        startTimeLbl.text = "\(Int(startSliderValue)) Sec"
    }
    @IBAction func endTimeSlider(_ sender: UISlider)
    {
        startSliderValue  = Int(startTimeSlide.value)
           endSliderValue  = Int(endTimeSlide.value)
           let addSliderValue = endSliderValue + startSliderValue
            if  addSliderValue <= 60{
             print("krishna")
            }
            else{
                let valueUpdate: Float = Float(addSliderValue) - 60.0
                
                startTimeSlide.setValue(startTimeSlide.value - valueUpdate , animated: true)
                   startTimeLbl.text = "\(Int(startTimeSlide.value)) Sec"
            }
        let thresholdDict = ["startCamera": startTimeSlide.value,"endCamera": endTimeSlide.value]
        UserDefaults.standard.set(thresholdDict, forKey: "thresHoldSetting")
            endTimeLbl.text = "\(Int(endSliderValue)) Sec"
        
    }
    
    @IBAction func settingBtnClicked(_ sender: Any) {
        let   thresholdDict = UserDefaults.standard.value(forKey: "thresHoldSetting") as! NSDictionary;
          
          startTimeSlide.setValue(thresholdDict["startCamera"] as! Float , animated: true)
          endTimeSlide.setValue(thresholdDict["endCamera"] as! Float, animated: true)
        
        UIView.transition(with: settingBackView, duration: 0.4,
            options: .transitionCrossDissolve,
            animations: {
                self.settingBackView.isHidden = false
        })
    }
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }
    @IBAction func closeCameraTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        self.timer.invalidate()
        self.counter = 0; self.navigationController?.popViewController(animated: false)
       // self.dismiss(animated: true, completion: nil)
    }
    @IBAction func draftBtnClicked(_ sender: Any) {
      //  self.timer.invalidate()
     checkSave = false
let draftVC = storyboard!.instantiateViewController(withIdentifier: "DraftViewController") as! DraftViewController
        draftVC.checkControler = 1
  self.navigationController?.pushViewController(draftVC, animated: true)

        
    }
 
    
    // MARK:- Timer
    @objc func timerAction() {
        counter += 1
        recordingTimerLbl.text = self.timeFormatted(self.counter)
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    @objc func fire()
       {
           timer.invalidate()
       }
    // MARK: -Trimm video Method
    func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float)
    {
        let asset = AVURLAsset(url: sourceURL1 as URL)
        let manager                 = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType         = "mov" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mov" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            print(documentDirectory)
            videoFileNameStr = "\(Date().timeIntervalSince1970).mp4"
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                outputURL = outputURL.appendingPathComponent(videoFileNameStr)
                
            }catch let error {
                print(error)
            }
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mov
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    ///  self.saveToCameraRoll(URL: outputURL as NSURL!)
                    
                    DispatchQueue.main.async {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                        
                        //We need to create a context from this container
                        let managedContext = appDelegate.persistentContainer.viewContext
                        
    let entity = NSEntityDescription.insertNewObject(forEntityName: "Store", into: managedContext);
        entity.setValue("output/\(self.videoFileNameStr)", forKey: "videoClip")
                        entity.setValue(NSDate().timeIntervalSince1970, forKey: "dateTime")
                        do
                        {
                            try managedContext.save();
                        }
                        catch
                        {
                            
                        }
                    }
                // self.performSegue(withIdentifier: "playVideo", sender: outputURL)
                case .failed:
                    print("failed \(exportSession.error)")
                    
                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    
                default: break
                }}}}
}


// UI Animations
@available(iOS 13.0, *)
extension CameraViewController {
    
    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            //self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
        }
    }
    
    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            //self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
        //flashEnabled = !flashEnabled
        if flashMode == .auto{
            flashMode = .on
            //flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
        }else if flashMode == .on{
            flashMode = .off
            //flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
        }else if flashMode == .off{
            flashMode = .auto
            //flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        }
    }
}
