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
            GADMobileAds.configure(withApplicationID: GoogleAds.applicationId)
            
            // Reset Ad Rewarded features
            resetAdRewardedFeatures()
            
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
        ScreenplayController.shared.resetCurrentScreenplay()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController else {
            return
        }
        
        self.window?.rootViewController = mainNavigationController
        self.window?.makeKeyAndVisible()
    }
    
    func presentNewCharacter() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let screenplayCoverVC = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController,
            let screenplayTabBar = screenplayCoverVC.orderedViewControllers[1] as? ScreenplayTabBarController,
            let characterNavigationController = screenplayTabBar.viewControllers?[1] as? UINavigationController,
            let characterTableViewController = characterNavigationController.viewControllers[0] as? CharacterTableViewController
        else {
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
        let mainStoryboard = UIStoryboard(name: "Main",
                                          bundle: nil)
        guard
            let screenplayCoverVC = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController,
            let screenplayTabBar = screenplayCoverVC.orderedViewControllers[1] as? ScreenplayTabBarController,
            let sceneNavigationController = screenplayTabBar.viewControllers?[2] as? UINavigationController,
            let scenesTableViewController =  sceneNavigationController.viewControllers[0] as? ScenesTableViewController
        else {
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
            
            let screenplay = Screenplay(title: "Untitled".localized)
            ScreenplayController.shared.set(currentScreenplay: screenplay)
            self.window?.rootViewController = screenplayCoverVC
            self.window?.makeKeyAndVisible()
        }
    }
    
    func resetAdRewardedFeatures() {
        // If user terminates app expire Character builder trial
        UserDefaults.standard.set(false,
                                  forKey: Constants.characterBuilderRewardEnabled)
       
        // If user terminates app expire Scene builder trial
        UserDefaults.standard.set(false,
                                  forKey: Constants.sceneBuilderTrialType)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        // Handles both Facebook and Google

      let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) ||   GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)

        return handled
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            
            let handled = FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                                open: url,
                                                                                options: options) || GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
            return handled
    }
    
}

