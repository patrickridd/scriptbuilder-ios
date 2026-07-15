import Foundation

/// Interface-style preference surfaced in the profile's appearance picker.
/// Mirrors the legacy `InterfaceStyle` (system / light / dark) but stays a pure
/// value type so `FeatureProfile` doesn't depend on UIKit.
public enum ProfileInterfaceStyle: Int, CaseIterable, Sendable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .system: return L10n.Style.system
        case .light: return L10n.Style.light
        case .dark: return L10n.Style.dark
        }
    }

    public var symbolName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

/// Display data + app-level side-effects for `ProfileView`.
///
/// Account operations (change password, delete, verify email) are handled by an
/// injected `AuthService` inside `ProfileViewModel` — they are *not* here.
/// This configuration carries only the things the module shouldn't decide for
/// itself: identity to display, navigation/app-level closures (sign-out,
/// share), legal links, and the interface-style preference the app persists.
public struct ProfileConfiguration: Sendable {

    // MARK: - Display

    /// The user's display name (falls back to email or a friendly default
    /// upstream).
    public var displayName: String

    /// The user's email address, if available.
    public var email: String?

    /// Short text describing how the user signed in (e.g. "Apple", "Google").
    public var providerLabel: String?

    /// Number of screenplays the user has written, shown as a stat. Optional —
    /// hidden when `nil`.
    public var screenplayCount: Int?

    // MARK: - App-level closures

    /// Invoked when the user confirms "Sign Out". The shell decides what
    /// "signed out" means (routing back to login, clearing caches, etc.).
    public var onSignOut: @Sendable () -> Void

    /// Invoked after the account is successfully deleted, so the shell can route
    /// back to the login screen.
    public var onAccountDeleted: @Sendable () -> Void

    /// The current interface-style preference (system / light / dark).
    ///
    /// This is a *snapshot* captured when the configuration was built. Because
    /// the shell often builds the configuration once (at composition time) and
    /// reuses it across presentations, prefer `currentInterfaceStyle` to read
    /// the live persisted value each time the screen appears.
    public var interfaceStyle: ProfileInterfaceStyle

    /// Returns the *live* interface-style preference at call time. The app wires
    /// this to read from persistent storage so the picker always reflects the
    /// user's last choice, even when the configuration itself is a stale
    /// snapshot. Defaults to returning `interfaceStyle` when not provided.
    public var currentInterfaceStyle: @Sendable () -> ProfileInterfaceStyle

    /// Invoked when the user changes the interface style; the app persists it
    /// and applies it to the window.
    public var onInterfaceStyleChange: @Sendable (ProfileInterfaceStyle) -> Void

    // MARK: - Static content

    /// URL the "Share App" sheet points to (App Store listing).
    public var shareURL: URL?

    /// Privacy-policy link shown in the legal section.
    public var privacyPolicyURL: URL?

    /// Terms-of-use link shown in the legal section.
    public var termsURL: URL?

    /// Pre-formatted app version string shown quietly in the footer
    /// (e.g. "Version 1.0 (1)"). Hidden when `nil`. The app builds this from
    /// its bundle so the package stays free of app-target dependencies.
    public var appVersionText: String?

    public init(
        displayName: String,
        email: String? = nil,
        providerLabel: String? = nil,
        screenplayCount: Int? = nil,
        interfaceStyle: ProfileInterfaceStyle = .system,
        shareURL: URL? = nil,
        privacyPolicyURL: URL? = nil,
        termsURL: URL? = nil,
        appVersionText: String? = nil,
        onSignOut: @escaping @Sendable () -> Void,
        onAccountDeleted: @escaping @Sendable () -> Void = {},
        onInterfaceStyleChange: @escaping @Sendable (ProfileInterfaceStyle) -> Void = { _ in },
        currentInterfaceStyle: @escaping @Sendable () -> ProfileInterfaceStyle = { .system }
    ) {
        self.displayName = displayName
        self.email = email
        self.providerLabel = providerLabel
        self.screenplayCount = screenplayCount
        self.interfaceStyle = interfaceStyle
        self.shareURL = shareURL
        self.privacyPolicyURL = privacyPolicyURL
        self.termsURL = termsURL
        self.appVersionText = appVersionText
        self.onSignOut = onSignOut
        self.onAccountDeleted = onAccountDeleted
        self.onInterfaceStyleChange = onInterfaceStyleChange
        self.currentInterfaceStyle = currentInterfaceStyle
    }

    /// First-letter initials for the avatar monogram.
    public var initials: String {
        let parts = displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
        let joined = parts.joined().uppercased()
        return joined.isEmpty ? "?" : joined
    }
}
