//
//  ServiceClass.swift
//  ReplayMe
//
//  Created by Core Techies on 26/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Reachability
import BRYXBanner


class ServiceClassMethods: NSObject {
    

    class func AlamoRequest(method:String,serviceString:String,parameters:[String : Any]?,completion: @escaping (_ dict:NSDictionary) -> Void) {
        var json:NSDictionary!
       
        var server = Bool()
        let reachability = try? Reachability()
        switch reachability!.connection {
        case .wifi:
            server = true
            break
        case .cellular:
            server = true
            break
        case .none:
            server = false
            break
        case .unavailable:
            server = false
            break
        }
        
        let modifiedURLString = NSMutableString(format: "%@%@",appConstants.kBASE_URL,serviceString) as NSMutableString
        
        if server {
           
            if method == "POST" {
                
                var tokensStr =  UserDefaults.standard.string(forKey: "token")
               
                if tokensStr == nil {
                    tokensStr = ""
                }
                 let getTokenStr: String = tokensStr!
            let headerss = ["x-auth-key":getTokenStr ]
                Alamofire.request(modifiedURLString as String, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headerss).responseJSON { (response) in
                    if let JSON = response.result.value {
                        
                        json = JSON as? NSDictionary
                        completion(json)
                        
                    }
                    else {
                        print("It may be json Error or network error")
                        
                        _ = ["status" : "FAILURE","message" : "It seems network is slow!","requestKey" : serviceString]
                        _ = ActivityData()
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                            let banner = Banner(title: "It seems network is slow!")
                            banner.imageView.image = UIImage(named: "ic_info_outline.png")
                            banner.backgroundColor = UIColor(red: 43.0/255, green: 70.0/255, blue: 173.0/255, alpha: 1.0)
                            banner.dismissesOnTap = true
                            banner.show(duration: 3.0)
                        }
                        print("network error")
                    }
                }
                
            }
            else{
                
                var tokensStr =  UserDefaults.standard.string(forKey: "token")
               
                if tokensStr == nil {
                    tokensStr = ""
                }
                 let getTokenStr: String = tokensStr!
            let headerss = ["x-auth-key":getTokenStr ]
                Alamofire.request(modifiedURLString as String, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headerss).responseJSON { (response) in
                    if let JSON = response.result.value {
                        
                        json = JSON as? NSDictionary
                        
                        completion(json)
                        
                    }
                    else {
                        print("It may be json Error or network error")
                        
                        _ = ["status" : "FAILURE","message" : "It seems network is slow!","requestKey" : serviceString]
                        _ = ActivityData()
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                            let banner = Banner(title: "It seems network is slow!")
                            banner.imageView.image = UIImage(named: "ic_info_outline.png")
                            banner.backgroundColor = UIColor(red: 43.0/255, green: 70.0/255, blue: 173.0/255, alpha: 1.0)
                            banner.dismissesOnTap = true
                            banner.show(duration: 3.0)
                        }
                        print("network error")
                    }
                }
                
            }
            

        }
        else
        {
         NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            let banner = Banner(title: "Please check your internet connection and try again.")
            banner.show(duration: 3.0)
            print("network error")
        }
    }
    
}

