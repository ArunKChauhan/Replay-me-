//
//  SignupViewController.swift
//  ReplayMe
//
//  Created by Core Techies on 24/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn
import TwitterKit
@available(iOS 13.0, *)

class SignupViewController: UIViewController,NVActivityIndicatorViewable,GIDSignInDelegate{
    
    @IBOutlet weak var firstNameTxtFild: UITextField!
    @IBOutlet weak var lastNameTxtFild: UITextField!
    @IBOutlet weak var emailtxtFild: UITextField!
    @IBOutlet weak var passwordTxtFild: UITextField!
    @IBOutlet weak var retypePwsdTxtFild: UITextField!
    @IBOutlet weak var mobNoTxtFild: UITextField!
    @IBOutlet weak var dateOfBirthTxtFild: UITextField!
     let appDel = UIApplication.shared.delegate as! AppDelegate
    let manager = LoginManager()
    var name: String = ""
    var email: String = ""
    var userId : String = ""
    var first_name: String = ""
    var last_name: String = ""
    var socialImagesUrl: String = ""
    var socialLoginType: String = ""
    var checkController: String = ""
    
    @IBOutlet var backgroundImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
   GIDSignIn.sharedInstance().delegate = self
        dateOfBirthTxtFild.delegate = self
        DispatchQueue.main.async {
                           self.backgroundImg.image = UIImage(named: "background.png")
                          }
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
      //MARK:- @Button Action
    @IBAction func signUpBtnClicked(_ sender: Any) {
        if ((self.firstNameTxtFild.text == "")) || ((self.lastNameTxtFild.text == "")) || ((self.emailtxtFild.text == "")) || ((self.retypePwsdTxtFild.text == "")) || ((self.passwordTxtFild.text == "")) || ((self.mobNoTxtFild.text == "")) || ((self.dateOfBirthTxtFild.text == ""))
        {
            if ((self.firstNameTxtFild.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "Please enter first name.")
            }
            else if ((self.lastNameTxtFild.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "Please enter last name.")
            }
            else if ((self.emailtxtFild.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "Please Enter email.")
            }
      
            else if ((self.passwordTxtFild.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "Please Enter Password.")
            }
            else if ((self.retypePwsdTxtFild.text == ""))
                      {
                          self.ShowBanner(title: "", subtitle: "Please Enter Retype password.")
                      }
            else if ((self.mobNoTxtFild.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "Please Enter Mobile number.")
            }
            else
            {
                self.ShowBanner(title: "", subtitle: "Date of birth field is required.")
            }
        }
        else{
            if isValidInput(Input: self.firstNameTxtFild.text!) && isValidInput(Input: self.lastNameTxtFild.text!)
            {
                if (self.firstNameTxtFild.text!.count >= 3 && self.firstNameTxtFild.text!.count <= 20)
                {
                    if (self.lastNameTxtFild.text!.count >= 3 && self.lastNameTxtFild.text!.count <= 15)
                    {
                        if (isValidEmail(testStr: self.emailtxtFild.text!))
                        {
                            if (isValidPassword(testStr: self.passwordTxtFild.text!))
                            {
                                if (isPasswordSame(password: self.passwordTxtFild.text!, confirmPassword: self.retypePwsdTxtFild.text!))
                                                                    {
                                   signUpApi()
                                }
                                else
                                {
                                    ShowBanner(title: "", subtitle: "Passwords do not match.")
                                }
                            }
                            else
                            {
                                self.ShowBanner(title: "", subtitle: "Password must contain 8 char, atleast 1 upercase letter, 1 lowercase letter, 1 numeric digit and 1 special char.")
                            }
                        }
                        else
                        {
                            ShowBanner(title: "", subtitle: "Please Enter Valid Email Address.")
                            
                        }
                        
                        
                    }
                    else
                    {
                        ShowBanner(title: "", subtitle: "Last Name should be between 3-15 characters.")
                    }
                }
                else
                {
                    ShowBanner(title: "", subtitle: "First Name should be between 3-20 characters.")
                }
            }
            else
            {
                ShowBanner(title: "", subtitle: "Please enter a valid First Name| Last Name containing alphabets.")
            }
        }
        
    }
    @IBAction func fbLoginBtnClicked(_ sender: Any) {
         self.facebooklogin()
    }
    @IBAction func googleLoginBtnClicked(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //  GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func twitterBtnLogin(_ sender: Any) {
        
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
    

    @IBAction func loginAccountBtnClicked(_ sender: Any) {
        if checkController == "root"{
            DispatchQueue.main.async {
                                     let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                     self.navigationController?.pushViewController(secondViewController, animated: true)
                                 }
        }
        else{
         self.navigationController?.popViewController(animated: true)
        }
       
    }
    @IBAction func bacBtnClicked(_ sender: Any) {
        if checkController == "root"{
            DispatchQueue.main.async {
                                     let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                     self.navigationController?.pushViewController(secondViewController, animated: true)
                                 }
        }
        else{
         self.navigationController?.popViewController(animated: true)
        }
        //self.navigationController?.popViewController(animated: true)
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
        
        
        manager.logIn(permissions: ["public_profile","email"], from: self, handler: {
            (result,error) in
            print((result,error) )
            if result?.token != nil {
                GraphRequest(graphPath: "me", parameters: ["fields":"picture.type(large),id,email,name,first_name,last_name,birthday"]).start(completionHandler: { (con, result, error)
                    in
                    if error == nil
                    {
            var fields = result as? NSDictionary
                        if let profilePictureObj = fields?.value(forKey: "picture") as? NSDictionary
                        {
                            let data = profilePictureObj.value(forKey: "data") as! NSDictionary
                            self.socialImagesUrl  = data.value(forKey: "url") as! String
                            print(self.socialImagesUrl)
                            self.name = (fields!["name"] as? String)!
                            self.email = (fields!["email"] as? String)!
                            self.userId = (fields!["id"] as? String)!
                            self.first_name = (fields!["first_name"] as? String)!
                            self.last_name = (fields!["last_name"] as? String)!
                            
                        }
                            
                        else
                        {
                            self.name = (fields!["name"] as? String)!
                            self.email = (fields!["email"] as? String)!
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
         let deviceToken =  UserDefaults.standard.string(forKey: "deviceToken")
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
               // self.emailTxtField.text = nil
                //self.pawsdtextField.text = nil
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
      //MARK:- @Validation check
    func isValidInput(Input:String) -> Bool {
        let emailRegEx = "^[a-zA-Z]+$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: Input)
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidPhone(teststr:String) -> Bool {
        let phoneRegEx = "^[3-9]\\d{10}$"
        let phoneTest = NSPredicate (format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: teststr)
    }
    //MARK:- @Service Api
      func signUpApi() {
          
       //   let userid = defaults.string(forKey: "resultDataId")!
          self.startAnimating()
          
        let para = ["firstName": firstNameTxtFild.text!,"lastName": lastNameTxtFild.text!,"email": emailtxtFild.text!,"password": passwordTxtFild.text!,"contactNumber": mobNoTxtFild.text!,"dob": dateOfBirthTxtFild.text!]
          print (para)
          ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kSignup, parameters: para as [String : Any]) { (dict) in
              print(dict)
              self.stopAnimating()
              let status = dict["status"] as? String
              self.stopAnimating()
              if(status == "true"){
     
            self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)
                if self.checkController == "root"{
                    DispatchQueue.main.async {
                                             let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                             self.navigationController?.pushViewController(secondViewController, animated: true)
                                         }
                }
                else{
                 self.navigationController?.popViewController(animated: true)
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
extension UITextField {
    func addBottomBorder(){
        DispatchQueue.main.async {
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 0.5)
            bottomLine.backgroundColor = UIColor.white.cgColor
            self.borderStyle = .none
            self.layer.addSublayer(bottomLine)
        }}
    func RemoveBottomBorder(){
        DispatchQueue.main.async {
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 0.5)
            bottomLine.backgroundColor = UIColor.white.cgColor
            self.borderStyle = .none
            self.layer.addSublayer(bottomLine)
        }}
}

@available(iOS 13.0, *)
extension SignupViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.dateOfBirthTxtFild {
                RPicker.selectDate {[weak self] (selectedDate) in
                    // TODO: Your implementation for date
                    
                    let dateOfBirth = selectedDate

                    let today = NSDate()

                    let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!

                    let age = gregorian.components([.year], from: dateOfBirth, to: today as Date, options: [])
                 
                    if age.year! < 12 {
                        self!.ShowBanner(title: "", subtitle: "Age should be minimum 13 years")
                        print(age)
                    }
                    else{
                    self?.dateOfBirthTxtFild.text = selectedDate.dateString("MMM-dd-YYYY")
                    }
                }
           
            return false
        }
        
        return true
    }
}
extension Date {
    
    func dateString(_ format: String = "MMM-dd-YYYY, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingYears(_ dYears: Int) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
}

extension UITextField {
    
    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }
    
    func addPadding(_ padding: PaddingSide) {
        
        self.leftViewMode = .always
        self.layer.masksToBounds = true
        
        
        switch padding {
            
        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = paddingView
            self.rightViewMode = .always
            
        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
            self.rightViewMode = .always
            
        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
            self.leftViewMode = .always
            // right
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
}
