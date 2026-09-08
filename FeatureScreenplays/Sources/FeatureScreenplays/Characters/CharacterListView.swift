import SwiftUI
import Domain
import DesignSystem

/// The Characters tab of the screenplay editor: cast grouped by role, each row a
/// card showing the character's name, role, and a preview of their intention.
/// Tapping a card opens the full arc form; the `+` adds a fresh character.
public struct CharacterListView: View {
    @Environment(\.appPalette) private var palette
    @State private var viewModel: CharactersViewModel
    @State private var newlyAdded: Character?
    @State private var selected: Character?
    private let gate: EditorGate
    /// Shown as the navigation title on a character's detail screen.
    private let screenplayTitle: String
    /// Observe entitlement changes so the lock chrome updates live after a
    /// purchase / restore / expiration while this tab is on screen.
    @ObservedObject private var entitlementSignal: EditorEntitlementSignal

    public init(
        screenplayID: String,
        characters: Set<Character>,
        repository: ScreenplayRepository,
        gate: EditorGate = .unrestricted,
        screenplayTitle: String = ""
    ) {
        _viewModel = State(
            wrappedValue: CharactersViewModel(
                screenplayID: screenplayID,
                characters: characters,
                repository: repository
            )
        )
        self.gate = gate
        self.screenplayTitle = screenplayTitle
        _entitlementSignal = ObservedObject(wrappedValue: gate.entitlementSignal)
    }

    public var body: some View {
        Group {
            if viewModel.isEmpty {
                emptyState
            } else {
                populatedContent
            }
        }
        .navigationDestination(item: $newlyAdded) { character in
            CharacterDetailView(character: character, viewModel: viewModel, screenplayTitle: screenplayTitle)
        }
        .navigationDestination(item: $selected) { character in
            CharacterDetailView(character: character, viewModel: viewModel, screenplayTitle: screenplayTitle)
        }
        // Fully custom pop-up so swipe-to-delete matches every other
        // destructive action in the app.
        .confirmDialog(
            isPresented: deleteDialogBinding,
            icon: "trash.fill",
            title: L10n.CharacterUI.deleteTitle,
            message: viewModel.pendingDeleteMessage,
            confirmTitle: L10n.Action.delete,
            cancelTitle: L10n.Action.cancel
        ) {
            Haptics.warning()
            if let target = viewModel.pendingDelete {
                if selected?.uuid == target.uuid { selected = nil }
                if newlyAdded?.uuid == target.uuid { newlyAdded = nil }
            }
            viewModel.confirmPendingDelete()
        }
    }

