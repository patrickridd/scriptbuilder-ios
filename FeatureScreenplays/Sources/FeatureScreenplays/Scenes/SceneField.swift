import Foundation
import Domain

/// The six free-form sections of a `Scene`, paired with the section title,
/// guiding prompt, and SF Symbol used in the scene detail form. Mirrors the
/// legacy `Scene.sceneTitles` / `Scene.sceneSubtitles` 1:1 but binds directly
/// to the pure Swift `Scene` value type.
enum SceneField: Int, CaseIterable, Identifiable {
    case sceneDescription
    case characters
    case dialogue
    case action
    case howPushesStory
    case notes

    var id: Int { rawValue }

    /// Stable, locale-independent key used to build the localization lookup.
    var key: String {
        switch self {
        case .sceneDescription: return "description"
        case .characters: return "characters"
        case .dialogue: return "dialogue"
        case .action: return "action"
        case .howPushesStory: return "storyProgression"
        case .notes: return "notes"
        }
    }

    var title: String {
        L10n.Scene.title(self)
    }

    var prompt: String {
        L10n.Scene.prompt(self)
    }

    var systemImage: String {
        switch self {
        case .sceneDescription: return "text.alignleft"
        case .characters: return "person.2.fill"
        case .dialogue: return "quote.bubble"
        case .action: return "figure.run"
        case .howPushesStory: return "arrow.forward.circle"
        case .notes: return "note.text"
        }
    }

    /// The sections that count toward a scene's completion. `notes` is a
    /// free-form scratchpad, so it is deliberately excluded.
    static var scoreable: [SceneField] {
        allCases.filter { $0 != .notes }
    }

    /// How many scoreable sections the writer has filled in.
    static func filledCount(for scene: Scene) -> Int {
        scoreable.reduce(into: 0) { total, field in
            let text = field.value(in: scene).trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty { total += 1 }
        }
    }

    /// The first scoreable section still empty — drives the "Next up: …" nudge.
    static func firstUnfilled(for scene: Scene) -> SceneField? {
        scoreable.first {
            $0.value(in: scene).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func value(in scene: Scene) -> String {        switch self {
        case .sceneDescription: return scene.sceneDescription
        case .characters: return scene.characters
        case .dialogue: return scene.dialogue
        case .action: return scene.action
        case .howPushesStory: return scene.howPushesStory
        case .notes: return scene.notes
        }
    }
}
