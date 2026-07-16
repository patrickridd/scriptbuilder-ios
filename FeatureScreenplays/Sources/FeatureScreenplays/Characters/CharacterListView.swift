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
    /// Observe entitlement changes so the lock chrome updates live after a
    /// purchase / restore / expiration while this tab is on screen.
    @ObservedObject private var entitlementSignal: EditorEntitlementSignal

    public init(
        screenplayID: String,
        characters: Set<Character>,
        repository: ScreenplayRepository,
        gate: EditorGate = .unrestricted
    ) {
        _viewModel = State(
            wrappedValue: CharactersViewModel(
                screenplayID: screenplayID,
                characters: characters,
                repository: repository
            )
        )
        self.gate = gate
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
            CharacterDetailView(character: character, viewModel: viewModel)
        }
        .navigationDestination(item: $selected) { character in
            CharacterDetailView(character: character, viewModel: viewModel)
        }
        .alert(
            L10n.CharacterUI.deleteTitle,
            isPresented: deleteDialogBinding,
            presenting: viewModel.pendingDelete
        ) { character in
            Button(L10n.Action.delete, role: .destructive) {
                Haptics.warning()
                if let target = viewModel.pendingDelete {
                    if selected?.uuid == target.uuid { selected = nil }
                    if newlyAdded?.uuid == target.uuid { newlyAdded = nil }
                }
                viewModel.confirmPendingDelete()
            }
            Button(L10n.Action.cancel, role: .cancel) { viewModel.pendingDelete = nil }
        } message: { _ in
            Text(viewModel.pendingDeleteMessage)
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            searchBar
        }
    }

    /// Pinned bottom bar: a rounded search field filling most of the width, with
    /// a compact "+" button on the trailing side. Sits at the bottom for easy
    /// thumb reach, mirroring the Screenplays screen.
    private var searchBar: some View {
        HStack(spacing: 12) {
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

            addButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
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
                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
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

    private var addButton: some View {
        Button {
            guard gate.canAddCharacter(viewModel.characters.count) else {
                gate.onBlocked()
                return
            }
            Task {
                let created = await viewModel.addCharacter(named: "", role: nil)
                newlyAdded = created
            }
        } label: {
            addButtonLabel
        }
        .accessibilityLabel(isCharacterLocked ? "Add character (Pro)" : "Add character")
        .accessibilityHint(isCharacterLocked ? "Unlock ScriptBuilder Pro to add more characters" : "")
    }

    private var addButtonLabel: some View {
        Image(systemName: "plus")
            .font(.title3.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(
                isCharacterLocked ? AnyShapeStyle(palette.textMuted.opacity(0.55)) : AnyShapeStyle(palette.primaryButtonGradient),
                in: Circle()
            )
            .overlay(alignment: .bottomTrailing) {
                if isCharacterLocked { lockBadge }
            }
            .shadow(color: palette.accent.opacity(isCharacterLocked ? 0 : 0.35), radius: 8, y: 4)
            .animation(.easeInOut(duration: 0.25), value: isCharacterLocked)
    }

    private var lockBadge: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(palette.accent)
            .padding(3)
            .background(.white, in: Circle())
            .overlay(Circle().stroke(palette.cardStroke, lineWidth: 0.5))
            .offset(x: 3, y: 3)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A single cast-list card: role glyph, name, role, and an intention preview.
private struct CharacterCard: View {
    @Environment(\.appPalette) private var palette
    let character: Character
    var isHighlighted: Bool = false

    private var role: CharacterRole { CharacterRole.bucket(for: character.role) }

    private var preview: String {
        let intention = character.intention.trimmingCharacters(in: .whitespacesAndNewlines)
        return intention.isEmpty ? "No intention set yet" : intention
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: role.systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(palette.heroGradient, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(character.name.isEmpty ? "Unnamed" : character.name)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                Text(preview)
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted)
        }
        .padding(14)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isHighlighted ? palette.accent.opacity(0.9) : palette.cardStroke,
                    lineWidth: isHighlighted ? 1.5 : 1
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}
