//
//  RootShellView.swift
//  ScriptStarter
//
//  App-level navigation shell. Owns the structural chrome — the
//  `NavigationStack`, navigation title, and toolbar — and hosts the
//  chrome-free feature views (`ScreenplaysView`, `ProfileView`) inside it.
//
//  The shell is a *dumb container*: it holds the navigation path and maps
//  routes to destinations, but contains no auth / persistence logic. When
//  routing grows (deep links, notification-driven navigation), a dedicated
//  `RootCoordinator` (@Observable) can own the path + route decisions and the
//  shell would simply observe it. Until then this small enum is enough.
//

import SwiftUI
import DesignSystem
import FeatureScreenplays
import FeatureProfile
import AuthDomain
import Domain

/// The destinations the shell can push onto its navigation stack.
enum RootRoute: Hashable {
    case profile
    /// The paged cover → editor container shown when a screenplay is opened.
    case screenplay(Screenplay)

    static func == (lhs: RootRoute, rhs: RootRoute) -> Bool {
        switch (lhs, rhs) {
        case (.profile, .profile): return true
        case let (.screenplay(a), .screenplay(b)): return a.id == b.id
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .profile:
            hasher.combine("profile")
        case .screenplay(let s):
            hasher.combine("screenplay")
            hasher.combine(s.id)
        }
    }
}

/// Holds the navigation path so closures handed to feature modules can drive
/// navigation without capturing the SwiftUI `View` value type. Lives for the
/// lifetime of the shell via `@StateObject`.
final class RootRouter: ObservableObject, @unchecked Sendable {
    @Published var path: [RootRoute] = []
    @Published var isProfilePresented = false

    /// Latest screenplay count reported by `ScreenplaysView`, so the shell's
    /// own "+" toolbar button can gate creation against the same count.
    @Published var screenplayCount = 0

    func openProfile() {
        isProfilePresented = true
    }

    func openScreenplay(_ screenplay: Screenplay) {
        path.append(.screenplay(screenplay))
    }
}

/// Structural shell around the Screenplays dashboard. Owns the
/// `NavigationStack` + toolbar so feature modules stay navigation-agnostic.
struct RootShellView: View {
    @Environment(\.appPalette) private var palette
    @StateObject private var router = RootRouter()
    // Observe the purchase store so the dashboard re-renders when entitlements
    // finish loading asynchronously at launch (or change after a purchase /
    // restore). Without this the lock badges captured `Store.shared` but had no
    // SwiftUI dependency on its `@Published` state, so they showed stale locks
    // on already-unlocked scripts until some unrelated re-render cleared them.
    @ObservedObject private var store = Store.shared
    @Namespace private var coverTransition

    let screenplaysConfig: ScreenplaysConfiguration
    let profileConfig: ProfileConfiguration
    let authService: any AuthService
    let makeScreenplaysView: (ScreenplaysConfiguration, Namespace.ID) -> AnyView
    /// Builds the paged cover → editor container for an opened screenplay,
    /// injecting the repository and a pop-on-delete callback.
    let makeScreenplayContainer: (Screenplay, @escaping () -> Void) -> AnyView
    /// Creates + persists a brand-new screenplay and returns it so the shell
    /// can open it in the SwiftUI editor. Called only when creation is *not*
    /// gated (the host runs the paywall check first via `onCreate`).
    let makeNewScreenplay: () -> Screenplay

    var body: some View {
        NavigationStack(path: $router.path) {
            makeScreenplaysView(shellConfig, coverTransition)
                .navigationTitle("Screenplays")
                .toolbar { toolbar }
                .navigationDestination(for: RootRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(palette.brandPrimary)
        .fullScreenCover(isPresented: $router.isProfilePresented) {
            profileSheet
        }
    }

    /// Profile presented modally, wrapped in its own navigation stack so it
    /// keeps a title bar and a Done button to dismiss.
    private var profileSheet: some View {
        let router = router
        return NavigationStack {
            ProfileView(config: profileConfig, service: authService)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            router.isProfilePresented = false
                        }
                    }
                }
        }
        .tint(palette.brandPrimary)
    }

    /// The screenplays config with the shell's profile-navigation wired in,
    /// so tapping the hero header pushes the profile route.
    private var shellConfig: ScreenplaysConfiguration {
        var config = screenplaysConfig
        let router = router
        let hostOnOpen = screenplaysConfig.onOpen
        let hostOnCreate = screenplaysConfig.onCreate
        let makeNew = makeNewScreenplay
        config.onOpen = { @Sendable screenplay, rank in
            // Host handles side-concerns (logging, quota gating / paywall).
            hostOnOpen(screenplay, rank)
            // Only drive the cinematic push when the screenplay isn't gated —
            // a gated tap shows the paywall instead of the cover.
            guard !screenplaysConfig.isRestricted(rank) else { return }
            DispatchQueue.main.async { router.openScreenplay(screenplay) }
        }
        config.onCreate = { @Sendable count in
            // Host decides gating (shows the paywall when over the free limit).
            hostOnCreate(count)
            // When not gated, create + persist a fresh screenplay and open it
            // in the SwiftUI editor.
            guard !screenplaysConfig.isRestricted(count) else { return }
            DispatchQueue.main.async { router.openScreenplay(makeNew()) }
        }
        config.onOpenProfile = { @Sendable in
            DispatchQueue.main.async { router.openProfile() }
        }
        config.onCountChange = { @Sendable count in
            DispatchQueue.main.async { router.screenplayCount = count }
        }
        return config
    }

    @ViewBuilder
    private func destination(for route: RootRoute) -> some View {
        switch route {
        case .profile:
            EmptyView()
        case .screenplay(let screenplay):
            makeScreenplayContainer(screenplay) {
                DispatchQueue.main.async {
                    if !router.path.isEmpty { router.path.removeLast() }
                }
            }
            .screenplayZoomDestination(id: screenplay.id, in: coverTransition)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { shellConfig.onCreate(router.screenplayCount) } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New Screenplay")
        }
    }
}
