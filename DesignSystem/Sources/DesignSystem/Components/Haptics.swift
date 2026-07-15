import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Centralized, lightweight haptic feedback helper so every feature can fire
/// consistent tactile cues with a single call. No-ops on platforms without
/// UIKit so shared code stays cross-platform safe.
public enum Haptics {

    /// UserDefaults key backing the global on/off preference.
    private static let enabledKey = "haptics.enabled"

    /// Whether tactile feedback is enabled app-wide. Defaults to `true` when the
    /// user has never chosen — every generator call checks this first, so a
    /// single toggle silences the entire app.
    public static var isEnabled: Bool {
        get {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: enabledKey) == nil { return true }
            return defaults.bool(forKey: enabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledKey)
        }
    }

    /// A gentle tap — ideal for confirming a lightweight creative action like
    /// spinning up a new draft.
    @MainActor
    public static func lightImpact() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    /// A firmer "are you sure" pulse for destructive confirmations like
    /// deleting a script, scene, or character.
    @MainActor
    public static func warning() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
        #endif
    }

    /// A celebratory double-tap for completed flows like a successful purchase,
    /// restore, or account update.
    @MainActor
    public static func success() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }

    /// A crisp tick for discrete selection changes like toggling appearance
    /// mode or switching a segmented control.
    @MainActor
    public static func selection() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }
}
