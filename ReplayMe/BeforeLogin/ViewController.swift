//
//  ViewController.swift
//  ReplayMe
//
//  Created by Core Techies on 24/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import Crashlytics

@available(iOS 13.0, *)
class ViewController: UIViewController {
    @IBOutlet var backgroundImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Crashlytics.sharedInstance().crash()
   backgroundImg.image = UIImage(named: "background.png")
   if let loginStr =  UserDefaults.standard.string(forKey: "login")
   {
    if loginStr == "login"{
    DispatchQueue.main.async {
                                 let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                                 self.navigationController?.pushViewController(secondViewController, animated: false)
                             }
    }
    
        }
  
       
    }
    override func viewDidAppear(_ animated: Bool) {
          backgroundImg.image = UIImage(named: "background.png")
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
       
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
                DispatchQueue.main.async {
                    self.backgroundImg.image = UIImage(named: "background-1.png")
                }
            } else {
                print("Portrait")
                DispatchQueue.main.async {
                    self.backgroundImg.image = UIImage(named: "background.png")
                   }
                 

            }
       
    }
    
    override var prefersStatusBarHidden: Bool {
          return true
      }
    @IBAction func loginBtnClicked(_ sender: Any) {
     
        let thresholdDict = ["startCamera": 0.0,"endCamera": 0.0]
          UserDefaults.standard.set(thresholdDict, forKey: "thresHoldSetting")
        DispatchQueue.main.async {
                                 let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                 self.navigationController?.pushViewController(secondViewController, animated: true)
                             }

        
    }
    @IBAction func createAccountBtnClicked(_ sender: Any) {
        let thresholdDict = ["startCamera": 0.0,"endCamera": 0.0]
                 UserDefaults.standard.set(thresholdDict, forKey: "thresHoldSetting")
        DispatchQueue.main.async {
                                  let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
            secondViewController.checkController = "root"; self.navigationController?.pushViewController(secondViewController, animated: true)
                              }
        
    }


}

