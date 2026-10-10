import Foundation
import Observation
import Domain

/// Owns all editing logic for a single character screen: the working `draft`,
/// the role bucket + free-form custom role, debounced autosave, and the final
/// flush on exit. Extracted out of `CharacterDetailView` so the view stays
/// declarative and the "when do we persist" ownership lives in one place.
@MainActor
@Observable
final class CharacterDetailViewModel {

    /// The live working copy the form binds to. Mutating any field schedules a
    /// debounced save automatically.
    ///
    /// Written by hand rather than as a plain stored property because the
    /// `@Observable` macro skips properties that declare `didSet`, which left
    /// the header title and progress ring stale while typing. `access` /
    /// `withMutation` reinstate the change notifications the macro would emit.
    var draft: Character {
        get {
            access(keyPath: \.draft)
            return storedDraft
        }
        set {
            withMutation(keyPath: \.draft) { storedDraft = newValue }
            scheduleSave()
        }
    }

    /// The selected role bucket. Changing it (or `customRole`) reschedules a save.
    var role: CharacterRole {
        get {
            access(keyPath: \.role)
            return storedRole
        }
        set {
            withMutation(keyPath: \.role) { storedRole = newValue }
            scheduleSave()
        }
    }

    /// Free-form role text, only meaningful when `role == .custom`.
    var customRole: String {
        get {
            access(keyPath: \.customRole)
            return storedCustomRole
        }
        set {
            withMutation(keyPath: \.customRole) { storedCustomRole = newValue }
            scheduleSave()
        }
    }

    @ObservationIgnored private var storedDraft: Character
    @ObservationIgnored private var storedRole: CharacterRole
    @ObservationIgnored private var storedCustomRole: String

    @ObservationIgnored private let viewModel: CharactersViewModel
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private let debounce: Duration
    /// Set once the user taps Delete so the exit `flush()` doesn't re-persist
    /// (and thereby resurrect) the character that's on its way out.
    @ObservationIgnored private var isDeleting = false

