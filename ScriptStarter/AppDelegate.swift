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
import FeatureHome
import FirebaseAuthData
import FirebaseData
import StoreKit
import SwiftUI

enum Shortcut: String {
    case newIdea = "newIdea"
    case newScene = "newScene"
    case newCharacter = "newCharacter"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let firebaseAuthService = FirebaseAuthData.FirebaseAuthService()

    /// The signed-in user's id, read live by the repository on every RTDB call.
    /// Kept in a reference box so the `@Sendable` closure captures a stable
    /// pointer rather than a `@State` value.
    private let uidBox = UIDBox()

    /// Holds the long-lived task consuming `authStateStream()` so it keeps
    /// running for the app's lifetime rather than being cancelled immediately.
    private var authStateTask: Task<Void, Never>?
    
    /// Builds a live `FirebaseScreenplayRepository` scoped to the signed-in user.
    lazy public var firebaseRepository: ScreenplayRepository = {
        let box = uidBox
        return FirebaseData.FirebaseScreenplayRepository(uidProvider: { box.uid })
    }()

    var isLoggedIn: Bool {
        firebaseAuthService.currentUser != nil
    }
    
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
            self?.uidBox.uid = user.id
            self?.presentHome()
        }
        return UIHostingController(rootView: authFlowView)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool {
        
        // One call: configures Firebase + Google Sign-In from GoogleService-Info.plist.
        FirebaseAuthService.configure()
        
        // Facebook (legacy) — supported entry point.
        FirebaseAuthService.configureFacebook(application: application, launchOptions: launchOptions)

        FirebaseDataPersistence.enableDiskPersistence()

        // Keep the repository's uid in sync with the *actual* Firebase session.
        // This covers a session restored on launch (when the sign-in callback
        // never fires) as well as fresh sign-in and sign-out — without it the
        // repository's `requireUID()` throws `notAuthenticated` on relaunch.
        startObservingAuthState()

        // Routing decision via the contract — no Firebase types here.
        if isLoggedIn {
            presentHome()
        } else {
            presentLoginScreen()
        }

        return true
    }

    /// Mirrors the live Firebase auth state into `uidBox` so the repository
    /// always reads the correct uid. Seeds synchronously from the restored
    /// session first, then keeps it current via the state-change listener.
    private func startObservingAuthState() {
        // Seed synchronously from the restored session via the contract.
        uidBox.uid = firebaseAuthService.currentUser?.id

        // Keep current via the service's auth-state stream, which bridges
        // Firebase's `addStateDidChangeListener` under the hood.
        authStateTask = Task { [weak self] in
            guard let stream = self?.firebaseAuthService.authStateStream() else { return }
            for await user in stream {
                self?.uidBox.uid = user?.id
            }
        }
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

    /// Presents the modern SwiftUI `HomeView` (FeatureHome) as the root after
    /// login, replacing the legacy `presentScreenplayCollectionView()` route.
    /// Side-concerns (open / create) are wired back into the existing
    /// storyboard navigation so the rest of the app keeps working.
    func presentHome() {
        let displayName = firebaseAuthService.currentUser?.displayName ?? "Writer"
        let config = HomeConfiguration(
            userDisplayName: displayName,
            isRestricted: { _ in
                !Store.shared.allAccessEnabled
            },
            onOpen: { [weak self] screenplay in
                DispatchQueue.main.async { self?.openScreenplay(screenplay) }
            },
            onCreate: { [weak self] in
                DispatchQueue.main.async { self?.presentNewScreenplayIdea() }
            },
            onSignOut: { [weak self] in
                DispatchQueue.main.async { self?.signOutToLogin() }
            }
        )

        let homeView = HomeView(repository: firebaseRepository, config: config)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UIHostingController(rootView: homeView)
        makeKeyAndVisible()
    }

    /// Signs the user out via `FirebaseAuthService` and returns to the login
    /// screen. Clears any cached current screenplay so the next session starts
    /// clean.
    func signOutToLogin() {
        do {
            try firebaseAuthService.signOut()
        } catch {
            NSLog("Sign-out failed: \(error.localizedDescription)")
        }
        ScreenplayController.shared.resetCurrentScreenplay()
        presentLoginScreen()
    }

    /// Opens an existing screenplay in the legacy editor flow.
    func openScreenplay(_ screenplay: Domain.Screenplay) {
        ScreenplayController.shared.set(currentScreenplay: screenplay)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let screenplayCoverVC = mainStoryboard.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController else {
            return
        }
        self.window?.rootViewController = screenplayCoverVC
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
            let name = self?.firebaseAuthService.currentUser?.displayName ?? "Name"
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
            
            let name = self?.firebaseAuthService.currentUser?.displayName ?? "Name"
            let screenplay = Domain.Screenplay(title: "Untitled".localized, authorName: name)
            ScreenplayController.shared.set(currentScreenplay: screenplay)
            self?.window?.rootViewController = screenplayCoverVC
            self?.makeKeyAndVisible()
        }
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

// MARK: - UIDBox

/// Thread-safe holder for the current user's id. The repository's
/// `uidProvider` closure is `@Sendable` and may be invoked off the main actor
/// (e.g. inside an RTDB observer), so access is guarded by a lock.
final class UIDBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _uid: String?

    var uid: String? {
        get { lock.withLock { _uid } }
        set { lock.withLock { _uid = newValue } }
    }
}
