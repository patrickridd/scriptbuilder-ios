import Foundation
import Observation
import Domain
import SwiftUI

/// Owns the outline for one screenplay: the Idea section, the three act overall
/// descriptions, and every per-act narrative beat. Mirrors the debounced
/// autosave pattern used by `SceneDetailViewModel` — mutating any bound field
/// schedules a scoped, non-destructive save on the correct repository method:
///
///  - `OutlineField` values (Idea + `act*Description`) → `updateOutline(_:of:)`
///  - `ActBeatField` values (per-act beats) → `updateActBeats(_:in:of:)`
///
/// Only the changed field is persisted, so sibling data is never touched.
@MainActor
@Observable
public final class OutlineViewModel {

    /// The live working copy every field binds to.
    private(set) var screenplay: Screenplay

    var errorMessage: String?

    @ObservationIgnored private let screenplayID: String
    @ObservationIgnored private let repository: ScreenplayRepository
    @ObservationIgnored private let debounce: Duration
    @ObservationIgnored private var saveTasks: [String: Task<Void, Never>] = [:]

    /// Fired exactly once each time the outline *transitions* into a fully
    /// complete state (every section 100% filled). The app layer treats this
    /// as a "moment of delight" for a possible review prompt. Edge-triggered so
    /// ongoing edits within a complete outline don't spam it.
    @ObservationIgnored var onOutlineCompleted: (() -> Void)?

    /// Whether the outline was already fully complete before the latest edit,
    /// so we only fire `onOutlineCompleted` on the incomplete→complete edge.
    @ObservationIgnored private var wasFullyComplete: Bool

    public init(
        screenplay: Screenplay,
        repository: ScreenplayRepository,
        debounce: Duration = .milliseconds(500)
    ) {
        self.screenplay = screenplay
        self.screenplayID = screenplay.uuid
        self.repository = repository
        self.debounce = debounce
        self.wasFullyComplete =
            OutlineSection.allCases.allSatisfy { section in
                let progress = Self.filledCount(for: section, in: screenplay)
                return progress.total > 0 && progress.filled == progress.total
            }
    }

    /// Re-evaluates full completion after an edit and fires
    /// `onOutlineCompleted` only on the incomplete→complete transition.
    private func evaluateCompletionEdge() {
        let nowComplete = overallCompletion >= 0.999
        defer { wasFullyComplete = nowComplete }
        guard nowComplete, !wasFullyComplete else { return }
        onOutlineCompleted?()
    }

    // MARK: - Idea + act descriptions (OutlineField)

    /// A `Binding` for an outline text field that writes through to the draft
    /// and schedules a debounced `updateOutline` save.
    func binding(for field: OutlineField) -> Binding<String> {
        Binding(
            get: { self.value(for: field) },
            set: { newValue in
                self.setValue(newValue, for: field)
                self.scheduleOutlineSave(field, value: newValue)
                self.evaluateCompletionEdge()
            }
        )
    }

    private func value(for field: OutlineField) -> String {
        switch field {
        case .idea:                return screenplay.idea
        case .logLine:             return screenplay.logLine
        case .notes:               return screenplay.notes
        case .theme:               return screenplay.theme
        case .centralIntention:    return screenplay.centralIntention
        case .mainObstacle:        return screenplay.mainObstacle
        case .actOneDescription:   return screenplay.actOneDescription
        case .actTwoDescription:   return screenplay.actTwoDescription
        case .actThreeDescription: return screenplay.actThreeDescription
        case .title:               return screenplay.title
        case .authorName:          return screenplay.authorName ?? ""
        }
    }

    private func setValue(_ value: String, for field: OutlineField) {
        switch field {
        case .idea:                screenplay.idea = value
        case .logLine:             screenplay.logLine = value
        case .notes:               screenplay.notes = value
        case .theme:               screenplay.theme = value
        case .centralIntention:    screenplay.centralIntention = value
        case .mainObstacle:        screenplay.mainObstacle = value
        case .actOneDescription:   screenplay.actOneDescription = value
        case .actTwoDescription:   screenplay.actTwoDescription = value
        case .actThreeDescription: screenplay.actThreeDescription = value
        case .title:               screenplay.title = value
        case .authorName:          screenplay.authorName = value
        }
    }

