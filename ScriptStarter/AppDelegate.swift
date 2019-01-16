//
//  AppDelegate.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import GoogleMobileAds

enum Shortcut: String {
    case newIdea = "newIdea"
    case newScene = "newScene"
    case newCharacter = "newCharacter"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var isLoggedIn: Bool {
        return FBSDKAccessToken.current() != nil || FIRAuth.auth()?.currentUser != nil
    }
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {
            
            // Configure Firebase
            FIRApp.configure()
            
            // Enable offline persistence
            FIRDatabase.database().persistenceEnabled = true
            
            // Initialize Facebook sign-in
            FBSDKApplicationDelegate.sharedInstance().application(application)
            
            // Initialize Google sign-in            
            GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
            
            // Initialize GoogleMobileAds
            GADMobileAds.configure(withApplicationID: "ca-app-pub-1297096402264538~9994351234")
            
            if isLoggedIn {
                // User is logged in so present their screenplays
                self.presentScreenplayCollectionView()
            } else {
                self.presentLoginScreen()
            }
            
            return true
    }
    

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem: shortcutItem))
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        if !isLoggedIn {
            self.presentLoginScreen()
            return false
        }
        
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
        
            switch shortcutType {
            case .newIdea:
                self.presentNewScreenplayIdea()
                quickActionHandled = true
            case .newScene:
                self.presentNewScene()
                quickActionHandled = true

            case .newCharacter:
                self.presentNewCharacter()
                quickActionHandled = true
            }
        }
        
        return quickActionHandled
    }
    
    // MARK: - Navigation
    
    func presentLoginScreen() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController {
            self.window?.rootViewController = loginVC
        }
        self.window?.makeKeyAndVisible()
    }
    
    func presentScreenplayCollectionView() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else {
            return
        }
        
        self.window?.rootViewController = mainNavigationController
        self.window?.makeKeyAndVisible()
    }
    
    func presentNewScreenplayIdea() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController else {
           // let screenplayCoverVC =  mainNavigationController.viewControllers[1] as? ScreenplayPageViewController else {
            return
        }
       
        self.window?.rootViewController = mainNavigationController
        self.window?.makeKeyAndVisible()
    }
    
    func presentNewCharacter() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let screenplayCoverVC = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController,
            let screenplayTabBar = screenplayCoverVC.orderedViewControllers[1] as? ScreenplayTabBarController,
            let characterNavigationController = screenplayTabBar.viewControllers?[1] as? UINavigationController,
             let characterTableViewController =  characterNavigationController.viewControllers[0] as? CharacterTableViewController else {
            return
        }
        
        screenplayCoverVC.swipedLeft()
        screenplayTabBar.selectedIndex = 1
        characterTableViewController.newCharacter = true
        FirebaseController.shared.getScreenplays { (screenplays) in
            if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: screenplays) {
                ScreenplayController.shared.set(currentScreenplay: screenplay)
                self.window?.rootViewController = screenplayCoverVC
                self.window?.makeKeyAndVisible()
                return
            }
            
            let screenplay = Screenplay(title: "Untitled")
            ScreenplayController.shared.set(currentScreenplay: screenplay)
            self.window?.rootViewController = screenplayCoverVC
            self.window?.makeKeyAndVisible()
        }
    }
    
    func presentNewScene() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let screenplayCoverVC = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController,
            let screenplayTabBar = screenplayCoverVC.orderedViewControllers[1] as? ScreenplayTabBarController,
            let sceneNavigationController = screenplayTabBar.viewControllers?[2] as? UINavigationController,
            let scenesTableViewController =  sceneNavigationController.viewControllers[0] as? ScenesTableViewController else {
                return
        }
        
        screenplayCoverVC.swipedLeft()
        screenplayTabBar.selectedIndex = 2
        scenesTableViewController.newScene = true
        FirebaseController.shared.getScreenplays { (screenplays) in
            if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: screenplays) {
                ScreenplayController.shared.set(currentScreenplay: screenplay)
                self.window?.rootViewController = screenplayCoverVC
                self.window?.makeKeyAndVisible()
                return
            }
            
            let screenplay = Screenplay(title: "Untitled")
            ScreenplayController.shared.set(currentScreenplay: screenplay)
            self.window?.rootViewController = screenplayCoverVC
            self.window?.makeKeyAndVisible()
        }
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        // Handles both Facebook and Google
        
      let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) ||   GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        
        return handled
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
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


}

