//
//  AppDelegate.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import AuthDomain
import Domain
import DesignSystem
import UIKit
import FeatureAuth
import FeatureScreenplays
import FeatureProfile
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

    /// App-wide logger injected at the composition root. Packages depend only
    /// on `Domain.AppLogger`; this is the concrete OS-backed implementation.
    let logger: AppLogger = SystemLogger(category: "Gate")

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
        return FirebaseData.FirebaseScreenplayRepository(
            uidProvider: { box.uid },
            logger: SystemLogger(category: "Repository")
        )
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
        } else if isSimulatorAuthBypassEnabled {
            // Seed a placeholder uid so the repository can resolve.
            if uidBox.uid == nil { uidBox.uid = "simulator-preview-user" }
            presentHome()
        } else {
            presentLoginScreen()
        }

        return true
    }

    /// Debug-only escape hatch so the dashboard (and its chrome) can be
    /// inspected on the Simulator without a real signed-in session. Firebase
    /// sign-in cannot complete on a fresh Simulator, so this lets us verify UI
    /// like the hero header / toolbar. Never active on device or in release.
    private var isSimulatorAuthBypassEnabled: Bool {
        #if targetEnvironment(simulator) && DEBUG
        return true
        #else
        return false
        #endif
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

    /// Presents the modern SwiftUI experience as the root after login. The
    /// app-level `RootShellView` owns the navigation chrome and hosts the
    /// chrome-free `ScreenplaysView`; the profile (with sign-out) is pushed
    /// from the shell's toolbar. Side-concerns (open / create / sign-out) are
    /// wired back into the existing storyboard navigation via closures.
    func presentHome() {
        let user = firebaseAuthService.currentUser
        let displayName = user?.displayName ?? "Writer"

        // Gating rule: the first screenplay is always free. Every screenplay
        // beyond index 0 is gated until the user has all-access. Lifetime
        // owners pass `allAccessEnabled` automatically, so they're never gated.
        let freeScreenplayLimit = 1
        logger.info("Gate: presentHome allAccessEnabled=\(Store.shared.allAccessEnabled) [forever=\(Store.shared.unlimitedForeverEnabled) monthly=\(Store.shared.unlimitedMonthlyEnabled) yearly=\(Store.shared.unlimitedYearlyEnabled) char=\(Store.shared.characterFeatureEnabled) scene=\(Store.shared.sceneFeatureEnabled)]")
        let isIndexRestricted: @Sendable (Int) -> Bool = { index in
            index >= freeScreenplayLimit && !Store.shared.allAccessEnabled
        }

        let screenplaysConfig = ScreenplaysConfiguration(
            userDisplayName: displayName,
            isRestricted: isIndexRestricted,
            onOpen: { [weak self] screenplay, rank in
                // The first screenplay (most-recently-updated, rank 0) is always
                // free. Anything past the free limit is gated until all-access.
                // `rank` comes from the same recency-sorted list the dashboard
                // renders, so the gate matches exactly what the user sees.
                DispatchQueue.main.async {
                    guard let self else { return }
                    let gated = rank >= freeScreenplayLimit && !Store.shared.allAccessEnabled
                    self.logger.debug("Gate(onOpen): \(screenplay.title) rank=\(rank) gated=\(gated)")
                    if gated {
                        self.presentPaywallOverCurrent()
                    } else {
                        // Not gated: let the SwiftUI shell own navigation and
                        // push the new cover → editor flow. We intentionally do
                        // NOT swap the window root to the legacy editor here.
                        self.logger.debug("onOpen: handing off to SwiftUI shell for \(screenplay.title)")
                    }
                }
            },
            onCreate: { [weak self] existingCount in
                // Creating a new screenplay beyond the free limit triggers the
                // paywall; the first one is always free. `existingCount` is the
                // dashboard's current count, so no separate fetch is needed.
                DispatchQueue.main.async {
                    guard let self else { return }
                    let gated = existingCount >= freeScreenplayLimit && !Store.shared.allAccessEnabled
                    self.logger.debug("Gate(onCreate): existingCount=\(existingCount) gated=\(gated)")
                    if gated {
                        self.presentPaywallOverCurrent()
                    } else {
                        self.presentNewScreenplayIdea()
                    }
                }
            }
        )

        let profileConfig = ProfileConfiguration(
            displayName: displayName,
            email: user?.email,
            providerLabel: user?.linkedProviders.first.map { $0.rawValue.capitalized },
            interfaceStyle: currentProfileInterfaceStyle(),
            shareURL: URL(string: "https://apps.apple.com/app/id1234567890"),
            privacyPolicyURL: URL(string: "https://www.scriptbuilderapp.com/_files/ugd/b622d0_f5722cd213394590bbd181559a0af540.pdf"),
            termsURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
            onSignOut: { [weak self] in
                DispatchQueue.main.async { self?.signOutToLogin() }
            },
            onAccountDeleted: { [weak self] in
                DispatchQueue.main.async { self?.signOutToLogin() }
            },
            onInterfaceStyleChange: { [weak self] style in
                DispatchQueue.main.async { self?.applyProfileInterfaceStyle(style) }
            }
        )

        let repository: ScreenplayRepository = isSimulatorAuthBypassEnabled
            ? MockScreenplayRepository()
            : firebaseRepository
        let shell = RootShellView(
            screenplaysConfig: screenplaysConfig,
            profileConfig: profileConfig,
            authService: firebaseAuthService,
            makeScreenplaysView: { config, namespace in
                AnyView(ScreenplaysView(
                    repository: repository,
                    config: config,
                    transitionNamespace: namespace
                ))
            },
            makeScreenplayContainer: { screenplay, onDelete in
                AnyView(ScreenplayContainerView(
                    screenplay: screenplay,
                    repository: repository,
                    onDelete: onDelete
                ))
            }
        )
        .appPalette(.default)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UIHostingController(rootView: shell)
        makeKeyAndVisible()
    }

    /// Presents the SwiftUI paywall over whatever is currently on screen (the
    /// live SwiftUI shell). We intentionally do NOT swap the window's root —
    /// `present(_:)` only works when the presenter is already in the view
    /// hierarchy, which the existing shell is. Finds the top-most presented
    /// controller and presents the paywall there.
    @MainActor
    func presentPaywallOverCurrent() {
        guard let root = window?.rootViewController else {
            logger.error("Gate: no rootViewController to present paywall over")
            return
        }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        logger.info("Gate: presenting paywall over \(type(of: top))")
        top.presentIAPSubscriptionView()
    }

    /// Signs the user out via `FirebaseAuthService` and returns to the login
    /// screen. Clears any cached current screenplay so the next session starts
    /// clean.
    func signOutToLogin() {
        do {
            try firebaseAuthService.signOut()
        } catch {
            logger.error("Sign-out failed: \(error.localizedDescription)")
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

    // MARK: - Profile interface style bridging

    /// Maps the persisted legacy `InterfaceStyle` to the SwiftUI-facing
    /// `ProfileInterfaceStyle` shown in the profile's appearance picker.
    private func currentProfileInterfaceStyle() -> ProfileInterfaceStyle {
        let raw = UserDefaults().integer(forKey: InterfaceStyle.userDefaultsKey)
        switch InterfaceStyle(rawValue: raw) ?? .defaultSelected {
        case .defaultSelected: return .system
        case .lightModeSelected: return .light
        case .darkModeSelected: return .dark
        }
    }

    /// Persists the user's chosen appearance and applies it live to the window,
    /// reusing the same `InterfaceStyle` machinery the legacy Settings used.
    private func applyProfileInterfaceStyle(_ style: ProfileInterfaceStyle) {
        let legacy: InterfaceStyle
        switch style {
        case .system: legacy = .defaultSelected
        case .light: legacy = .lightModeSelected
        case .dark: legacy = .darkModeSelected
        }
        UserDefaults().set(legacy.rawValue, forKey: InterfaceStyle.userDefaultsKey)
        UIApplication.shared.set(style: legacy)
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
