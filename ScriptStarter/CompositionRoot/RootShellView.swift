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

/// The destinations the shell can push onto its navigation stack.
enum RootRoute: Hashable {
    case profile
}

/// Holds the navigation path so closures handed to feature modules can drive
/// navigation without capturing the SwiftUI `View` value type. Lives for the
/// lifetime of the shell via `@StateObject`.
final class RootRouter: ObservableObject, @unchecked Sendable {
    @Published var path: [RootRoute] = []

    func openProfile() {
        if path.last != .profile { path.append(.profile) }
    }
}

/// Structural shell around the Screenplays dashboard. Owns the
/// `NavigationStack` + toolbar so feature modules stay navigation-agnostic.
struct RootShellView: View {
    @Environment(\.appPalette) private var palette
    @StateObject private var router = RootRouter()

    let screenplaysConfig: ScreenplaysConfiguration
    let profileConfig: ProfileConfiguration
    let makeScreenplaysView: (ScreenplaysConfiguration) -> AnyView

    var body: some View {
        NavigationStack(path: $router.path) {
            makeScreenplaysView(shellConfig)
                .navigationTitle("Screenplays")
                .toolbar { toolbar }
                .navigationDestination(for: RootRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(palette.brandPrimary)
    }

    /// The screenplays config with the shell's profile-navigation wired in,
    /// so tapping the hero header pushes the profile route.
    private var shellConfig: ScreenplaysConfiguration {
        var config = screenplaysConfig
        let router = router
        config.onOpenProfile = { @Sendable in
            DispatchQueue.main.async { router.openProfile() }
        }
        return config
    }

    @ViewBuilder
    private func destination(for route: RootRoute) -> some View {
        switch route {
        case .profile:
            ProfileView(config: profileConfig)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { screenplaysConfig.onCreate() } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New Screenplay")
        }
    }
}
