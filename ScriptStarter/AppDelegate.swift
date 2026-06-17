//
//  AppDelegate.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import AuthDomain
import Domain
import UIKit
import FeatureAuth
import FirebaseAuth
import FirebaseAuthData
import FirebaseDatabase
import FBSDKCoreKit
import GoogleSignIn
import StoreKit
import FirebaseCore
import SwiftUI

enum Shortcut: String {
    case newIdea = "newIdea"
    case newScene = "newScene"
    case newCharacter = "newCharacter"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let firebaseAuthService = FirebaseAuthData.FirebaseAuthService()

    var isLoggedIn: Bool {
        return AccessToken.current != nil || Auth.auth().currentUser != nil
    }
    
    var window: UIWindow?
    
    private lazy var authConfiguration: AuthConfiguration = {
        AuthConfiguration(
            appName: "Script Builder",
            loginSubtitle: "From your screen to the silver screen",
            signUpSubtitle: "Create your account to start writing",
            loginFooterPrompt: "New to Script Builder?",
            loginProviders: [.apple, .google, .facebook],   // existing users can still log in with Facebook
            signUpProviders: [.apple, .google]               // Facebook phased out for new sign-ups
        )
    }()

    private lazy var loginView: UIHostingController<AuthFlowView> = {
        let authFlowView = AuthFlowView(
            config: authConfiguration,
            service: firebaseAuthService
        ) { [weak self] user in
            self?.presentScreenplayCollectionView()
        }
        return UIHostingController(rootView: authFlowView)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool {
        
        // One call: configures Firebase + Google Sign-In from GoogleService-Info.plist.
        FirebaseAuthService.configure()
        
        // Facebook (legacy) — supported entry point.
        FirebaseAuthService.configureFacebook(application: application, launchOptions: launchOptions)
        
        // App-specific concern, NOT auth: keep it, but it's yours to own.
        FirebaseDatabase.Database.database().isPersistenceEnabled = true
        
        // Routing decision via the contract — no Firebase types here.
        if firebaseAuthService.currentUser != nil {
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
        self.window?.rootViewController = loginView
        makeKeyAndVisible()
    }
    
    @discardableResult
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

