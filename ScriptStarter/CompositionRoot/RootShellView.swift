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

/// The destinations the shell can push onto its navigation stack.
enum RootRoute: Hashable {
    case profile
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
}

/// Structural shell around the Screenplays dashboard. Owns the
/// `NavigationStack` + toolbar so feature modules stay navigation-agnostic.
struct RootShellView: View {
    @Environment(\.appPalette) private var palette
    @StateObject private var router = RootRouter()

    let screenplaysConfig: ScreenplaysConfiguration
    let profileConfig: ProfileConfiguration
    let authService: any AuthService
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
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { screenplaysConfig.onCreate(router.screenplayCount) } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New Screenplay")
        }
    }
}
