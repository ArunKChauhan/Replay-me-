//
//  AppDelegate.swift
//  ReplayMe
//
//  Created by Core Techies on 24/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import GoogleSignIn
import FBSDKCoreKit
import AWSCognito
import AWSS3
import AWSCore
import Firebase
import FirebaseCore
import FirebaseAnalytics
import Crashlytics
import TwitterKit

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {

var window: UIWindow?

    var isLandscape = false
    
    var showCamera = true
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
            return self.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.showCamera = true
        Thread.sleep(forTimeInterval: 3)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
         FirebaseApp.configure()
          GIDSignIn.sharedInstance().clientID = "861497831299-l8mvter9abufssi9cpe061havv592lm4.apps.googleusercontent.com"
        TWTRTwitter.sharedInstance().start(withConsumerKey:"rw3Opi4sXSlTEPk4JfVwG0lMG", consumerSecret:"lycW6qzd0x0JwRDlGxuumBz0XAB7bG0NwNIFecvWRytK43ow9F")
         IQKeyboardManager.shared.enable = true
         Fabric.sharedSDK().debug = true
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
        
           ApplicationDelegate.shared.application(
                 application,
                 didFinishLaunchingWithOptions: launchOptions
             )
        
       
         return true
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
                      let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
                      print(deviceTokenString)
                      let defaults = UserDefaults.standard
                      //defaults.set(deviceTokenString, forKey: defaultsKeyDeviceToken.deviceTokenKey)
                      
                      
                  }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
                       print("i am not available in simulator \(error)")
                      // let defaults = UserDefaults.standard
                      // defaults.set("", forKey: defaultsKeyDeviceToken.deviceTokenKey)
                   }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      let application = UIApplication.shared
      
      if(application.applicationState == .active){
        print("user tapped the notification bar when the app is in foreground")
        
      }
      
      if(application.applicationState == .inactive)
      {
        print("user tapped the notification bar when the app is in background")
      }
    
        
      completionHandler()
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String?] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict as [AnyHashable : Any])
        let token = Messaging.messaging().fcmToken
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }
    // MARK: UISceneSession Lifecycle
    func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if app.applicationState == .inactive || app.applicationState == .active || app.applicationState == .background
        {
            
            print("krishna")
            
            
        }
       
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         
         
         
         completionHandler([.alert, .badge, .sound])
         
     }
     
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RecordVideo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        print(orientation.rawValue)
        if (orientation.rawValue == 3 || orientation.rawValue == 4)
        {
            isLandscape = true
            NotificationCenter.default.post(name: Notification.Name("OnOrientationChange"), object: nil)
        }
        else if (orientation.rawValue == 1 || orientation.rawValue == 2)
        {
            isLandscape = false
            NotificationCenter.default.post(name: Notification.Name("OnOrientationChange"), object: nil)
        }
        
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: HandleURL GIDSignIn
  
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        var signedIn: Bool = GIDSignIn.sharedInstance().handle(url)
        
        signedIn = signedIn ? signedIn :      ApplicationDelegate.shared.application(
                   app,
                   open: url,
                   sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                   annotation: options[UIApplication.OpenURLOptionsKey.annotation]
               )
        let twitterDidHandle = TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        return signedIn || twitterDidHandle
    }
    

    
//    func application(
//      _ application: UIApplication,
//      continue userActivity: NSUserActivity,
//      restorationHandler: @escaping ([UIUserActivityRestoring]?
//    ) -> Void) -> Bool {
//      
//      // 1
//      guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//        let url = userActivity.webpageURL,
//        let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//          return false
//      }
//        
//        print("url...components...", url, components)
//      
//      // 2
////      if let computer = ItemHandler.sharedInstance.items
////        .filter({ $0.path == components.path}).first {
////        presentDetailViewController(computer)
////        return true
////      }
////
//      // 3
//      if let webpageUrl = URL(string: "http://rw-universal-links-final.herokuapp.com") {
//        application.open(webpageUrl)
//        return false
//      }
//      
//      return false
//    }
//    
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//        print("Continue User Activity called: ")
//        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
//            let url = userActivity.webpageURL!
//            print(url.absoluteString)
//            //handle url and open whatever page you want to open.
//        }
//        return true
//    }
    
//    func initializeS3(){
//        let poolId = "ap-south-1:76f1b98d-f558-44eb-9446-a40b3119c128"
//        let credentialsProvider = AWSCognitoCredentialsProvider(
//            regionType: .APSouth1,
//            identityPoolId: poolId
//        )
//        let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
//    }
  
    func applicationWillEnterForeground(_ application: UIApplication) {
          // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
      }
}

