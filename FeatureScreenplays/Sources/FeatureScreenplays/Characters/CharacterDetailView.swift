import SwiftUI
import Domain
import DesignSystem

/// The full arc form for a single character: basic info (name + role) plus the
/// ten dramatic-arc fields, each an auto-growing `ExpandableTextField`. All
/// editing logic (draft, role resolution, debounced autosave, flush-on-exit)
/// lives in `CharacterDetailViewModel`; this view is purely declarative.
struct CharacterDetailView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CharacterDetailViewModel
    @State private var showDeleteConfirm = false
    @State private var showArc = false
    @FocusState private var nameFocused: Bool

    /// Scroll anchor for the identity rows, used by the header's nudge.
    private let identityAnchor = "character-identity-rows"

    /// Title of the owning screenplay, shown in the navigation bar so the
    /// on-screen header can carry the character's own name instead.
    private let screenplayTitle: String

    init(character: Character, viewModel: CharactersViewModel, screenplayTitle: String = "") {
        _viewModel = State(initialValue: CharacterDetailViewModel(character: character, viewModel: viewModel))
        self.screenplayTitle = screenplayTitle
    }

    private var navTitle: String {
        screenplayTitle.isEmpty ? viewModel.navigationTitle : screenplayTitle
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        characterHeader(proxy: proxy)
                            .padding(8)
                        identitySection
                        arcCard
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationDestination(isPresented: $showArc) {
            CharacterArcView(viewModel: viewModel)
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { overflowMenu }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(IdentityUIStrings.nameFieldDone) { nameFocused = false }
                    .font(.body.weight(.semibold))
            }
        }
        .onAppear {
            if viewModel.shouldFocusName { nameFocused = true }
        }
        .onDisappear { Task { await viewModel.flush() } }
        // A fully custom pop-up: system alerts inherit the brand tint and can
        // draw the cancel capsule with a label in the same colour as its fill.
        .confirmDialog(
            isPresented: $showDeleteConfirm,
            icon: "trash.fill",
            title: L10n.CharacterUI.deleteTitle,
            message: viewModel.deleteConfirmMessage,
            confirmTitle: L10n.Action.delete,
            cancelTitle: L10n.Action.cancel
        ) {
            Haptics.warning()
            viewModel.requestDelete()
            dismiss()
        }
    }

    // MARK: - Header

    /// The character's stated intention, or a gentle nudge when it is empty.
    private var intentionText: String {
        let trimmed = viewModel.draft.intention.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? CharacterArcField.intention.prompt : trimmed
    }

    private var hasIntention: Bool {
        !viewModel.draft.intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// "Wants to: …" once an intention exists; the bare prompt while it is empty.
    private var intentionLine: Text {
        guard hasIntention else { return Text(intentionText) }
        return Text(IdentityUIStrings.intentionPrefix)
            .fontWeight(.semibold)
            .foregroundColor(palette.textPrimary)
            + Text(" " + intentionText)
    }

    private func characterHeader(proxy: ScrollViewProxy) -> some View {
        let next = viewModel.nextOverallTarget
        return VStack(alignment: .leading, spacing: 12) {
            ProgressHeader(
                title: viewModel.headerTitle,
                systemImage: "person.crop.circle",
                titleIsPlaceholder: !viewModel.hasName,
                titleBinding: $viewModel.draft.name,
                titlePlaceholder: IdentityUIStrings.nameFieldPrompt,
                titleAccessibilityLabel: IdentityUIStrings.nameFieldLabel,
                titleFocus: $nameFocused,
                filled: viewModel.overallFilledCount,
                total: viewModel.overallTotalCount,
                completeText: IdentityUIStrings.characterComplete,
                nextFieldTitle: next?.title,
                onNextTapped: { jump(to: next, proxy: proxy) }
            )
            intentionLine
                .font(.subheadline)
                .foregroundStyle(hasIntention ? palette.textMuted : palette.textMuted.opacity(0.7))
                .lineLimit(3)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: intentionText)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Send the writer to whatever is still missing: identity rows live on this
    /// screen, arc fields live one push away in the Arc editor.
    private func jump(to target: CharacterProgressTarget?, proxy: ScrollViewProxy) {
        guard let target else { return }
        switch target {
        case .identity(let field):
            if field == .name {
                nameFocused = true
                return
            }
            withAnimation(.easeInOut(duration: 0.35)) {
                proxy.scrollTo(identityAnchor, anchor: .center)
            }
        case .arc:
            showArc = true
        }
    }

    // MARK: - Arc card

    /// The arc is a doorway to another screen rather than a field, so it stands
    /// on its own below Identity with room for its progress.
    private var arcCard: some View {
        NavigationLink {
            CharacterArcView(viewModel: viewModel)
        } label: {
            HStack(spacing: 12) {
                arcGlyph
                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.CharacterUI.arcTitle)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(palette.textPrimary)
                    Text(IdentityUIStrings.arcCardSubtitle)
                        .font(.caption)
                        .foregroundStyle(palette.textMuted)
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                ProgressBadge(
                    filled: viewModel.arcFilledCount,
                    total: viewModel.arcTotalCount,
                    completeText: L10n.CharacterUI.arcComplete
                )
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
            }
            .padding(14)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var arcGlyph: some View {
        Image(systemName: "chart.line.uptrend.xyaxis")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.accent)
            .frame(width: 34, height: 34)
            .background(palette.accent.opacity(0.14), in: Circle())
    }

    /// Identity carries no frame of its own: the title floats on the gradient
    /// like the header above it, and each field keeps its single card. The name
    /// itself lives in the header, so this is purely the three choices.
    private var identitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(IdentityUIStrings.sectionTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .padding(.leading, 4)
            identityRows
                .id(identityAnchor)
        }
    }

    // MARK: - Identity rows

    private var identityRows: some View {
        let role = viewModel.draft.identity.role
        return VStack(spacing: 10) {
            roleRow
            traitRow(
                title: IdentityUIStrings.archetypeRow,
                intro: .archetype,
                catalog: IdentityCatalog.archetypes,
                nudge: IdentityUIStrings.archetypeNudge,
                suggestedSlugs: IdentityRelevance.suggestedArchetypeSlugs(for: role),
                selection: $viewModel.draft.identity.archetypes
            )
            traitRow(
                title: IdentityUIStrings.storyFunctionRow,
                intro: .storyFunction,
                catalog: IdentityCatalog.storyFunctions,
                nudge: IdentityUIStrings.storyFunctionNudge,
                suggestedSlugs: IdentityRelevance.suggestedStoryFunctionSlugs(for: role),
                selection: $viewModel.draft.identity.storyFunctions,
                tint: IdentityHue.storyFunction
            )
        }
    }

    private var roleRow: some View {
        NavigationLink {
            RolePickerDetailView(
                characterName: viewModel.navigationTitle,
                selection: viewModel.draft.identity.role
            ) { newRole in
                viewModel.applyRole(newRole)
            }
        } label: {
            identityRowLabel(title: IdentityUIStrings.roleRow, systemImage: IdentitySectionIntro.role.symbol) {
                Text(viewModel.roleDisplayText ?? IdentityUIStrings.noneValue)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundStyle(viewModel.roleDisplayText == nil ? palette.textMuted.opacity(0.7) : palette.accent)
            }
        }
        .buttonStyle(.plain)
    }

    private func traitRow(
        title: String,
        intro: IdentitySectionIntro,
        catalog: [IdentityCatalogEntry],
        nudge: String,
        suggestedSlugs: [String],
        selection: Binding<[IdentityTrait]>,
        tint: Color? = nil
    ) -> some View {
        let names = selection.wrappedValue.map { IdentityCatalog.displayName(for: $0, in: catalog) }
        return VStack(alignment: .leading, spacing: 10) {
            NavigationLink {
                traitPicker(
                    title: title,
                    intro: intro,
                    catalog: catalog,
                    nudge: nudge,
                    suggestedSlugs: suggestedSlugs,
                    selection: selection
                )
            } label: {
                traitRowHeader(title: title, systemImage: intro.symbol, count: names.count)
            }
            .buttonStyle(.plain)

            if !names.isEmpty {
                TraitChipsWrap(names: names, tint: tint) { index in
                    traitPicker(
                        title: title,
                        intro: intro,
                        catalog: catalog,
                        nudge: nudge,
                        suggestedSlugs: suggestedSlugs,
                        selection: selection,
                        focus: selection.wrappedValue.indices.contains(index) ? selection.wrappedValue[index] : nil
                    )
                }
                .padding(.leading, 30)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: names)
        .padding(12)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    /// Shared picker destination for a multi-select row — used by both the row
    /// itself and by each selected chip (which opens focused on its trait).
    private func traitPicker(
        title: String,
        intro: IdentitySectionIntro,
        catalog: [IdentityCatalogEntry],
        nudge: String,
        suggestedSlugs: [String],
        selection: Binding<[IdentityTrait]>,
        focus: IdentityTrait? = nil
    ) -> some View {
        TraitPickerDetailView(
            title: title,
            characterName: viewModel.navigationTitle,
            intro: intro,
            catalog: catalog,
            nudge: nudge,
            roleName: viewModel.roleDisplayText,
            suggestedSlugs: suggestedSlugs,
            selection: selection,
            focusTrait: focus
        )
    }

    /// Row header for a multi-select field: icon, title, a summary of how many
    /// traits are chosen, and the disclosure chevron. The chips themselves live
    /// below so long selections never squeeze the title.
    private func traitRowHeader(title: String, systemImage: String, count: Int) -> some View {
        HStack(spacing: 8) {
            rowIcon(systemImage)
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(palette.textPrimary)
            Spacer(minLength: 8)
            Text(count == 0 ? IdentityUIStrings.noneValue : IdentityUIStrings.selectedCount(count))
                .font(.subheadline)
                .foregroundStyle(count == 0 ? palette.textMuted.opacity(0.7) : palette.accent)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted)
        }
        .contentShape(Rectangle())
    }

    /// Consistent leading glyph for every row inside the Identity section.
    private func rowIcon(_ systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.accent)
            .frame(width: 22, alignment: .center)
    }

    private func identityRowLabel(
        title: String,
        systemImage: String,
        @ViewBuilder value: () -> some View
    ) -> some View {
        HStack(spacing: 8) {
            rowIcon(systemImage)
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(palette.textPrimary)
            Spacer(minLength: 8)
            value()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted)
        }
        .padding(12)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    // MARK: - Delete

    /// Character-level actions live in the navigation bar so the page body
    /// stays focused on writing, and destructive actions are never a stray tap
    /// away at the end of a scroll.
    @ToolbarContentBuilder
    private var overflowMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    focusName()
                } label: {
                    Label(IdentityUIStrings.changeNameAction, systemImage: "textformat")
                }
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label(L10n.CharacterUI.deleteButton, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(palette.accent)
            }
            .accessibilityLabel(IdentityUIStrings.moreActions)
        }
    }

    /// Menus dismiss asynchronously, so give the sheet a beat before claiming
    /// focus or the keyboard never appears.
    private func focusName() {
        Haptics.selection()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            nameFocused = true
        }
    }

}
#if DEBUG

