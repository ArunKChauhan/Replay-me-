//
//  LicenseKeyViewController.swift
//  GhostECC
//
//  Created by Diksha on 03/06/17.
//  Copyright © 2017 Core Techies. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner


enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6_7          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P_7P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}


extension UIViewController {
    
    func validateEmail(address: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: address)
    }
    
    func ShowBanner (title: String, subtitle: String)
    {
        if title == "Message"
        {
            let banner = Banner(title: title, subtitle: subtitle, image: UIImage(named: "ic_message.png") ,backgroundColor: UIColor(red: 246.0/255, green: 127.0/255, blue: 1.0/255, alpha: 1.0))
            banner.dismissesOnTap = true
            banner.minimumHeight = 80
            banner.show(duration: 4.0)
        }
        else if title == "Alert"
        {
            let banner = Banner(title: title, subtitle: subtitle, image: UIImage(named: "ic_error_icon.png"),backgroundColor: UIColor(red: 225.0/255, green: 0.0/255, blue: 68.0/255, alpha: 1.0))
            banner.dismissesOnTap = true
            banner.textColor = UIColor.white
            banner.minimumHeight = 80
            banner.show(duration: 4.0)
        }
        else if title == ""
        {
            let banner = Banner(title: title, subtitle: subtitle, image: UIImage(named: "ic_info_outline.png"),backgroundColor: UIColor(red: 43.0/255, green: 70.0/255, blue: 173.0/255, alpha: 1.0))
            banner.dismissesOnTap = true
            banner.textColor = UIColor.white
            banner.minimumHeight = 80
            banner.show(duration: 3.0)
        }
        else
        {
            let banner = Banner(title: title, subtitle: subtitle ,image: UIImage(named: "ic_info_outline.png"),backgroundColor: UIColor(red: 43.0/255, green: 70.0/255, blue: 173.0/255, alpha: 1.0))
            banner.dismissesOnTap = true
            banner.minimumHeight = 80
            banner.show(duration: 3.0)
        }
    }
    func ShadowView(viewToModify: UIView) {
        viewToModify.layer.shadowColor = UIColor(red: 219/255, green: 227/255, blue: 238/255, alpha: 1.0).cgColor
        viewToModify.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewToModify.layer.shadowOpacity = 8.0
        viewToModify.layer.shadowRadius = 10.0
        viewToModify.layer.masksToBounds = false
        viewToModify.layer.cornerRadius = 2.0
        viewToModify.layer.borderWidth = 0.8
        viewToModify.layer.borderColor = UIColor(red: 222/255, green: 228/255, blue: 233/255, alpha: 1.0).cgColor
    }
    func isValidPassword(testStr:String) -> Bool {
        
        let emailRegEx = "^((?=.*?[A-Z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{6,})"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidName(testStr:String) -> Bool {
        
        let nameRegEx = "^([ A-Za-z0-9_.-]+$)"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: testStr)
    }
    
    func updateTextFieldFormatting(field: UITextField, placeholder: String) {
        //        field.autocapitalizationType = .allCharacters
        field.attributedPlaceholder? = NSAttributedString(string: placeholder.uppercased(), attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 204/255, green: 205/255, blue: 11/255, alpha: 0.75)])
    }
    
    
    func isPasswordSame(password: String , confirmPassword : String) -> Bool {
        if password == confirmPassword{
            return true
        }
        else{
            return false
        }
    }
    
    func donePicker () {
        
        self.view.endEditing(true)
    }
    
    func cancelPicker () {
        self.view.endEditing(true)
    }
    func dropShadowView(viewToModify: UIView) {
        viewToModify.layer.shadowColor = UIColor(red: 219/255, green: 227/255, blue: 238/255, alpha: 1.0).cgColor
        viewToModify.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewToModify.layer.shadowOpacity = 8.0
        viewToModify.layer.shadowRadius = 5.0
        viewToModify.layer.masksToBounds = false
    }
    @IBAction func callPressed(sender: UIButton)
    {
        self.view.endEditing(true)
        let url = URL(string: String(format:"tel://%@","+92-42-35784255"))
        UIApplication.shared.open(url!)
        
    }
    @IBAction func homeBtnPressed(sender: UIButton)
    {
        self.view .endEditing(true)
    }
}

extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension UITextView {
    
}

//MARK:- @IBOutlets
//MARK:- Variables
//MARK:- Location Manager
//MARK:- ViewController LifeCycle
//MARK:- Notification Center Methods
//MARK:- Service Calls Response
//MARK:- Class Methods
//MARK:- Action Methods
//MARK:- TableView Delegate Methods
