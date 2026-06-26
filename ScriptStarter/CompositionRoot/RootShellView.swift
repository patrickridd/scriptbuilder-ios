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

/// Structural shell around the Screenplays dashboard. Owns the
/// `NavigationStack` + toolbar so feature modules stay navigation-agnostic.
struct RootShellView: View {
    @Environment(\.appPalette) private var palette
    @State private var path: [RootRoute] = []

    let screenplaysConfig: ScreenplaysConfiguration
    let profileConfig: ProfileConfiguration
    let makeScreenplaysView: (ScreenplaysConfiguration) -> AnyView

    var body: some View {
        NavigationStack(path: $path) {
            makeScreenplaysView(screenplaysConfig)
                .navigationTitle("Screenplays")
                .toolbar { toolbar }
                .navigationDestination(for: RootRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(palette.brandPrimary)
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
        ToolbarItem(placement: .topBarLeading) {
            Button { path.append(.profile) } label: {
                Image(systemName: "person.crop.circle")
            }
            .accessibilityLabel("Profile")
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button { screenplaysConfig.onCreate() } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New Screenplay")
        }
    }
}
