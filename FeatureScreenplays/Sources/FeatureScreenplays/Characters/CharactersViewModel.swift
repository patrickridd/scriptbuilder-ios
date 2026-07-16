import Foundation
import Observation
import Domain
import SwiftUI

/// Owns the cast for one screenplay: grouping by role, granular autosave of a
/// single character, add/delete, all via the non-destructive repository writes.
@MainActor
@Observable
public final class CharactersViewModel {

    public private(set) var characters: [Character]
    public var errorMessage: String?

    /// Live search query typed into the cast-list header. Filters the displayed
    /// sections by character name or intention. Empty string shows everyone.
    var searchText: String = ""

    /// The character most recently finished editing. Drives a transient accent
    /// border on its row (like a focused `ExpandableTextField`) so the user can
    /// spot where their edit landed after it bubbles to the top. Cleared
    /// automatically a moment later.
    private(set) var highlightedCharacterID: String?

    @ObservationIgnored private var highlightClearTask: Task<Void, Never>?

    /// The character awaiting delete confirmation, if any. Owned here so the
    /// view can stay declarative and the confirmation copy lives in one place.
    var pendingDelete: Character?

    @ObservationIgnored private let screenplayID: String
    @ObservationIgnored private let repository: ScreenplayRepository

    public init(screenplayID: String, characters: Set<Character>, repository: ScreenplayRepository) {
        self.screenplayID = screenplayID
        self.repository = repository
        self.characters = characters.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        syncRoleOrder()
        rebuildSections()
    }

    /// Whether the cast is empty (drives the empty-state UI).
    var isEmpty: Bool { characters.isEmpty }

    /// Structural identity for a card that changes whenever the *displayed*
    /// content changes. `Character` is `Equatable` on `uuid` only, so SwiftUI
    /// would otherwise skip re-rendering a row after its name/role/intention was
    /// edited elsewhere. Tying `.id` to the visible fields forces a refresh.
    func cardIdentity(for character: Character) -> String {
        "\(character.uuid)|\(character.name)|\(character.role ?? "")|\(character.intention)"
    }

    /// Confirmation-dialog copy for the character currently pending deletion.
    var pendingDeleteMessage: String {
        let name = pendingDelete?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let subject = name.isEmpty ? L10n.CharacterUI.deleteSubjectFallback : name
        return L10n.CharacterUI.deleteMessage(subject)
    }

    /// Explicit section order. This is the single source of truth for how role
    /// sections are laid out — deliberately **not** derived from `characters` so
    /// that deleting a row can never reorder or drop a section mid-diff (the
    /// cause of the "invalid number of items in section" collection-view crash).
    /// Add / moveToTop bubble a role to the front here; delete only prunes a
    /// role once it becomes empty, in a separate, settled update.
    private var roleOrder: [CharacterRole] = []

    /// Roles that currently contain at least one character, derived from the
    /// **stored** `sections` snapshot so it never re-filters the live array.
    var populatedRoles: [CharacterRole] {
        sections.map(\.role)
    }

    /// A single **stored** atomic snapshot of the whole list: sections **and**
    /// their rows, materialized once per mutation via `rebuildSections()` and
    /// then frozen until the next mutation. This is the direct analogue of the
    /// UIKit `roleCharacterSections` stored property that never crashed: `List`
    /// reads section count and each section's row count from the *same* frozen
    /// value throughout an update pass, so it can never sample section-count and
    /// row-count from two different states mid-diff (the actual cause of the
    /// "invalid number of items in section" crash). A computed version re-ran
    /// the filter against the mid-mutation `characters` array on every read.
    private(set) var sections: [RoleSection] = []

