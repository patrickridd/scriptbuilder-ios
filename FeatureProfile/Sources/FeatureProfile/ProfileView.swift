import SwiftUI
import UIKit
import DesignSystem
import AuthDomain

/// The user's profile screen — identity hero, appearance, account management
/// (change password, verify email, share, legal), and a destructive danger
/// zone (sign out / delete account).
///
/// Like `ScreenplaysView`, this view is **chrome-free**: an app-level shell
/// provides the `NavigationStack` and title. Display data + app-level
/// side-effects arrive via `ProfileConfiguration`, while sensitive account
/// operations are driven by an injected `AuthService` (the protocol only) held
/// in a `ProfileViewModel`.
public struct ProfileView: View {
    @Environment(\.appPalette) private var palette
    @State private var viewModel: ProfileViewModel
    @State private var interfaceStyle: ProfileInterfaceStyle
    private let config: ProfileConfiguration

    /// - Parameters:
    ///   - config: Display data and app-level closures.
    ///   - service: The auth backend used for account operations. Inject a
    ///     concrete `AuthService` (e.g. `FirebaseAuthService`) from the
    ///     composition root, or `MockAuthService` in tests/previews.
    public init(config: ProfileConfiguration, service: any AuthService) {
        self.config = config
        _viewModel = State(initialValue: ProfileViewModel(service: service))
        _interfaceStyle = State(initialValue: config.interfaceStyle)
    }

    public var body: some View {
        ZStack {
            AppBackground()
            scrollContent
        }
        .onAppear {
            viewModel.refresh()
            // Re-sync the picker from the live persisted preference so it always
            // reflects the user's last choice, even when the configuration is a
            // stale snapshot captured at composition time.
            interfaceStyle = config.currentInterfaceStyle()
        }
        .alert(L10n.Alert.error, isPresented: errorBinding) {
            Button(L10n.Action.ok, role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert(L10n.Alert.done, isPresented: successBinding) {
            Button(L10n.Action.ok, role: .cancel) { viewModel.successMessage = nil }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .onChange(of: viewModel.successMessage) { _, message in
            if message != nil { Haptics.success() }
        }
        .onChange(of: viewModel.errorMessage) { _, message in
            if message != nil { Haptics.warning() }
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileHeaderCard(config: config, liveName: viewModel.user?.displayName)
                accountSettingsRow
                AppearanceCard(selection: $interfaceStyle, onChange: config.onInterfaceStyleChange)
                HapticsCard()
                accountActions
                dangerZone
                versionFooter
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
            case .accountSettings:
                AccountSettingsView(viewModel: viewModel)
            }
        }
    }

    private var accountSettingsRow: some View {
        NavigationLink(value: ProfileRoute.accountSettings) {
            SettingsRow(
                icon: "person.text.rectangle.fill",
                title: L10n.Row.accountDetails,
                subtitle: accountDetailsSubtitle
            )
        }
        .buttonStyle(.plain)
    }

    private var accountDetailsSubtitle: String {
        viewModel.needsEmailVerification
            ? L10n.Row.accountDetailsSubtitleFull
            : L10n.Row.accountDetailsSubtitleNamePassword
    }

    private var accountActions: some View {
        AccountActionsCard(
            shareURL: config.shareURL,
            privacyURL: config.privacyPolicyURL,
            termsURL: config.termsURL
        )
    }

    private var dangerZone: some View {
        DangerZoneCard(
            isWorking: viewModel.isWorking,
            onSignOut: config.onSignOut,
            onDelete: {
                if await viewModel.deleteAccount() {
                    config.onAccountDeleted()
                }
            }
        )
    }

    @ViewBuilder
    private var versionFooter: some View {
        if let versionText = config.appVersionText {
            Button {
                UIPasteboard.general.string = versionText
                Haptics.selection()
            } label: {
                Text(versionText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.A11y.appVersion(versionText))
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var successBinding: Binding<Bool> {
        Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } }
        )
    }
}
