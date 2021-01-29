//
//  SceneDelegate.swift
//  ReplayMe
//
//  Created by Core Techies on 24/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import TwitterKit
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    //  SceneDelegate.swift

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        if let openURLContext = URLContexts.first{
          let url = openURLContext.url
            print(url)
          let options: [AnyHashable : Any] = [
            UIApplication.OpenURLOptionsKey.annotation : openURLContext.options.annotation as Any,
            UIApplication.OpenURLOptionsKey.sourceApplication : openURLContext.options.sourceApplication as Any,
            UIApplication.OpenURLOptionsKey.openInPlace : openURLContext.options.openInPlace
          ]
         
            if TWTRTwitter.sharedInstance().application(UIApplication.shared, open: url, options: options) {
                TWTRTwitter.sharedInstance().application(UIApplication.shared, open: url, options: options)
                return
            }
            ApplicationDelegate.shared.application(
                   UIApplication.shared,
                   open: url,
                   sourceApplication: nil,
                   annotation: [UIApplication.OpenURLOptionsKey.annotation]
                   
               )
            
        }


   
    }

func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    print("Krishna...")
    
    
//    self.window = UIWindow(frame: UIScreen.main.bounds)
//
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//    let initialViewController = storyboard.instantiateViewController(withIdentifier: "MyProfileViewController")
//
//    self.window?.rootViewController = initialViewController
//    self.window?.makeKeyAndVisible()
//    
//    self.window = UIWindow(frame: UIScreen.main.bounds)

    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
    let navigationController = UINavigationController.init(rootViewController: viewController)
    self.window?.rootViewController = navigationController

    self.window?.makeKeyAndVisible()
    
    
     guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
              //return false
                return
          }
            
            //print("url...components...Path...", url, components,components.path)
    print("Path...", components.path)
             // 3
          if let webpageUrl = URL(string: "http://rw-universal-links-final.herokuapp.com") {
          //  application.open(webpageUrl)
           // return false
          }
          
         // return false
    }
}

