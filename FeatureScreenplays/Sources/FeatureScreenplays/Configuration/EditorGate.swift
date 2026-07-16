import Foundation
import Combine

/// A lightweight, StoreKit-free entitlement change signal. The composition
/// root drives this whenever the user's purchase state changes (a purchase
/// completes, a restore lands, or a subscription expires), so the editor views
/// can re-evaluate the gate and re-render — even while they're on screen.
///
/// Keeping this in the feature package (rather than importing the app's
/// `Store`) preserves the module boundary: the feature knows *that*
/// entitlements can change, not *how* they're sourced.
public final class EditorEntitlementSignal: ObservableObject, @unchecked Sendable {
    /// Bumps to force observers to re-evaluate. The value itself is meaningless;
    /// SwiftUI just needs the `@Published` change to trigger a re-render.
    @Published public private(set) var revision = 0

    public init() {}

    /// Call from the main actor when entitlements change.
    @MainActor
    public func entitlementsDidChange() {
        revision &+= 1
    }
}

/// Injected free-tier gating for the in-editor "add" actions (characters and
/// scenes), so `FeatureScreenplays` stays free of IAP / StoreKit knowledge.
///
/// The composition root supplies the decisions (based on the user's
/// entitlements and the free-tier limits) and the paywall presentation. Each
/// add-site asks the gate whether it may create; if not, it calls `onBlocked`
/// to surface the paywall instead of creating the entity.
///
/// The default value permits everything, so previews and tests behave as if
/// the user has full access without any wiring.
public struct EditorGate: Sendable {

    /// Whether the user may add another character, given the count that
    /// already exist in this screenplay. `true` allows creation.
    public var canAddCharacter: @Sendable (_ existingCount: Int) -> Bool

    /// Whether the user may add another scene, given the total scene count
    /// (across all acts) that already exist in this screenplay. `true` allows
    /// creation.
    public var canAddScene: @Sendable (_ existingCount: Int) -> Bool

    /// Called when an add action is blocked, so the host can present the
    /// paywall. Runs on the main actor.
    public var onBlocked: @Sendable () -> Void

    /// Emits whenever the user's entitlements change. Editor views observe this
    /// so their locked/unlocked chrome updates live after a purchase, restore,
    /// or expiration — without needing to be dismissed and re-opened.
    public let entitlementSignal: EditorEntitlementSignal

    public init(
        canAddCharacter: @escaping @Sendable (_ existingCount: Int) -> Bool = { _ in true },
        canAddScene: @escaping @Sendable (_ existingCount: Int) -> Bool = { _ in true },
        onBlocked: @escaping @Sendable () -> Void = {},
        entitlementSignal: EditorEntitlementSignal = EditorEntitlementSignal()
    ) {
        self.canAddCharacter = canAddCharacter
        self.canAddScene = canAddScene
        self.onBlocked = onBlocked
        self.entitlementSignal = entitlementSignal
    }

    /// A gate that never blocks — the default used by previews and tests.
    public static let unrestricted = EditorGate()
}
