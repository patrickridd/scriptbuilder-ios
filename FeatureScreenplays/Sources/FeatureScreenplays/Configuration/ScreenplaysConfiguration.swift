import Foundation
import Domain

/// Injected side-concerns for `ScreenplaysView`. Keeps `FeatureScreenplays`
/// free of IAP, navigation, and persistence knowledge — the composition root
/// (or the app-level shell) wires the behavior in via closures.
public struct ScreenplaysConfiguration: Sendable {

    /// Greeting name shown in the hero header.
    public var userDisplayName: String

    /// Returns `true` if the screenplay at the given index should be gated
    /// (e.g. behind an in-app purchase). Defaults to never restricted.
    public var isRestricted: @Sendable (Int) -> Bool

    /// Invoked when the user taps a screenplay to open it. `rank` is the
    /// screenplay's position in the full, recency-sorted list (0 = most
    /// recent), so the host can apply quota gating against the same ordering
    /// the dashboard renders — independent of any active search filter.
    public var onOpen: @Sendable (_ screenplay: Screenplay, _ rank: Int) -> Void

    /// Invoked when the user taps the "+" / create action. `existingCount` is
    /// the number of screenplays currently in the list, so the host can decide
    /// whether a new one would exceed the free quota.
    public var onCreate: @Sendable (_ existingCount: Int) -> Void

    /// Invoked when the user taps the hero header to open their profile.
    public var onOpenProfile: @Sendable () -> Void

    /// Invoked whenever the loaded screenplay count changes, so an outer shell
    /// (which owns its own "+" toolbar button) can gate creation against the
    /// same count the dashboard sees. Defaults to a no-op.
    public var onCountChange: @Sendable (_ count: Int) -> Void

    public init(
        userDisplayName: String,
        isRestricted: @escaping @Sendable (Int) -> Bool = { _ in false },
        onOpen: @escaping @Sendable (_ screenplay: Screenplay, _ rank: Int) -> Void,
        onCreate: @escaping @Sendable (_ existingCount: Int) -> Void,
        onOpenProfile: @escaping @Sendable () -> Void = {},
        onCountChange: @escaping @Sendable (_ count: Int) -> Void = { _ in }
    ) {
        self.userDisplayName = userDisplayName
        self.isRestricted = isRestricted
        self.onOpen = onOpen
        self.onCreate = onCreate
        self.onOpenProfile = onOpenProfile
        self.onCountChange = onCountChange
    }
}
