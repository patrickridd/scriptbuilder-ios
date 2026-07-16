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

    func value(in scene: Scene) -> String {
        switch self {
        case .sceneDescription: return scene.sceneDescription
        case .characters: return scene.characters
        case .dialogue: return scene.dialogue
        case .action: return scene.action
        case .howPushesStory: return scene.howPushesStory
        case .notes: return scene.notes
        }
    }
}
