//
//  AppDelegate.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Domain
import UIKit
import FirebaseAuth
import FBSDKCoreKit
import GoogleSignIn
import StoreKit
import FirebaseCore
import FirebaseDatabaseInternal

enum Shortcut: String {
    case newIdea = "newIdea"
    case newScene = "newScene"
    case newCharacter = "newCharacter"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var isLoggedIn: Bool {
        return AccessToken.current != nil || Auth.auth().currentUser != nil
    }
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {

            // Configure Firebase
            FirebaseApp.configure()

            // Enable offline persistence
            Database.database().isPersistenceEnabled = true

            // Initialize Facebook sign-in
            ApplicationDelegate.shared.application(application,
                                                   didFinishLaunchingWithOptions: launchOptions)

            // Initialize Google sign-in
            let clientId = FirebaseApp.app()!.options.clientID!
            let config = GIDConfiguration(clientID: clientId)

            GIDSignIn.sharedInstance.configuration = config

            if isLoggedIn {
                // User is logged in so present their screenplays
                _ = presentScreenplayCollectionView()
            } else {
                presentLoginScreen()
            }

            return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name.AppWillEnterForeground,
                                        object: nil)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem: shortcutItem))
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        if !isLoggedIn {
            self.presentLoginScreen()
            return false
        }
        
        if !Store.shared.allAccessEnabled {
            allAccessFeatureTriggered()
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
        makeKeyAndVisible()
    }
    
    func presentScreenplayCollectionView() -> UINavigationController? {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else {
            return nil
        }
        
        self.window?.rootViewController = mainNavigationController
        makeKeyAndVisible()
        return mainNavigationController
    }

    func allAccessFeatureTriggered() {
        let collectionViewController = presentScreenplayCollectionView()
        let screenplayCollectionView = collectionViewController?.viewControllers.first as? ScreenplayCollectionViewController
        screenplayCollectionView?.presentIAPSubscriptionView()
    }

    func presentNewScreenplayIdea() {
        ScreenplayController.shared.resetCurrentScreenplay()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController else {
            return
        }

        self.window?.rootViewController = mainNavigationController
        makeKeyAndVisible()
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
        FirebaseController.shared.getScreenplays { [weak self] (screenplays) in
            if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: screenplays) {
                ScreenplayController.shared.set(currentScreenplay: screenplay)
                self?.window?.rootViewController = screenplayCoverVC
                self?.window?.makeKeyAndVisible()
                return
            }
            let name = Auth.auth().currentUser?.displayName ?? "Name"
            let screenplay = Screenplay(title: "Untitled", authorName: name)
            ScreenplayController.shared.set(currentScreenplay: screenplay)
            self?.window?.rootViewController = screenplayCoverVC
            self?.makeKeyAndVisible()
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
        FirebaseController.shared.getScreenplays { [weak self] (screenplays) in
            if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: screenplays) {
                ScreenplayController.shared.set(currentScreenplay: screenplay)
                self?.window?.rootViewController = screenplayCoverVC
                self?.window?.makeKeyAndVisible()
                return
            }
            
            let name = Auth.auth().currentUser?.displayName ?? "Name"
            let screenplay = Domain.Screenplay(title: "Untitled".localized, authorName: name)
            ScreenplayController.shared.set(currentScreenplay: screenplay)
            self?.window?.rootViewController = screenplayCoverVC
            self?.makeKeyAndVisible()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handles both Facebook and Google
        let handledByFB = ApplicationDelegate.shared.application(app, open: url, options: options)
        let handledByGoogle = GIDSignIn.sharedInstance.handle(url)
        return handledByFB || handledByGoogle
    }
    
    func makeKeyAndVisible() {
        self.window?.makeKeyAndVisible()
        determineInterfaceStyle()
    }

    func determineInterfaceStyle() {
        let interfaceStyleRawValue = UserDefaults().integer(forKey: InterfaceStyle.userDefaultsKey)
        let interfaceStyle = InterfaceStyle(rawValue: interfaceStyleRawValue) ?? .defaultSelected
        UIApplication.shared.set(style: interfaceStyle)
    }
}


extension UIApplication {
    
    var mainWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last
    }

    var interfaceStyle: UIUserInterfaceStyle? {
        mainWindow?.overrideUserInterfaceStyle
    }
    
    func set(style: InterfaceStyle) {
        mainWindow?.overrideUserInterfaceStyle = style.systemInterfaceStyle
    }
}