    /// The sections actually shown by the List, after applying `searchText`.
    /// When the query is blank this is exactly the frozen `sections` snapshot,
    /// so unfiltered browsing keeps the same crash-safe atomic behaviour. When
    /// searching, we derive a fresh (read-only) snapshot filtered by name or
    /// intention — safe because search is a passive view state, never mutated
    /// mid-delete.
    var visibleSections: [RoleSection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return sections }
        return sections.compactMap { section in
            let matches = section.characters.filter { $0.matches(query) }
            guard !matches.isEmpty else { return nil }
            return RoleSection(role: section.role, characters: matches)
        }
    }

    /// Whether a non-empty search is currently active.
    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// True when a search is active but nothing matches — drives the "no results"
    /// empty state distinct from the "no characters yet" one.
    var hasNoSearchResults: Bool {
        isSearching && visibleSections.isEmpty
    }

    /// Rebuild the stored `sections` snapshot from the current `characters` and
    /// `roleOrder`. Call this exactly once at the end of every mutation — the
    /// SwiftUI equivalent of UIKit's `didSet { reloadTableView() }`.
    private func rebuildSections() {
        sections = roleOrder.compactMap { role in
            let rows = characters.filter { CharacterRole.bucket(for: $0.role) == role }
            guard !rows.isEmpty else { return nil }
            return RoleSection(role: role, characters: rows)
        }
    }

    /// A fingerprint of the current section/row **structure** — which sections
    /// exist and which character IDs live in each. The view attaches this as the
    /// `List`'s `.id`, so any structural change (a section appearing/disappearing
    /// or a row moving between sections) swaps the `List`'s identity and forces a
    /// clean rebuild instead of an animated UIKit batch update — the operation
    /// that throws "invalid number of items in section". It stays constant across
    /// in-place edits (name/intention changes) so those still animate normally.
    var structureID: String {
        sections
            .map { section in
                section.role.rawValue + ":" + section.characters.map(\.uuid).joined(separator: ",")
            }
            .joined(separator: "|")
    }

    /// One role bucket plus its rows, snapshotted together (see `sections`).
    struct RoleSection: Identifiable {
        let role: CharacterRole
        let characters: [Character]
        var id: CharacterRole { role }
    }

    /// Ensure `roleOrder` contains every role currently present in the cast,
    /// preserving existing order and appending any newcomers. Call after seeding
    /// or when a character's role changes.
    private func syncRoleOrder(bringingToFront front: CharacterRole? = nil) {
        for character in characters {
            let role = CharacterRole.bucket(for: character.role)
            if !roleOrder.contains(role) { roleOrder.append(role) }
        }
        if let front, let idx = roleOrder.firstIndex(of: front) {
            roleOrder.remove(at: idx)
            roleOrder.insert(front, at: 0)
        }
    }

    /// Characters for a role bucket, read from the **stored** `sections`
    /// snapshot so it matches exactly what the List is diffing (never
    /// re-filters the live array mid-mutation).
    func characters(in role: CharacterRole) -> [Character] {
        sections.first(where: { $0.role == role })?.characters ?? []
    }

    /// Insert a brand-new blank character (used by the "add" button) and persist.
    /// New characters go to the top of the list for easy discovery.
    func addCharacter(named name: String, role: String?) async -> Character {
        let new = Character(name: name, role: role)
        characters.insert(new, at: 0)
        syncRoleOrder(bringingToFront: CharacterRole.bucket(for: role))
        rebuildSections()
        await save(new)
        return new
    }

    /// Merge an edited character back into the list and autosave just that one,
    /// **without** reordering. Used for debounced autosave while typing so the
    /// card doesn't hop around mid-edit. Call `moveToTop(_:)` on exit to bubble
    /// the finished edit (and its section) to the top.
    func update(_ character: Character) async {
        if let index = characters.firstIndex(where: { $0.uuid == character.uuid }) {
            characters[index] = character
        } else {
            characters.insert(character, at: 0)
        }
        syncRoleOrder()
        rebuildSections()
        await save(character)
    }

    /// Move an already-saved character to the top of the list and bubble its
    /// whole role section to the front (via `roleOrder`). Called when finishing
    /// an edit (on exit). Wrapped in a spring so the card/section glides up.
    func moveToTop(_ character: Character) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            characters.removeAll { $0.uuid == character.uuid }
            characters.insert(character, at: 0)
            syncRoleOrder(bringingToFront: CharacterRole.bucket(for: character.role))
            rebuildSections()
            highlightedCharacterID = character.uuid
        }
        scheduleHighlightClear()
    }

    /// Whether a given character's row should show the "just edited" accent border.
    func isHighlighted(_ character: Character) -> Bool {
        highlightedCharacterID == character.uuid
    }

    /// Fade the highlight out a couple of seconds after the edit settles.
    private func scheduleHighlightClear() {
        highlightClearTask?.cancel()
        highlightClearTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                self?.highlightedCharacterID = nil
            }
        }
    }

    /// Ask to delete a character. Called from the swipe action. We record the
    /// pending target (which drives the confirmation alert) instead of mutating
    /// the list here — mutating list-shape state *inside* the swipe action's own
    /// transaction is exactly what races UIKit's row-removal bookkeeping and
    /// triggers the "attempt to delete item N which only contains N items" crash.
    func requestDelete(_ character: Character) {
        pendingDelete = character
    }

    /// Confirm the pending deletion from the alert. Dismisses the alert first,
    /// then defers the actual list mutation to the *next* main-actor runloop
    /// tick so it happens after SwiftUI has fully torn down the alert and any
    /// in-flight swipe transaction. Diffing a settled snapshot removes the row
    /// cleanly instead of fighting the collection view mid-update.
    func confirmPendingDelete() {
        guard let character = pendingDelete else { return }
        pendingDelete = nil
        Task { @MainActor in
            // Yield one tick so the alert-dismissal transaction commits before
            // we change the list's shape.
            await Task.yield()
            await delete(character)
        }
    }

    func delete(_ character: Character) async {
        // Clear a stale highlight/scroll target first so the List isn't asked
        // to reference a row that's about to be removed mid-diff.
        if highlightedCharacterID == character.uuid {
            highlightClearTask?.cancel()
            highlightedCharacterID = nil
        }

        let role = CharacterRole.bucket(for: character.role)
        let isLastInSection = characters
            .filter { CharacterRole.bucket(for: $0.role) == role }
            .count == 1

        // Apply the list-shape change with animations EXPLICITLY DISABLED. The
        // remaining crash was never about *when* the snapshot is computed — it
        // was `List` trying to run an ANIMATED batch update (insert/delete
        // deltas) across a structural change where a whole section can vanish.
        // UIKit's batch-update bookkeeping then sees "section still present, row
        // count changed by 1 but I was told 0 rows deleted" and throws the
        // "invalid number of items in section" exception. Mutating inside
        // `withTransaction { transaction.disablesAnimations = true }` forces
        // `List` to RELOAD (like UIKit `reloadData()`) instead of diffing —
        // exactly the atomic, non-animated refresh `roleCharacterSections`'
        // `didSet { reloadTableView() }` gave you.
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            characters.removeAll { $0.uuid == character.uuid }
            if isLastInSection {
                roleOrder.removeAll { $0 == role }
            }
            rebuildSections()
        }

        do {
            try await repository.delete(characterID: character.uuid, from: screenplayID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save(_ character: Character) async {
        do {
            try await repository.save(character: character, in: screenplayID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension Character {
    /// Case-insensitive match against the character's name or intention.
    func matches(_ query: String) -> Bool {
        name.localizedCaseInsensitiveContains(query)
            || intention.localizedCaseInsensitiveContains(query)
    }
}
