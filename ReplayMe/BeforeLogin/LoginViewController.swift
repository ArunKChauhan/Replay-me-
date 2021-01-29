//
//  LoginViewController.swift
//  ReplayMe
//
//  Created by Core Techies on 24/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import TwitterKit

import GoogleSignIn

@available(iOS 13.0, *)
class LoginViewController: UIViewController,GIDSignInDelegate,NVActivityIndicatorViewable {
    
    @IBOutlet var backgroundImg: UIImageView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var pawsdtextField: UITextField!
    var emailTxtFIeldTxtStr: String = ""
    var checkMobilNoStr: String = ""
    var name: String = ""
    var email: String = ""
    var userId : String = ""
    var first_name: String = ""
    var last_name: String = ""
    var socialImagesUrl: String = ""
    var socialLoginType: String = ""
    let manager = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let store = TWTRTwitter.sharedInstance().sessionStore
        store.reload()
        for case let session as TWTRSession in store.existingUserSessions() {
            store.logOutUserID(session.userID)
        }
        GIDSignIn.sharedInstance().delegate = self
      backgroundImg.image = UIImage(named: "background.png")
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
    //MARK:- @Button Action Method
    
    @IBAction func forgotPwsdBtnClicked(_ sender: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPwsdViewController") as! ForgotPwsdViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        emailTxtField.text = nil
        pawsdtextField.text = nil
    }
    @IBAction func loginBtnClicked(_ sender: Any) {
        
        if ((self.emailTxtField.text == "")) || ((self.pawsdtextField.text == ""))
        {
            if ((self.emailTxtField.text == ""))
            {
                self.ShowBanner(title: "", subtitle: " Please Enter Valid Email.")
            }
            else if ((self.pawsdtextField.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "Please Enter Password.")
            }
        }
        else{
            
            
            let digitSet = CharacterSet.decimalDigits
            
            for ch in emailTxtField.text!.unicodeScalars {
                if digitSet.contains(ch) {
                    checkMobilNoStr = emailTxtField.text!
                    emailTxtFIeldTxtStr = ""
                }
                else{
                    emailTxtFIeldTxtStr = emailTxtField.text!
                    checkMobilNoStr = ""
                    break
                }
            }
            let deviceToken =  UserDefaults.standard.string(forKey: "deviceToken")!
            self.startAnimating()
            let para = ["email": emailTxtFIeldTxtStr,"password": pawsdtextField.text!,"device_type":
                "ios","deviceId": deviceToken,"contactNumber": checkMobilNoStr]
            print (para)
            ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kLogin, parameters: para as [String : Any]) { (dict) in
                print(dict)
                self.stopAnimating()
                let status = dict["status"] as? String
                self.stopAnimating()
                if(status == "true"){
                    UserDefaults.standard.set(((dict as AnyObject).value(forKey: "_token") as! String?), forKey: "token")
                    UserDefaults.standard.set("login", forKey: "login")
                    self.emailTxtField.text = nil
                    self.pawsdtextField.text = nil
                    self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                    let userDataDict = dict.value(forKey: "data") as! NSDictionary
                    UserDefaults.standard.set(userDataDict, forKey: "userDetailDict")
                    DispatchQueue.main.async {
                 let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
                        
                    }
                }
                    else
                    {
                        self.stopAnimating()
                        self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                        
                    }
                    
                }
            }
            
        
        
    }
    @IBAction func fbLoginBtnClicked(_ sender: Any) {
        self.facebooklogin()
    }
    @IBAction func gmailLoginBtnClicked(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //  GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        GIDSignIn.sharedInstance().signIn()
        
    }
    @IBAction func twitterLoginBtnClicked(_ sender: Any) {
        
        
        
        
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                 if (session != nil) {
                    
                    let twitterClient = TWTRAPIClient(userID: session?.userID)
                        twitterClient.loadUser(withID: (session?.userID)!, completion: { (user, error) in
                          
                            self.socialImagesUrl = user!.profileImageLargeURL
                           // self.last_name = user!.screenName
                          self.socialLogin()
                            
                    })
                    
                    let client = TWTRAPIClient.withCurrentUser()
                         client.requestEmail { email, error in
                             if (email != nil) {
                                 self.email = email ?? ""
                                self.first_name = session!.userName
                                self.userId = session!.userID
                                
                                 
                             }else {
                                 print("error--: \(String(describing: error?.localizedDescription))");
                             }
                         }
                    self.socialLoginType = "twitter"
                   
             
                 }
                 else {
                     print("error: \(error!.localizedDescription)");
                 }
             })
        
    }
    @IBAction func signupBtnClicked(_ sender: Any) {
        DispatchQueue.main.async {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }

    
    //MARK: - Google Sign-In Methods
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        print(user)
        
        if user != nil {
            
            let fullname = user.profile.name
            var nameArray = fullname!.components(separatedBy: " ")
            self.email = user.profile.email
            self.userId = user.userID
            socialLoginType = "gmail"
            if user.profile.hasImage
            {
                socialImagesUrl = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 400).absoluteString
                print(socialImagesUrl)
                // let imageUrl = signIn.currentUser.profile.imageURL(withDimension: 150)
                
                first_name = user.profile.givenName
                last_name = user.profile.familyName
                socialLogin()
            }
            else
            {
                self.socialImagesUrl = ""
                first_name = user.profile.givenName
                last_name = user.profile.familyName
                
                self.socialLogin()
                
            }
        }
    }
    
    //MARK: - Facebook Sign-In Methods
    func facebooklogin() {
        
       // manager.loginBehavior = .native
        manager.logIn(permissions: ["public_profile","email"], from: self, handler: {
            (result,error) in
            print((result,error) )
            if result?.token != nil {
                GraphRequest(graphPath: "me", parameters: ["fields":"picture.type(large),id,email,name,first_name,last_name,birthday"]).start(completionHandler: { (con, result, error)
                    in
                    if error == nil
                    {
                        let fields = result as? NSDictionary
                        print(fields as Any)
                        if let profilePictureObj = fields?.value(forKey: "picture") as? NSDictionary
                        {
                            let data = profilePictureObj.value(forKey: "data") as! NSDictionary
                            self.socialImagesUrl  = data.value(forKey: "url") as! String
                            print(self.socialImagesUrl)
                            self.name = (fields!["name"] as? String)!
                            if let emailId = (fields!["email"])as? String
                            
                            {
                                self.email = emailId
                            }
                          
                            self.userId = (fields!["id"] as? String)!
                            self.first_name = (fields!["first_name"] as? String)!
                            self.last_name = (fields!["last_name"] as? String)!
                            
                        }
                            
                        else
                        {
                            self.name = (fields!["name"] as? String)!
                            if let emailId = (fields!["email"])as? String
                                                       {
                                self.email = emailId
                                                       }
                           // self.email = (fields!["email"] as? String)!
                            self.userId = (fields!["id"] as? String)!
                            self.first_name = (fields!["first_name"] as? String)!
                            self.last_name = (fields!["last_name"] as? String)!
                            self.socialImagesUrl = ""
                            
                        }
                        self.socialLoginType = "facebook"
                        self.socialLogin()
                    }
                })
            }
        })
    }
   
    func socialLogin()   {
        let deviceToken =  UserDefaults.standard.string(forKey: "deviceToken")!
        self.startAnimating()
        let para = ["firstName": first_name,"lastName": last_name,"email":
            email,"contactNumber": "","deviceId": deviceToken,"SocailId": userId,"login_type": socialLoginType ,"device_type": "ios","imageUrl": socialImagesUrl ]
        print (para)
        ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kSocialLogin, parameters: para as [String : Any]) { (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            self.stopAnimating()
            if(status == "true"){
                self.emailTxtField.text = nil
                self.pawsdtextField.text = nil
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                 UserDefaults.standard.set("login", forKey: "login")
                  UserDefaults.standard.set(((dict as AnyObject).value(forKey: "_token") as! String?), forKey: "token")
                   let userDataDict = dict.value(forKey: "data") as! NSDictionary
                 UserDefaults.standard.set(userDataDict, forKey: "userDetailDict")
              DispatchQueue.main.async {
                      let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                    
                }
                
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                
            }
            
        }
        
    }
    
}
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
