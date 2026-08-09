import Foundation
import Domain

/// The three identity facets that count toward a character's overall
/// completion: who they are in the hierarchy (role), the pattern they embody
/// (archetype), and the job they do for the plot (story function).
enum CharacterIdentityField: Int, CaseIterable, Identifiable {
    case role
    case archetype
    case storyFunction

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .role: return IdentityUIStrings.roleRow
        case .archetype: return IdentityUIStrings.archetypeRow
        case .storyFunction: return IdentityUIStrings.storyFunctionRow
        }
    }

    func isFilled(in identity: CharacterIdentity) -> Bool {
        switch self {
        case .role: return identity.role != nil
        case .archetype: return !identity.archetypes.isEmpty
        case .storyFunction: return !identity.storyFunctions.isEmpty
        }
    }

    /// How many identity facets the writer has chosen so far.
    static func filledCount(for identity: CharacterIdentity) -> Int {
        allCases.reduce(into: 0) { total, field in
            if field.isFilled(in: identity) { total += 1 }
        }
    }

    /// The first identity facet still waiting on a choice, if any.
    static func firstUnfilled(for identity: CharacterIdentity) -> CharacterIdentityField? {
        allCases.first { !$0.isFilled(in: identity) }
    }
}

/// Where the character header's "Next up" nudge should send the writer:
/// an identity row on the same screen, or a field inside the Arc editor.
enum CharacterProgressTarget: Equatable {
    case identity(CharacterIdentityField)
    case arc(CharacterArcField)

    var title: String {
        switch self {
        case .identity(let field): return field.title
        case .arc(let field): return field.title
        }
    }
}
