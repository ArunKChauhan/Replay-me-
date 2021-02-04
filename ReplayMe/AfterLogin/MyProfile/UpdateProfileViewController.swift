//
//  UpdateProfileViewController.swift
//  ReplayMe
//
//  Created by Krishna on 12/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift


class UpdateProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NVActivityIndicatorViewable {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var firstNameTxt: PaddedTextField!
    @IBOutlet var lastNameTxt: PaddedTextField!
    //@IBOutlet var emailTxt: PaddedTextField!
    //@IBOutlet var mobileNoTxt: PaddedTextField!
    @IBOutlet var birthDateTxt: PaddedTextField!
    @IBOutlet var bioTxtCountLbl: UILabel!
    
    
    @IBOutlet var bioTxt: PaddedTextField!
    let imagePicker: UIImagePickerController! = UIImagePickerController()
       var imageStrData : NSData? = nil
       var uploadImageUrlStr: String = ""
       var imageUrl: String = ""
    var userEmail: String = ""
    var userMobNo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    IQKeyboardManager.shared.enableAutoToolbar = true
         imagePicker.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UpdateProfileViewController.imageTapped(gesture:)))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
         let   userDetail = UserDefaults.standard.value(forKey: "userDetailDict") as! NSDictionary;
        print(userDetail)
        bioTxt.delegate = self
        
        
       profileDetail()
    }

    func profileDetail(){

        self.startAnimating()

       // print (para)
        ServiceClassMethods.AlamoRequest(method: "Get", serviceString: appConstants.kProfileDetail, parameters: nil){ (dict) in
            print(dict)
            self.stopAnimating()
            let status = dict["status"] as? String
            self.stopAnimating()
            if(status == "true"){
                  let userDetail  = ((dict as AnyObject).object(forKey: "data") as! NSDictionary?)
                self.firstNameTxt.text = ((userDetail as AnyObject).object(forKey: "firstName") as! String?)!
                    self.lastNameTxt.text = ((userDetail as AnyObject).object(forKey: "lastName") as! String?)!
                self.userEmail = ((userDetail as AnyObject).object(forKey: "email") as! String?)!
                    let mobileNo = ((userDetail as AnyObject).object(forKey: "contactNumber") as! Int?)
                
                if mobileNo != 0{
                    
                    self.userMobNo = "\(mobileNo!)"
                }
                else{
                    
                    self.userMobNo = "\(Int.random(in: 1..<72375765))"
                }
               
                  self.birthDateTxt.text = ((userDetail as AnyObject).object(forKey: "dob") as! String?)!
                   self.bioTxt.text = ((userDetail as AnyObject).object(forKey: "bio") as! String?)!
                self.profileImage.sd_setImage(with: URL(string: appConstants.kBASE_URL+(((userDetail as AnyObject).object(forKey: "imageUrl") as! String?)!)), placeholderImage: UIImage(named: "layer35"))
                self.bioTxtCountLbl.text = "\(self.bioTxt.text!.count)/80"
          
            }
            else
            {
                self.stopAnimating()
                self.ShowBanner(title: "", subtitle: dict.object(forKey: "message") as! String)

            }

        }
    }

    @objc func imageTapped(gesture: UIGestureRecognizer) {
          if (gesture.view as? UIImageView) != nil {
            
                  let alert = UIAlertController(title: nil,
                                              message: nil,
                                              preferredStyle: UIAlertController.Style.actionSheet)
                
                let galleryAction = UIAlertAction(title: "Gallery",
                                                  style: .default, handler: selectFromGallery)
                
                let CameraAction = UIAlertAction(title: "Camera",
                                                 style: .default, handler: takePhoto)
                
                let cancelAction = UIAlertAction(title: "cancel",
                                                 style: .cancel, handler: nil)
                
                alert.addAction(galleryAction)
                alert.addAction(CameraAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
          }
      }
    
    
    func takePhoto (action: UIAlertAction){
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = true
        self .present(imagePicker, animated: true, completion: nil)
    }
    func selectFromGallery (action: UIAlertAction)
    {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageStrData = image.jpegData(compressionQuality: 0.75) as NSData?
            profileImage.image = image
           // self.profileimage()
           // profileimage()
        }
        else
        {
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User canceled image")
        dismiss(animated: true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    func profileimage()
    {
        var tokensStr =  UserDefaults.standard.string(forKey: "token")
                     
                      if tokensStr == nil {
                          tokensStr = ""
                      }
                       let getTokenStr: String = tokensStr!
                  let headerss = ["x-auth-key":getTokenStr ]
       self.startAnimating()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(self.profileImage.image!.jpegData(compressionQuality: 0.75)!, withName: "imageUrl", fileName: "file.jpeg", mimeType: "image/jpeg")
            
        }, to:kImageBaseUrl + appConstants.kUplodProfieImage,headers: headerss )
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    self.stopAnimating()
                    if let JSON = response.result.value
                    {
//                        print("JSON: \(JSON)")
                        let jsonDic = JSON as? NSDictionary
                        print(jsonDic)
//                        self.uploadImageUrlStr = (jsonDic!["file_name"] as? String)!
                        print(self.uploadImageUrlStr)
                         self.ShowBanner(title: "", subtitle: "Profile has been updated successfully.")
                       
                    self.navigationController?.popViewController(animated: true)
                       
                    }
                }
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                print(encodingError)
            }
            
        }
        
    }
    @IBAction func submitBtnClicked(_ sender: Any) {
        if ((self.firstNameTxt.text == "")) || ((self.lastNameTxt.text == "")) ||  ((self.birthDateTxt.text == ""))
        {
            if ((self.firstNameTxt.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "First Name field is required.")
            }
            else if ((self.lastNameTxt.text == ""))
            {
                self.ShowBanner(title: "", subtitle: "Last Name field is required.")
            }
        
            else
            {
                self.ShowBanner(title: "", subtitle: "Date of birth field is required.")
            }
        }
        else{
            updateProfile()
        }
        
    }
    
    //MARK:- @Service Api
      func updateProfile() {
          
       //   let userid = defaults.string(forKey: "resultDataId")!
          self.startAnimating()
        let para = ["firstName": firstNameTxt.text!,"lastName": lastNameTxt.text!,"email": userEmail  ,"contactNumber": self.userMobNo,"dob": birthDateTxt.text!,"bio": bioTxt.text!]
          print (para)
          ServiceClassMethods.AlamoRequest(method: "POST", serviceString: appConstants.kUpdateProfile, parameters: para as [String : Any]) { (dict) in
              print(dict)
              self.stopAnimating()
              let status = dict["status"] as? String
              self.stopAnimating()
              if(status == "true"){
                self.profileimage()
            
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
    @IBAction func backBtnClicked(_ sender: Any) {
  self.navigationController?.popViewController(animated: true)
    }
    

}
//@available(iOS 13.0, *)
extension UpdateProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.birthDateTxt {
            if #available(iOS 13.0, *) {
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
                    self?.birthDateTxt.text = selectedDate.dateString("dd-MMM-YYYY")
                    }
                }
            } else {
                // Fallback on earlier versions
            }
            return false
        }
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        bioTxtCountLbl.text = "\(count)/80"
        return count <= 79
    }
}