    private var populatedContent: some View {
        Group {
            if viewModel.hasNoSearchResults {
                noResultsState
            } else {
                castList
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            newCharacterPill
                .padding(.top)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            searchBar
        }
    }

    /// Pinned bottom bar: the cast search field with a compact "+" on the
    /// trailing side — the same shape as the Screenplays shelf, so "add" lives
    /// in the same place on both screens. The navigation bar carries a second
    /// "+" for reach while scrolling.
    private var searchBar: some View {
        HStack(spacing: 12) {
            searchField
            addButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
                TextField("Search cast", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(palette.textPrimary)
                if viewModel.isSearching {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(palette.textMuted)
                    }
                    .buttonStyle(.plain)
                }
            }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(palette.cardSurface, in: Capsule())
        .overlay(Capsule().stroke(palette.cardStroke, lineWidth: 1))
    }

    private var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDelete != nil },
            set: { if !$0 { viewModel.pendingDelete = nil } }
        )
    }

    private var castList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.visibleSections) { section in
                    roleSection(section)
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .id(viewModel.structureID)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 0)
            .onChange(of: viewModel.highlightedCharacterID) { _, newID in
                guard let newID else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    proxy.scrollTo(newID, anchor: .top)
                }
            }
        }
        .padding(.top)
    }

    private func roleSection(_ section: CharactersViewModel.RoleSection) -> some View {
        Section {
            ForEach(section.characters, id: \.uuid) { character in
                Button {
                    selected = character
                } label: {
                    CharacterCard(character: character, isHighlighted: viewModel.isHighlighted(character))
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 5, leading: 2, bottom: 5, trailing: 2))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.requestDelete(character)
                    } label: {
                        Label(L10n.Action.delete, systemImage: "trash.fill")
                    }
                }
            }
        } header: {
            Label(section.role.displayName.uppercased(), systemImage: section.role.systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(palette.textMuted)
        }
    }

    /// Whether adding another character is blocked by the free-tier gate. When
    /// `true` the add button shows a lock hint so the boundary is visible
    /// before the user taps into the paywall.
    private var isCharacterLocked: Bool {
        !gate.canAddCharacter(viewModel.characters.count)
    }

    /// Single entry point for every "add" affordance on this screen (bottom
    /// pill, empty-state button, no-results shortcut) so the gate is checked in
    /// exactly one place.
    private func createCharacter(named name: String = "") {
        guard gate.canAddCharacter(viewModel.characters.count) else {
            gate.onBlocked()
            return
        }
        Haptics.lightImpact()
        Task {
            let created = await viewModel.addCharacter(named: name, role: nil)
            newlyAdded = created
        }
    }

    /// Compact circular "+" beside the search field, matching the Screenplays
    /// shelf. It keeps its full gradient when the free-tier gate is active — it
    /// stays tappable (it opens the paywall) — and shows a small lock instead.
    private var addButton: some View {
        Button {
            createCharacter()
        } label: {
            Image(systemName: "plus")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(palette.primaryButtonGradient, in: Circle())
                .overlay(alignment: .topTrailing) {
                    if isCharacterLocked { lockBadge }
                }
                .shadow(color: palette.accent.opacity(0.35), radius: 8, y: 4)
        }
        .accessibilityLabel(isCharacterLocked ? "New character (Pro)" : "New character")
        .accessibilityHint(isCharacterLocked ? "Unlock ScriptBuilder Pro to add more characters" : "")
    }

    private var lockBadge: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(palette.accent)
            .frame(width: 18, height: 18)
            .background(Color.white, in: Circle())
            .offset(x: 2, y: -2)
            .accessibilityHidden(true)
    }

    /// Dashed "New Character" pill pinned directly under the screenplay tab
    /// bar, above the cast list. It borrows the dashed-accent vocabulary of the
    /// Scenes tab's `AddSceneCard` so both tabs read as one system: list
    /// scaffolding rather than a second primary button competing with the
    /// bottom shelf "+".
    private var newCharacterPill: some View {
        Button {
            createCharacter()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.subheadline.weight(.bold))
                Text("New Character")
                    .font(.subheadline.weight(.semibold))
                if isCharacterLocked { proCapsule }
            }
            .foregroundStyle(palette.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(dashedPillBackground)
        }
        .buttonStyle(PressableScaleStyle())
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 2)
        .accessibilityLabel(isCharacterLocked ? "New character (Pro)" : "New character")
        .accessibilityHint(isCharacterLocked ? "Unlock ScriptBuilder Pro to add more characters" : "")
    }

    private var dashedPillBackground: some View {
        Capsule()
            .fill(palette.accent.opacity(0.08))
            .overlay(
                Capsule()
                    .strokeBorder(
                        palette.accent.opacity(0.55),
                        style: StrokeStyle(lineWidth: 1.5, dash: [7, 5])
                    )
            )
    }

    private var proCapsule: some View {
        Text("PRO")
            .font(.caption2.weight(.black))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(palette.accent, in: Capsule())
            .accessibilityHidden(true)
    }

    private var noResultsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(palette.textMuted)
            Text(L10n.CharacterUI.noMatchesTitle)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
            Text(L10n.CharacterUI.noMatchesMessage(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)))
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            createTypedNameButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Turns a dead-end search into an add: "Create 'Mara'" makes the character
    /// with the text already typed as their name.
    @ViewBuilder
    private var createTypedNameButton: some View {
        let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            AddPillButton(
                title: "Create “\(query)”",
                isLocked: isCharacterLocked,
                accessibilityHintText: isCharacterLocked ? "Unlock ScriptBuilder Pro to add more characters" : ""
            ) {
                viewModel.searchText = ""
                createCharacter(named: query)
            }
            .padding(.top, 6)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(palette.accent)
            Text(L10n.CharacterUI.emptyTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
            Text(L10n.CharacterUI.emptyMessage)
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            AddPillButton(
                title: "New Character",
                isLocked: isCharacterLocked,
                accessibilityHintText: isCharacterLocked ? "Unlock ScriptBuilder Pro to add more characters" : ""
            ) {
                createCharacter()
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
private struct CharacterListPreview: View {
    let characters: Set<Character>

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                CharacterListView(
                    screenplayID: "preview-screenplay",
                    characters: characters,
                    repository: MockScreenplayRepository(seedSamples: false)
                )
            }
            .navigationTitle("Cast")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    static let sampleCast: Set<Character> = [
        CharacterCardSamples.mixed,
        CharacterCardSamples.overflowing,
        CharacterCardSamples.functionsOnly,
        CharacterCardSamples.custom
    ]
}

#Preview("Cast — Populated") {
    CharacterListPreview(characters: CharacterListPreview.sampleCast)
}

#Preview("Cast — Empty") {
    CharacterListPreview(characters: [])
}

#Preview("Cast — Dark") {
    CharacterListPreview(characters: CharacterListPreview.sampleCast)
        .preferredColorScheme(.dark)
}
#endif