    init(
        character: Character,
        viewModel: CharactersViewModel,
        debounce: Duration = .milliseconds(500)
    ) {
        self.viewModel = viewModel
        self.debounce = debounce
        // Backfill identity for characters constructed with only a legacy flat
        // role string (non-destructive; persisted on the next save).
        var initialDraft = character
        if initialDraft.identity.isEmpty,
           let legacyRole = initialDraft.role,
           !legacyRole.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            initialDraft.identity = CharacterIdentity(resolvingLegacyRole: legacyRole)
        }
        self.storedDraft = initialDraft
        let bucket = CharacterRole.bucket(for: character.role)
        self.storedRole = bucket
        self.storedCustomRole = bucket == .custom ? (character.role ?? "") : ""
    }

    // MARK: - Identity

    /// Apply a role picked in `RolePickerDetailView`: updates the structured
    /// identity and keeps the legacy flat `role` string in sync so the cast
    /// list's role grouping keeps working.
    func applyRole(_ newRole: HierarchicalRole?) {
        draft.identity.role = newRole
        let legacy = Self.legacyBucket(for: newRole)
        role = legacy.bucket
        customRole = legacy.customText
    }

    /// Display text for the Role row: the writer's own label for custom and
    /// legacy roles (shown as-is), otherwise the stock catalog name.
    var roleDisplayText: String? {
        guard let identityRole = draft.identity.role else { return nil }
        return IdentityCatalog.displayName(for: identityRole)
    }

    /// Map a structured role back onto the legacy picker buckets. Stock roles
    /// without a legacy equivalent are stored by display name so the cast list
    /// groups them under their own header.
    private static func legacyBucket(for identityRole: HierarchicalRole?) -> (bucket: CharacterRole, customText: String) {
        guard let identityRole else { return (.custom, "") }
        if identityRole.isCustom {
            return (.custom, identityRole.customLabel ?? "")
        }
        switch identityRole.slug {
        case HierarchicalRole.Stock.protagonist:
            return (.protagonist, "")
        case HierarchicalRole.Stock.antagonist:
            return (.antagonist, "")
        default:
            let name = IdentityCatalog.roleEntry(for: identityRole.slug)?.name ?? identityRole.slug.capitalized
            return (.custom, name)
        }
    }

    // MARK: - Arc progress

    /// How many of the active arc questions currently have an answer.
    var arcFilledCount: Int { draft.arcFilledCount }

    /// Active arc questions: stock ones switched on plus every custom one.
    var arcTotalCount: Int { draft.arcTotalCount }

    /// The first arc question still waiting for an answer, if any.
    var nextArcSlot: ArcSlot? { draft.firstUnfilledArcSlot }

    /// True when the writer has declared this character simply has no arc.
    var arcNotApplicable: Bool { draft.arcNotApplicable }

    /// Completion copy for the arc: a distinct line when the arc was waived.
    var arcCompleteText: String {
        draft.arcNotApplicable ? IdentityUIStrings.arcNotApplicableComplete : L10n.CharacterUI.arcComplete
    }

    // MARK: - Overall progress

    /// How many identity facets (name, role, archetype, story function) are set.
    var identityFilledCount: Int { CharacterIdentityField.filledCount(for: draft) }

    /// Total number of identity facets counted toward completion.
    var identityTotalCount: Int { CharacterIdentityField.allCases.count }

    /// Identity + arc combined: the character's overall completion numerator.
    var overallFilledCount: Int { identityFilledCount + arcFilledCount }

    /// Identity + arc combined: the character's overall completion denominator.
    var overallTotalCount: Int { identityTotalCount + arcTotalCount }

    /// The next thing to work on: an unchosen identity facet first (it's the
    /// quickest win and shapes the arc), then the first empty arc field.
    var nextOverallTarget: CharacterProgressTarget? {
        if let field = CharacterIdentityField.firstUnfilled(for: draft) {
            return .identity(field)
        }
        if let slot = nextArcSlot { return .arc(slot) }
        return nil
    }

    /// Title shown in the navigation bar.
    var navigationTitle: String {
        draft.name.isEmpty ? "Character" : draft.name
    }

    /// True once the writer has typed a name (ignoring whitespace).
    var hasName: Bool {
        !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Big header title: the character's name, or a friendly prompt while blank.
    var headerTitle: String {
        hasName ? draft.name : IdentityUIStrings.namePlaceholderTitle
    }

    /// Whether the name field should grab focus when the detail view appears.
    /// True for a brand-new (still unnamed) character so the user can start
    /// typing immediately; false when editing an existing, named character.
    var shouldFocusName: Bool {
        draft.name.isEmpty
    }

    /// The character to write out, with the role string resolved from the
    /// picker + custom field.
    private var resolvedCharacter: Character {
        var toSave = draft
        switch role {
        case .custom:
            let trimmed = customRole.trimmingCharacters(in: .whitespacesAndNewlines)
            toSave.role = trimmed.isEmpty ? nil : trimmed
        default:
            toSave.role = role.rawValue
        }
        return toSave
    }

    /// Debounced autosave so inline edits persist as you type, not only on exit.
    private func scheduleSave() {
        saveTask?.cancel()
        let character = resolvedCharacter
        saveTask = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.viewModel.update(character)
        }
    }

    /// Cancel any pending debounce and flush the latest state immediately.
    /// Called when the screen is leaving so nothing is lost. On exit we also
    /// bubble the finished character (and its role section) to the top, so
    /// reordering happens once at the end rather than on every keystroke.
    func flush() async {
        guard !isDeleting else { return }
        saveTask?.cancel()
        saveTask = nil
        let character = resolvedCharacter
        await viewModel.update(character)
        viewModel.moveToTop(character)
    }

    /// Confirmation-alert copy shown before deleting this character.
    var deleteConfirmMessage: String {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = name.isEmpty ? L10n.CharacterUI.deleteSubjectFallbackCapitalized : name
        return L10n.CharacterUI.deleteMessage(subject)
    }

    /// Cancel any pending autosave and delete this character. Called only after
    /// the user has confirmed on the detail screen's alert, so we delete
    /// directly rather than re-prompting via the list's pending-delete flow.
    func requestDelete() {
        isDeleting = true
        saveTask?.cancel()
        saveTask = nil
        let character = resolvedCharacter
        Task { await viewModel.delete(character) }
    }
}
