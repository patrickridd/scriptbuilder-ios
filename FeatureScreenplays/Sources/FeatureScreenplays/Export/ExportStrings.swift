import Foundation

extension L10n {
    /// Section headers and field labels used by the PDF / plain-text export.
    ///
    /// These follow the app's language: an export is the writer's own working
    /// document, so a French user gets French headings. Scene sluglines and the
    /// writer's own prose are of course never touched.
    enum Export {
        private static func str(_ key: String, _ fallback: String) -> String {
            L10n.string("export.\(key)", default: fallback)
        }

        // Title page
        static var untitled: String { str("untitled", "Untitled") }
        static func writtenBy(_ author: String) -> String {
            String(format: str("writtenBy", "Written by %@"), author)
        }
        static var logline: String { str("logline", "Logline") }

        // Overview
        static var overview: String { str("section.overview", "Overview") }
        static var idea: String { str("idea", "Idea") }
        static var theme: String { str("theme", "Theme") }
        static var centralIntention: String { str("centralIntention", "Central Intention") }
        static var mainObstacle: String { str("mainObstacle", "Main Obstacle") }
        static var notes: String { str("notes", "Notes") }

        // Outline
        static var outline: String { str("section.outline", "Outline") }

        // Characters
        static var characters: String { str("section.characters", "Characters") }
        static var unnamedCharacter: String { str("unnamedCharacter", "Unnamed Character") }
        static var role: String { str("role", "Role") }
        static var intention: String { str("intention", "Intention") }
        static var why: String { str("why", "Why") }
        static var whatTheyDo: String { str("whatTheyDo", "What They Do") }
        static var howTheyDoIt: String { str("howTheyDoIt", "How They Do It") }
        static var obstacles: String { str("obstacles", "Obstacles") }
        static var flaws: String { str("flaws", "Flaws") }
        static var intentionFix: String { str("intentionFix", "Intention Fix") }
        static var need: String { str("need", "Need") }
        static var howTheyChange: String { str("howTheyChange", "How They Change") }

        // Scenes
        static var scenes: String { str("section.scenes", "Scenes") }
        static var header: String { str("header", "Header") }
        static var description: String { str("description", "Description") }
        static var dialogue: String { str("dialogue", "Dialogue") }
        static var action: String { str("action", "Action") }
        static var storyProgression: String { str("storyProgression", "Story Progression") }
    }
}
