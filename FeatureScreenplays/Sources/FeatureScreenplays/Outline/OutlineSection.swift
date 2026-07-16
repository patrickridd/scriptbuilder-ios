import Foundation
import Domain

/// The four navigable parts of an outline: the Idea plus the three acts. Drives
/// both the hub cards and the detail editor. Ported from the legacy UIKit
/// `OutlineSection`, but bound to the pure-Swift `Screenplay` value type.
///
/// This is pure presentation data — no SwiftUI dependency — so it can be unit
/// tested directly and reused by the `OutlineViewModel` without importing the
/// view layer.
public enum OutlineSection: Int, CaseIterable, Identifiable, Sendable {
    case idea, actOne, actTwo, actThree

    public var id: Int { rawValue }

    /// Stable, locale-independent key used to build localization lookups.
    public var key: String {
        switch self {
        case .idea:     return "idea"
        case .actOne:   return "actOne"
        case .actTwo:   return "actTwo"
        case .actThree: return "actThree"
        }
    }

    public var title: String {
        L10n.Outline.sectionTitle(self)
    }

    public var subtitle: String {
        L10n.Outline.sectionSubtitle(self)
    }

    public var systemImage: String {
        switch self {
        case .idea:     return "lightbulb.fill"
        case .actOne:   return "1.circle.fill"
        case .actTwo:   return "2.circle.fill"
        case .actThree: return "3.circle.fill"
        }
    }

    public var placeholder: String {
        L10n.Outline.sectionPlaceholder(self)
    }

    /// The act this section maps to, if any (Idea has none).
    public var act: Act? {
        switch self {
        case .idea:     return nil
        case .actOne:   return .one
        case .actTwo:   return .two
        case .actThree: return .three
        }
    }

    /// The "overall description" outline field for act sections.
    public var descriptionField: OutlineField? {
        switch self {
        case .idea:     return nil
        case .actOne:   return .actOneDescription
        case .actTwo:   return .actTwoDescription
        case .actThree: return .actThreeDescription
        }
    }
}
