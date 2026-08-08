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
    @FocusState private var nameFocused: Bool

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
            ScrollView {
                VStack(spacing: 16) {
                    characterHeader
                    basicInfoCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { overflowMenu }
        .onAppear {
            if viewModel.shouldFocusName { nameFocused = true }
        }
        .onDisappear { Task { await viewModel.flush() } }
        // Alerts inherit the surrounding tint. A custom brand tint makes iOS 26
        // draw the prominent cancel capsule with a label in the same colour as
        // its fill, so we hand the alert the system tint instead.
        .tint(.blue)
        .alert(L10n.CharacterUI.deleteTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.Action.cancel, role: .cancel) { }
            Button(L10n.Action.delete, role: .destructive) {
                Haptics.warning()
                viewModel.requestDelete()
                dismiss()
            }
        } message: {
            Text(viewModel.deleteConfirmMessage)
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

    private var characterHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(viewModel.navigationTitle)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(2)
            }
            Text(intentionText)
                .font(.subheadline)
                .foregroundStyle(hasIntention ? palette.textMuted : palette.textMuted.opacity(0.7))
                .lineLimit(3)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: intentionText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Arc row

    private var arcRow: some View {
        NavigationLink {
            CharacterArcView(viewModel: viewModel)
        } label: {
            HStack(spacing: 8) {
                Label(L10n.CharacterUI.arcTitle, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.textPrimary)
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
            .padding(12)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var hairline: some View {
        Rectangle()
            .fill(palette.cardStroke)
            .frame(height: 1)
            .padding(.vertical, 2)
    }

    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            fieldLabel(L10n.CharacterUI.fieldName, systemImage: "person.text.rectangle")
            TextField(L10n.CharacterUI.fieldName, text: $viewModel.draft.name)
                .font(.body)
                .focused($nameFocused)
                .foregroundStyle(palette.textPrimary)
                .tint(palette.accent)
                .padding(12)
                .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))

            hairline
            arcRow
            hairline

            fieldLabel(IdentityUIStrings.sectionTitle, systemImage: "theatermasks")
            identityRows
        }
        .padding(16)
        .background(palette.cardSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    // MARK: - Identity rows

    private var identityRows: some View {
        VStack(spacing: 10) {
            roleRow
            traitRow(
                title: IdentityUIStrings.archetypeRow,
                intro: .archetype,
                catalog: IdentityCatalog.archetypes,
                nudge: IdentityUIStrings.archetypeNudge,
                selection: $viewModel.draft.identity.archetypes
            )
            traitRow(
                title: IdentityUIStrings.storyFunctionRow,
                intro: .storyFunction,
                catalog: IdentityCatalog.storyFunctions,
                nudge: IdentityUIStrings.storyFunctionNudge,
                selection: $viewModel.draft.identity.storyFunctions
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
            identityRowLabel(title: IdentityUIStrings.roleRow) {
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
        selection: Binding<[IdentityTrait]>
    ) -> some View {
        let names = selection.wrappedValue.map { IdentityCatalog.displayName(for: $0, in: catalog) }
        return NavigationLink {
            TraitPickerDetailView(
                title: title,
                characterName: viewModel.navigationTitle,
                intro: intro,
                catalog: catalog,
                nudge: nudge,
                selection: selection
            )
        } label: {
            identityRowLabel(title: title) {
                if names.isEmpty {
                    Text(IdentityUIStrings.noneValue)
                        .font(.subheadline)
                        .foregroundStyle(palette.textMuted.opacity(0.7))
                } else {
                    TraitChipsPreview(names: names)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func identityRowLabel(title: String, @ViewBuilder value: () -> some View) -> some View {
        HStack(spacing: 8) {
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
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label(L10n.CharacterUI.deleteButton, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(palette.accent)
            }
            .accessibilityLabel(L10n.CharacterUI.deleteButton)
        }
    }

    /// Section label used above the name field and identity rows.
    private func fieldLabel(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.textPrimary)
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
