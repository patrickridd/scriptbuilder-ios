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
    @State private var focusRequest: AnyHashable?
    @FocusState private var nameFocused: Bool

    init(character: Character, viewModel: CharactersViewModel) {
        _viewModel = State(initialValue: CharacterDetailViewModel(character: character, viewModel: viewModel))
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        arcHeader(proxy: proxy)
                        basicInfoCard
                        arcFields
                        deleteButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.shouldFocusName { nameFocused = true }
        }
        .onDisappear { Task { await viewModel.flush() } }
        .alert(L10n.CharacterUI.deleteTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.Action.delete, role: .destructive) {
                Haptics.warning()
                viewModel.requestDelete()
                dismiss()
            }
            Button(L10n.Action.cancel, role: .cancel) { }
        } message: {
            Text(viewModel.deleteConfirmMessage)
        }
    }

    // MARK: - Arc progress

    private var arcFilledCount: Int { CharacterArcField.filledCount(for: viewModel.draft) }
    private var arcTotalCount: Int { CharacterArcField.scoreable.count }

    private var nextArcField: CharacterArcField? {
        CharacterArcField.firstUnfilled(for: viewModel.draft)
    }

    private func arcHeader(proxy: ScrollViewProxy) -> some View {
        ProgressHeader(
            title: L10n.CharacterUI.arcTitle,
            filled: arcFilledCount,
            total: arcTotalCount,
            completeText: L10n.CharacterUI.arcComplete,
            nextFieldTitle: nextArcField?.title,
            onNextTapped: {
                guard let field = nextArcField else { return }
                focusRequest = AnyHashable(field)
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo(field, anchor: .top)
                }
            }
        )
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
                catalog: IdentityCatalog.archetypes,
                nudge: IdentityUIStrings.archetypeNudge,
                selection: $viewModel.draft.identity.archetypes
            )
            traitRow(
                title: IdentityUIStrings.storyFunctionRow,
                catalog: IdentityCatalog.storyFunctions,
                nudge: IdentityUIStrings.storyFunctionNudge,
                selection: $viewModel.draft.identity.storyFunctions
            )
        }
    }

    private var roleRow: some View {
        NavigationLink {
            RolePickerDetailView(selection: viewModel.draft.identity.role) { newRole in
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
        catalog: [IdentityCatalogEntry],
        nudge: String,
        selection: Binding<[IdentityTrait]>
    ) -> some View {
        let names = selection.wrappedValue.map { IdentityCatalog.displayName(for: $0, in: catalog) }
        return NavigationLink {
            TraitPickerDetailView(title: title, catalog: catalog, nudge: nudge, selection: selection)
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

    private var arcFields: some View {
        VStack(spacing: 14) {
            ForEach(CharacterArcField.allCases) { field in
                ExpandableTextField(
                    title: field.title,
                    prompt: field.prompt,
                    systemImage: field.systemImage,
                    focusRequest: $focusRequest,
                    focusID: AnyHashable(field),
                    text: binding(for: field)
                )
                .id(field)
            }
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label(L10n.CharacterUI.deleteButton, systemImage: "trash")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.red.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .padding(.top, 16)
    }

    /// Return the real state-backed binding for a field. Hand-made
    /// `Binding(get:set:)` closures go stale inside `fullScreenCover` and
    /// silently drop writes — direct `$model.draft.<field>` bindings are tracked
    /// by SwiftUI/Observation and stay live everywhere.
    private func binding(for field: CharacterArcField) -> Binding<String> {
        switch field {
        case .intention: return $viewModel.draft.intention
        case .whyIntention: return $viewModel.draft.whyIntention
        case .whatToDo: return $viewModel.draft.whatToDo
        case .howDoesCharacterDoIt: return $viewModel.draft.howDoesCharacterDoIt
        case .obstacles: return $viewModel.draft.obstacles
        case .flaws: return $viewModel.draft.flaws
        case .intentionFix: return $viewModel.draft.intentionFix
        case .need: return $viewModel.draft.need
        case .howCharacterChanged: return $viewModel.draft.howCharacterChanged
        case .notes: return $viewModel.draft.notes
        }
    }

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