    private func scheduleOutlineSave(_ field: OutlineField, value: String) {
        let key = "outline.\(field.rawValue)"
        saveTasks[key]?.cancel()
        saveTasks[key] = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled, let self else { return }
            do { try await self.repository.updateOutline([field: value], of: self.screenplayID) }
            catch { self.errorMessage = error.localizedDescription }
        }
    }

    // MARK: - Per-act beats (ActBeatField)

    /// A `Binding` for a narrative beat that writes through to the draft and
    /// schedules a debounced `updateActBeats` save on the beat's own act.
    func binding(for beat: ActBeatField) -> Binding<String> {
        Binding(
            get: { beat.value(in: self.screenplay) },
            set: { newValue in
                beat.apply(newValue, to: &self.screenplay)
                self.scheduleBeatSave(beat, value: newValue)
                self.evaluateCompletionEdge()
            }
        )
    }

    private func scheduleBeatSave(_ beat: ActBeatField, value: String) {
        let key = "beat.\(beat.rawValue)"
        saveTasks[key]?.cancel()
        saveTasks[key] = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled, let self else { return }
            do { try await self.repository.updateActBeats([beat: value], in: beat.act, of: self.screenplayID) }
            catch { self.errorMessage = error.localizedDescription }
        }
    }

    // MARK: - Section previews (for the hub cards)

    /// A short preview snippet for a hub card, or a placeholder when empty.
    func preview(for section: OutlineSection) -> String {
        let text: String
        switch section {
        case .idea:  text = screenplay.idea
        case .actOne:   text = screenplay.actOneDescription
        case .actTwo:   text = screenplay.actTwoDescription
        case .actThree: text = screenplay.actThreeDescription
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return isBlank(text) ? section.placeholder : trimmed
    }

    /// How many of a section's fields have content — drives a subtle progress
    /// hint on each hub card.
    func filledCount(for section: OutlineSection) -> (filled: Int, total: Int) {
        Self.filledCount(for: section, in: screenplay)
    }

    /// Pure completion count for a section against a given screenplay, usable
    /// before the instance is fully initialized (e.g. to seed the edge state).
    static func filledCount(
        for section: OutlineSection, in screenplay: Screenplay
    ) -> (filled: Int, total: Int) {
        func blank(_ text: String) -> Bool {
            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        switch section {
        case .idea:
            // Notes is optional and intentionally excluded from completion.
            let fields: [String] = [
                screenplay.idea, screenplay.logLine, screenplay.centralIntention,
                screenplay.mainObstacle, screenplay.theme
            ]
            return (fields.filter { !blank($0) }.count, fields.count)
        case .actOne, .actTwo, .actThree:
            guard let act = section.act else { return (0, 0) }
            let beats = ActBeatField.beats(for: act)
            let desc: String
            switch section {
            case .actOne:   desc = screenplay.actOneDescription
            case .actTwo:   desc = screenplay.actTwoDescription
            case .actThree: desc = screenplay.actThreeDescription
            case .idea:     desc = ""
            }
            let filledBeats = beats.filter { !blank($0.value(in: screenplay)) }.count
            let descFilled = blank(desc) ? 0 : 1
            return (filledBeats + descFilled, beats.count + 1)
        }
    }

    /// Whether a section counts as fully complete — every one of its *required*
    /// (non-optional) fields has content. Notes is excluded from these counts.
    func isComplete(_ section: OutlineSection) -> Bool {
        let progress = filledCount(for: section)
        return progress.total > 0 && progress.filled == progress.total
    }

    /// Overall outline completion as a fraction (0...1), measured by how many
    /// sections are *fully* complete rather than merely started.
    var overallCompletion: Double {
        let sections = OutlineSection.allCases
        guard !sections.isEmpty else { return 0 }
        let completed = sections.filter { isComplete($0) }.count
        return Double(completed) / Double(sections.count)
    }

    /// How many sections are fully complete (for the header subtitle).
    var completedSectionCount: Int {
        OutlineSection.allCases.filter { isComplete($0) }.count
    }

    // MARK: - Detail editor specs (relocated from the View)
    /// `OutlineField` it edits, plus its on-screen title, guiding prompt, and
    /// SF Symbol. Drives the Idea editor without the View hardcoding the set.
    struct IdeaFieldSpec: Identifiable {
        let field: OutlineField
        let title: String
        let prompt: String
        let systemImage: String
        var isOptional: Bool = false
        var id: String { field.rawValue }
    }

    /// The ordered Idea fields the detail editor should render. Relocated from
    /// `OutlineSectionDetailView` so the ordering/config is testable.
    let ideaFieldSpecs: [IdeaFieldSpec] = [
        IdeaFieldSpec(field: .idea, title: L10n.Idea.title("idea"),
                      prompt: L10n.Idea.prompt("idea"),
                      systemImage: "lightbulb"),
        IdeaFieldSpec(field: .logLine, title: L10n.Idea.title("logLine"),
                      prompt: L10n.Idea.prompt("logLine"),
                      systemImage: "text.quote"),
        IdeaFieldSpec(field: .centralIntention, title: L10n.Idea.title("centralIntention"),
                      prompt: L10n.Idea.prompt("centralIntention"),
                      systemImage: "target"),
        IdeaFieldSpec(field: .mainObstacle, title: L10n.Idea.title("mainObstacle"),
                      prompt: L10n.Idea.prompt("mainObstacle"),
                      systemImage: "exclamationmark.triangle"),
        IdeaFieldSpec(field: .theme, title: L10n.Idea.title("theme"),
                      prompt: L10n.Idea.prompt("theme"),
                      systemImage: "sparkles"),
        IdeaFieldSpec(field: .notes, title: L10n.Idea.title("notes"),
                      prompt: L10n.Idea.prompt("notes"),
                      systemImage: "note.text", isOptional: true)
    ]

    /// The ordered narrative beats for a section's act, or an empty list for the
    /// Idea section. Keeps the View from reaching into the domain enum directly.
    func beats(for section: OutlineSection) -> [ActBeatField] {
        guard let act = section.act else { return [] }
        return ActBeatField.beats(for: act)
    }

    /// The explanatory copy shown in the Act Beats info popover.
    let beatsInfoText = "Answering these questions can help you develop the plot points in your acts and push the story forward. Although not required, they can help you escape writer's block."

    // MARK: - Helpers

    /// Whether a text value is empty once surrounding whitespace/newlines are
    /// trimmed. Centralizes the "is this field filled?" rule used by `preview`
    /// and `filledCount`.
    private func isBlank(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
