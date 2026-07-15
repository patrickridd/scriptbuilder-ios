import SwiftUI
import UIKit
import FeatureAuth
import FeatureHome
import DesignSystem
import FirebaseAuthData
import FirebaseData
import Domain
import AuthDomain

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseAuthService.configure()
        FirebaseAuthService.configureFacebook(application: application, launchOptions: launchOptions)
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        FirebaseAuthService.handleOpenURL(url, options: options)
    }
}

// MARK: - App

@main
struct FeatureAuthDemoApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let service = FirebaseAuthService()
    @State private var currentUser: AuthUser?

    /// The signed-in user's id, read live by the repository on every RTDB call.
    /// Kept in a reference box so the `@Sendable` closure captures a stable
    /// pointer rather than a `@State` value.
    private let uidBox = UIDBox()

    var body: some SwiftUI.Scene {
        WindowGroup {
            content
                .task { await observeAuthState() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let currentUser {
            authenticatedHome(for: currentUser)
        } else {
            AuthFlowView(
                config: authConfiguration,
                service: service
            ) { user in
                NSLog("FeatureAuth: authenticated as \(user.email ?? user.displayName ?? user.id)")
                uidBox.uid = user.id
                currentUser = user
            }
        }
    }

    private func authenticatedHome(for user: AuthUser) -> some View {
        let repo = makeRepository()
        return HomeView(
            repository: repo,
            config: makeHomeConfig(for: user, repository: repo)
        )
        .appPalette(.default)
        .overlay(alignment: .topLeading) {
            signOutButton
        }
    }

    private var signOutButton: some View {
        Button {
            try? service.signOut()
            uidBox.uid = nil
            currentUser = nil
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(10)
                .background(.black.opacity(0.25), in: Circle())
        }
        .padding(.leading, 16)
        .padding(.top, 8)
    }

    private func makeHomeConfig(
        for user: AuthUser,
        repository repo: ScreenplayRepository
    ) -> HomeConfiguration {
        let name = user.displayName ?? user.email ?? "there"
        return HomeConfiguration(
            userDisplayName: name,
            isRestricted: { _ in false },
            onOpen: { screenplay, _ in
                NSLog("Home: open screenplay \(screenplay.title)")
            },
            onCreate: { _ in
                Task {
                    let draft = Screenplay(
                        title: "Untitled Draft",
                        authorName: "Me",
                        logLine: "A new story waiting to be told.",
                        theme: "Discovery"
                    )
                    try? await repo.save(draft)
                }
            }
        )
    }

    /// Single source of truth for the session. Honors a Firebase session that
    /// was restored on launch (so `uidBox.uid` is populated before any RTDB
    /// call) and keeps the uid in sync on every subsequent auth change.
    private func observeAuthState() async {
        // Seed immediately from the restored session so the repository has a
        // uid even before the listener's first emission.
        if let restored = service.currentUser {
            uidBox.uid = restored.id
            if currentUser == nil { currentUser = restored }
        }
        for await user in service.authStateStream() {
            uidBox.uid = user?.id
            currentUser = user
        }
    }

    /// Builds a live `FirebaseScreenplayRepository` scoped to the signed-in user.
    private func makeRepository() -> ScreenplayRepository {
        let box = uidBox
        return FirebaseScreenplayRepository(uidProvider: { box.uid })
    }

    // MARK: - Auth config

    private var authConfiguration: AuthConfiguration {
        AuthConfiguration(
            appName: "Script Builder",
            loginSubtitle: "From your screen to the silver screen",
            signUpSubtitle: "Create your account to start writing",
            loginFooterPrompt: "New to Script Builder?",
            loginProviders: [.apple, .google, .facebook],   // existing users can still log in with Facebook
            signUpProviders: [.apple, .google]               // Facebook phased out for new sign-ups
        )
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
