//
//  ForgotPwsdViewController.swift
//  ReplayMe
//  Created by Core Techies on 24/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

class ForgotPwsdViewController: UIViewController,NVActivityIndicatorViewable {
    @IBOutlet var backgroundImg: UIImageView!
    
    @IBOutlet weak var emailTxtFieldTxt: UITextField!
    var emailTxtFIeldTxtStr: String = ""
      var checkMobilNoStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    @IBAction func submitBtnClicked(_ sender: Any) {
        if ((self.emailTxtFieldTxt.text == ""))
              {
                  if ((self.emailTxtFieldTxt.text == ""))
                  {
                  self.ShowBanner(title: "", subtitle: "Please enter email / phone.")
                  }
                  
              }
            
             else{
            let digitSet = CharacterSet.decimalDigits
            
                  for ch in emailTxtFieldTxt.text!.unicodeScalars {
                           if digitSet.contains(ch) {
                              checkMobilNoStr = emailTxtFieldTxt.text!
                               emailTxtFIeldTxtStr = ""
                           }
                           else{
                              emailTxtFIeldTxtStr = emailTxtFieldTxt.text!
                              checkMobilNoStr = ""
                              break
                           }
                       }
            self.startAnimating()
            let para = ["email": emailTxtFIeldTxtStr,"contactNumber": checkMobilNoStr]
                 print (para)
                 ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kForgotPassword, parameters: para as [String : Any]) { (dict) in
                     print(dict)
                     self.stopAnimating()
                     let status = dict["status"] as? String
                     self.stopAnimating()
                     if(status == "true"){
                        self.emailTxtFieldTxt.text = nil
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
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    

}