private enum CharacterDetailPreviewData {

    static let partial = Character(
        uuid: "preview-partial",
        name: "Mara Vale",
        role: "Protagonist",
        intention: "Recover the stolen memory and prove the archive is lying.",
        whyIntention: "Without it she cannot prove her sister ever existed.",
        whatToDo: "Break into the Ledger and pull the original shard.",
        howDoesCharacterDoIt: "",
        obstacles: "The city's every camera already knows her face.",
        flaws: "She trusts data more than people.",
        intentionFix: "",
        need: "",
        howCharacterChanged: "",
        notes: ""
    )

    static let complete = Character(
        uuid: "preview-complete",
        name: "Idris Kwan",
        role: "Antagonist",
        intention: "Keep the archive sealed at any cost.",
        whyIntention: "He wrote the lie that holds the city together.",
        whatToDo: "Erase every witness to the original upload.",
        howDoesCharacterDoIt: "Through proxies, favours and quiet edits.",
        obstacles: "Mara remembers what he deleted.",
        flaws: "He mistakes control for care.",
        intentionFix: "Confess before the final upload.",
        need: "To be forgiven rather than obeyed.",
        howCharacterChanged: "He hands Mara the key and walks into the light.",
        notes: "Speaks softly, never raises his voice."
    )

    @MainActor
    static func viewModel(for character: Character) -> CharactersViewModel {
        CharactersViewModel(
            screenplayID: "preview-screenplay",
            characters: [character],
            repository: MockScreenplayRepository(seedSamples: false)
        )
    }
}

#Preview("Arc in progress") {
    let character = CharacterDetailPreviewData.partial
    return NavigationStack {
        CharacterDetailView(character: character, viewModel: CharacterDetailPreviewData.viewModel(for: character))
    }
}

#Preview("Arc complete — Dark") {
    let character = CharacterDetailPreviewData.complete
    return NavigationStack {
        CharacterDetailView(character: character, viewModel: CharacterDetailPreviewData.viewModel(for: character))
    }
    .preferredColorScheme(.dark)
}

#endif
