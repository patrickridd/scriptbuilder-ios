import Foundation
import Domain

/// The identity facets that count toward a character's overall completion:
/// what they're called (name), who they are in the hierarchy (role), the
/// pattern they embody (archetype), and the job they do for the plot
/// (story function).
enum CharacterIdentityField: Int, CaseIterable, Identifiable {
    case name
    case role
    case archetype
    case storyFunction

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .name: return L10n.CharacterUI.fieldName
        case .role: return IdentityUIStrings.roleRow
        case .archetype: return IdentityUIStrings.archetypeRow
        case .storyFunction: return IdentityUIStrings.storyFunctionRow
        }
    }

    func isFilled(in character: Character) -> Bool {
        switch self {
        case .name:
            return !character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .role:
            return character.identity.role != nil
        case .archetype:
            return !character.identity.archetypes.isEmpty
        case .storyFunction:
            return !character.identity.storyFunctions.isEmpty
        }
    }

    /// How many identity facets the writer has settled so far.
    static func filledCount(for character: Character) -> Int {
        allCases.reduce(into: 0) { total, field in
            if field.isFilled(in: character) { total += 1 }
        }
    }

    /// The first identity facet still waiting on the writer, if any.
    static func firstUnfilled(for character: Character) -> CharacterIdentityField? {
        allCases.first { !$0.isFilled(in: character) }
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
