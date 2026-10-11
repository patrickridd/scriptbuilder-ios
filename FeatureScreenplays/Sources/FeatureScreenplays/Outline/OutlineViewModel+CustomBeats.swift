import Foundation
import Domain
import SwiftUI

/// Writer-authored beats on the act editors. Ordering always comes from the
/// screenplay's beat layout (`Screenplay.outlineSlots(in:)`), so the editor,
/// the hub counts and the export can never disagree about where a beat sits.
///
/// A custom beat is always stored in its *home* act, even when the layout
/// shows it in another section, so every edit resolves the home act by id
/// (`Screenplay.customBeat(withID:)`) rather than trusting the section.
///
/// Persistence mirrors the template beats: edits are debounced per beat and
/// saved as the whole beat (`save(customBeat:in:of:)`), keyed by id so two
/// beats never overwrite each other. Deletes cancel any pending save first.
extension OutlineViewModel {

    // MARK: - Reading

    /// The section's template and custom beats in display order. Empty for
    /// the Idea section.
    func slots(for section: OutlineSection) -> [CustomBeat.Slot] {
        guard let act = section.act else { return [] }
        return screenplay.outlineSlots(in: act)
    }

    /// How many custom beats the section's act holds — drives the free-tier
    /// gate and the "2 custom beats" hint on the hub card.
    func customBeatCount(for section: OutlineSection) -> Int {
        guard let act = section.act else { return 0 }
        return screenplay.customBeats(in: act).count
    }

    /// The beat's title, or a friendly stand-in while it's still unnamed.
    func displayTitle(for beat: CustomBeat) -> String {
        let trimmed = beat.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.CustomBeatCopy.untitled : trimmed
    }

    // MARK: - Creating

    /// Adds an empty custom beat to `section`'s act directly after `slot`
    /// (`nil` = end of the act) and returns its id so the view can focus it.
    /// Gating is the caller's job — this always creates.
    @discardableResult
    func addCustomBeat(to section: OutlineSection, after slot: CustomBeat.Slot?) -> String? {
        guard let act = section.act else { return nil }
        let placement = insertionPoint(after: slot, in: screenplay.customBeats(in: act))
        let beat = CustomBeat(anchor: placement.anchor, order: placement.order)
        screenplay.upsert(customBeat: beat, in: act)
        scheduleCustomBeatSave(id: beat.id, in: act)
        // In a rearranged outline the anchor alone can't say where the beat
        // goes, so pin it right after `slot` in the saved layout too.
        if screenplay.placeInSavedLayout(.custom(beat.id), after: slot.map(reference(for:)), in: act) {
            saveBeatLayout()
        }
        evaluateCompletionEdge()
        return beat.id
    }

    private func reference(for slot: CustomBeat.Slot) -> BeatReference {
        switch slot {
        case .template(let field): return BeatReference(field)
        case .custom(let beat):    return .custom(beat.id)
        }
    }

    /// Persists the current saved layout (nil = standard order).
    func saveBeatLayout() {
        let layout = screenplay.savedBeatLayout
        Task { [weak self] in
            guard let self else { return }
            do { try await self.repository.save(beatLayout: layout, of: self.screenplayID) }
            catch { self.errorMessage = error.localizedDescription }
        }
    }

    /// Where a new beat lands so it sits immediately after `slot`:
    /// - after a template beat → first among that beat's custom followers;
    /// - after a custom beat → halfway to its next sibling (no renumbering);
    /// - no slot → after everything at the end of the act.
    private func insertionPoint(
        after slot: CustomBeat.Slot?, in existing: [CustomBeat]
    ) -> (anchor: ActBeatField?, order: Double) {
        switch slot {
        case .none:
            return (nil, CustomBeat.nextOrder(after: nil, in: existing))
        case .template(let template):
            let siblingOrders = existing.filter { $0.anchor == template }.map(\.order)
            return (template, (siblingOrders.min() ?? 1) - 1)
        case .custom(let previous):
            let nextOrder = existing
                .filter { $0.anchor == previous.anchor && $0.order > previous.order }
                .map(\.order)
                .min()
            let order = nextOrder.map { (previous.order + $0) / 2 } ?? previous.order + 1
            return (previous.anchor, order)
        }
    }

