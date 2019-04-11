//
//  AppDelegate.swift
//  Driveway
//
//  Created by imac on 4/28/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import SVProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        SVProgressHUD.setDefaultMaskType(.black)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        monitorReachability()
        
        GMSServices.provideAPIKey("AIzaSyBi1B8nj-Cl8NWeGny5rt0oJFL9WEd1GOA")
        GMSPlacesClient.provideAPIKey("AIzaSyBi1B8nj-Cl8NWeGny5rt0oJFL9WEd1GOA")
        
        IQKeyboardManager.sharedManager().enable = true
        
        if let tutorial = UserDefaults.standard.value(forKey: "tutorial") as? Bool, tutorial == true {
            gotoViewController(id: "loginnvc", storyboardName: "Login")
        } else {
            gotoViewController(id: "tutorialvc")
            
            do {
                try Auth.auth().signOut()
            } catch {
                
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        if !handled {
            handled = GIDSignIn.sharedInstance().handle(url,
                                                        sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                        annotation: [:])
        }
        
        return handled
    }
    
    func monitorReachability() {
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                //                isOnline = true
                if reachability.connection == .wifi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            
            DispatchQueue.main.async {
                //                isOnline = false
                print("Not reachable")
            }
        }
        do {
            
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