    // MARK: - Editing

    /// Binding for a custom beat's title.
    func titleBinding(forCustomBeat id: String, in section: OutlineSection) -> Binding<String> {
        customBeatBinding(id: id, in: section, keyPath: \.title)
    }

    /// Binding for a custom beat's optional subtitle (guiding line).
    func subtitleBinding(forCustomBeat id: String, in section: OutlineSection) -> Binding<String> {
        customBeatBinding(id: id, in: section, keyPath: \.subtitle)
    }

    /// Binding for a custom beat's body text.
    func textBinding(forCustomBeat id: String, in section: OutlineSection) -> Binding<String> {
        customBeatBinding(id: id, in: section, keyPath: \.text)
    }

    private func customBeatBinding(
        id: String,
        in section: OutlineSection,
        keyPath: WritableKeyPath<CustomBeat, String>
    ) -> Binding<String> {
        Binding(
            get: { self.screenplay.customBeat(withID: id)?.beat[keyPath: keyPath] ?? "" },
            set: { newValue in
                guard let match = self.screenplay.customBeat(withID: id) else { return }
                var beat = match.beat
                beat[keyPath: keyPath] = newValue
                self.screenplay.upsert(customBeat: beat, in: match.act)
                self.scheduleCustomBeatSave(id: id, in: match.act)
                self.evaluateCompletionEdge()
            }
        )
    }

    // MARK: - Disabling template beats

    func isDisabled(_ beat: ActBeatField) -> Bool {
        screenplay.isBeatDisabled(beat)
    }

    /// Switches a template beat off (or back on). Its text is kept, so
    /// re-enabling restores it; while off it's skipped by progress, the
    /// "Next up" nudge and exports.
    func setBeat(_ beat: ActBeatField, disabled: Bool) {
        guard screenplay.isBeatDisabled(beat) != disabled else { return }
        screenplay.setBeat(beat, disabled: disabled)
        evaluateCompletionEdge()
        Task { [weak self] in
            guard let self else { return }
            do { try await self.repository.setBeat(beat, disabled: disabled, of: self.screenplayID) }
            catch { self.errorMessage = error.localizedDescription }
        }
    }

    // MARK: - Deleting

    /// Removes a custom beat locally and from storage, dropping any edit that
    /// was still waiting to save so it can't resurrect the beat.
    func deleteCustomBeat(id: String, from section: OutlineSection) {
        // The beat may be shown in `section` but stored in another act.
        guard let act = screenplay.customBeat(withID: id)?.act ?? section.act else { return }
        let key = customBeatSaveKey(id)
        saveTasks[key]?.cancel()
        saveTasks[key] = nil
        pendingWrites[key] = nil
        screenplay.removeCustomBeat(id: id, from: act)
        // Keep the saved layout tidy; reads would repair it anyway.
        if var layout = screenplay.savedBeatLayout {
            for sectionID in layout.sections.keys {
                layout.sections[sectionID]?.removeAll { $0 == .custom(id) }
            }
            screenplay.savedBeatLayout = layout
            saveBeatLayout()
        }
        evaluateCompletionEdge()
        Task { [weak self] in
            guard let self else { return }
            do { try await self.repository.delete(customBeatID: id, from: act, of: self.screenplayID) }
            catch { self.errorMessage = error.localizedDescription }
        }
    }

    // MARK: - Saving

    private func customBeatSaveKey(_ id: String) -> String { "customBeat.\(id)" }

    /// Debounced save of the beat's latest state. Goes through `schedule`, so
    /// a burst of keystrokes collapses into one write and `flush()` sends it
    /// (rather than cancelling it) when the editor closes.
    private func scheduleCustomBeatSave(id: String, in act: Act) {
        guard let beat = screenplay.customBeats(in: act).first(where: { $0.id == id }) else { return }
        let repository = repository
        let screenplayID = screenplayID
        schedule(customBeatSaveKey(id)) {
            try await repository.save(customBeat: beat, in: act, of: screenplayID)
        }
    }
}
