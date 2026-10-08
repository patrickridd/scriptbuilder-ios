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
    @State private var showArc = false
    @State private var showSettings = false
    /// Identity step the header's "Next up" nudge is pushing, if any.
    @State private var pickerField: CharacterIdentityField?
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
                        behaviorSection
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
        .navigationDestination(item: $pickerField) { field in
            identityPicker(for: field)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                CharacterSettingsView(viewModel: viewModel) {
                    showSettings = false
                    viewModel.requestDelete()
                    dismiss()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(IdentityUIStrings.settingsSave) { showSettings = false }
                            .fontWeight(.semibold)
                            .foregroundStyle(palette.accent)
                    }
                }
            }
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
                onNextTapped: { jump(to: next, proxy: proxy) },
                nextFieldGlyph: nudgeGlyph(for: next)
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

    /// Send the writer to whatever is still missing: the name lives in the
    /// header, the identity facets each own a picker one push away, and arc
    /// fields live in the Arc editor.
    private func jump(to target: CharacterProgressTarget?, proxy: ScrollViewProxy) {
        guard let target else { return }
        switch target {
        case .identity(let field):
            if field == .name {
                nameFocused = true
                return
            }
            nameFocused = false
            pickerField = field
        case .arc:
            showArc = true
        }
    }

    /// The nudge's trailing glyph tells the writer what the tap will do: edit
    /// the name in place, or push the step's own editor.
    private func nudgeGlyph(for target: CharacterProgressTarget?) -> String {
        if case .identity(.name) = target { return "pencil.circle.fill" }
        return "chevron.right.circle.fill"
    }

    /// Destination for the "Next up" nudge — the very same picker the matching
    /// identity row pushes, so both routes stay in sync.
    @ViewBuilder
    private func identityPicker(for field: CharacterIdentityField) -> some View {
        switch field {
        case .role:
            rolePicker
        case .archetype:
            traitPicker(archetypeSpec, selection: $viewModel.draft.identity.archetypes)
        case .storyFunction:
            traitPicker(storyFunctionSpec, selection: $viewModel.draft.identity.storyFunctions)
        case .name:
            EmptyView()
        }
    }

    // MARK: - Arc card

    /// The arc is a doorway to another screen rather than a field. It sits in
    /// Behavior beneath Story Function, with room for its progress badge.
    private var arcCard: some View {
        NavigationLink {
            CharacterArcView(viewModel: viewModel)
        } label: {
            HStack(spacing: 8) {
                arcGlyph
                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.CharacterUI.arcTitle)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(palette.textPrimary)
                    Text(viewModel.arcNotApplicable
                         ? IdentityUIStrings.arcNotApplicableTitle
                         : IdentityUIStrings.arcCardSubtitle)
                        .font(.caption)
                        .foregroundStyle(palette.textMuted)
                        .lineLimit(2)
                }
                Spacer(minLength: 4)
                ProgressBadge(
                    filled: viewModel.arcFilledCount,
                    total: viewModel.arcTotalCount,
                    completeText: viewModel.arcCompleteText
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
            sectionTitle(IdentityUIStrings.sectionTitle)
            identityRows
                .id(identityAnchor)
        }
    }

    /// Behavior collects what the character *does* — their story function —
    /// and how they change across the script, so the arc sits with it.
    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(IdentityUIStrings.behaviorSectionTitle)
            VStack(spacing: 10) {
                storyFunctionRow
                arcCard
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.textPrimary)
            .padding(.leading, 4)
    }

    // MARK: - Identity rows

    private var identityRows: some View {
        VStack(spacing: 10) {
            roleRow
            traitRow(archetypeSpec, selection: $viewModel.draft.identity.archetypes)
        }
    }

    /// Step 2 — the archetype row, hidden families and gate copy included.
    private var archetypeSpec: TraitRowSpec {
        let role = viewModel.draft.identity.role
        let archetypes = viewModel.draft.identity.archetypes
        return TraitRowSpec(
            step: 2,
            title: IdentityUIStrings.archetypeRow,
            prompt: IdentityUIStrings.archetypePrompt,
            intro: .archetype,
            catalog: IdentityRelevance.archetypeCatalog(for: role, selection: archetypes),
            nudge: IdentityUIStrings.archetypeNudge,
            suggestedSlugs: IdentityRelevance.suggestedArchetypeSlugs(for: role),
            gateHint: role == nil ? IdentityUIStrings.archetypeGateHint : nil,
            gateBanner: role == nil ? IdentityUIStrings.archetypeGateBanner : nil,
            roleExclusiveFamilies: IdentityRelevance.hiddenRoleExclusiveFamilies(
                for: role,
                selection: archetypes
            ),
            tint: IdentityHue.archetype,
            glyph: IdentityHue.glyph(for: .archetype)
        )
    }

    /// Lives under Behavior but keeps step 3 of the identity sequence, so the
    /// numbered badges still read 1 → 2 → 3 down the screen.
    private var storyFunctionRow: some View {
        traitRow(storyFunctionSpec, selection: $viewModel.draft.identity.storyFunctions)
    }

    /// Step 3 — the story-function row, including the role-restriction notice.
    private var storyFunctionSpec: TraitRowSpec {
        let role = viewModel.draft.identity.role
        let archetypes = viewModel.draft.identity.archetypes
        let functions = viewModel.draft.identity.storyFunctions
        let hiddenCount = IdentityRelevance.hiddenStoryFunctionCount(
            for: role,
            selection: functions
        )
        let ownerRoleName = IdentityRelevance.hiddenStoryFunctionOwnerRoleName(
            for: role,
            selection: functions
        )
        let blockedNotice = storyFunctionBlockedNotice(
            count: hiddenCount,
            ownerRoleName: ownerRoleName
        )
        return TraitRowSpec(
            step: 3,
            title: IdentityUIStrings.storyFunctionRow,
            prompt: IdentityUIStrings.storyFunctionPrompt,
            intro: .storyFunction,
            catalog: IdentityRelevance.storyFunctionCatalog(for: role, selection: functions),
            nudge: IdentityUIStrings.storyFunctionNudge,
            suggestedSlugs: IdentityRelevance.suggestedStoryFunctionSlugs(
                for: role,
                archetypes: archetypes
            ),
            suggestionSources: IdentityRelevance.storyFunctionSuggestionSources(
                role: role,
                roleName: viewModel.roleDisplayText,
                archetypes: archetypes
            ),
            gateHint: archetypes.isEmpty ? IdentityUIStrings.storyFunctionGateHint : nil,
            gateBanner: archetypes.isEmpty ? IdentityUIStrings.storyFunctionGateBanner : nil,
            blockedNotice: blockedNotice,
            tint: IdentityHue.storyFunction,
            glyph: IdentityHue.glyph(for: .storyFunction)
        )
    }

    /// Names the owning role when the hidden jobs all belong to one ("3
    /// Protagonist-only jobs"); otherwise stays neutral, because a lead hides a
    /// mixed bag of opposition jobs that no single role owns.
    private func storyFunctionBlockedNotice(
        count: Int,
        ownerRoleName: String?
    ) -> String? {
        guard count > 0, let roleName = viewModel.roleDisplayText else { return nil }
        if let ownerRoleName {
            return IdentityUIStrings.roleOnlyFunctionNotice(
                count: count,
                roleName: ownerRoleName
            )
        }
        return IdentityUIStrings.blockedFunctionNotice(count: count, roleName: roleName)
    }

    private var roleRow: some View {
        let hue = IdentityHue.role
        return NavigationLink {
            rolePicker
        } label: {
            identityRowLabel(
                step: 1,
                title: IdentityUIStrings.roleRow,
                hue: hue,
                glyph: IdentityHue.glyph(for: .role)
            ) {
                identityRowValue(
                    text: viewModel.roleDisplayText ?? IdentityUIStrings.rolePrompt,
                    isPrompt: viewModel.roleDisplayText == nil,
                    hue: hue
                )
            }
        }
        .buttonStyle(.plain)
    }

    /// Step 1's destination, shared by the row and the header's nudge.
    private var rolePicker: some View {
        RolePickerDetailView(
            characterName: viewModel.navigationTitle,
            selection: viewModel.draft.identity.role,
            tint: IdentityHue.role
        ) { newRole in
            viewModel.applyRole(newRole)
        }
    }

    /// Numbered badge that makes the craft sequence visible — Role, then
    /// Archetype, then Story Function — without ever locking a row. The badge
    /// carries the facet's own hue so the number and its chips match.
    private func stepBadge(_ step: Int, hue: Color, dimmed: Bool) -> some View {
        let tint = dimmed ? palette.textMuted : hue
        return Text("\(step)")
            .font(.caption.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(tint)
            .frame(width: 24, height: 24)
            .background(tint.opacity(0.15), in: Circle())
            .accessibilityLabel(IdentityUIStrings.stepLabel(step))
    }

    private func traitRow(
        _ spec: TraitRowSpec,
        selection: Binding<[IdentityTrait]>
    ) -> some View {
        let names = selection.wrappedValue.map { IdentityCatalog.displayName(for: $0, in: spec.catalog) }
        let dimmed = spec.gateHint != nil && names.isEmpty
        return VStack(alignment: .leading, spacing: 10) {
            NavigationLink {
                traitPicker(spec, selection: selection)
            } label: {
                traitRowHeader(
                    step: spec.step,
                    title: spec.title,
                    count: names.count,
                    prompt: spec.prompt,
                    hint: names.isEmpty ? spec.gateHint : nil,
                    dimmed: dimmed,
                    hue: spec.tint,
                    glyph: spec.glyph
                )
            }
            .buttonStyle(.plain)

            if !names.isEmpty {
                TraitChipsWrap(names: names, tint: spec.tint, glyph: spec.glyph) { index in
                    traitPicker(
                        spec,
                        selection: selection,
                        focus: selection.wrappedValue.indices.contains(index) ? selection.wrappedValue[index] : nil
                    )
                }
                .padding(.leading, 32)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: names)
        .padding(12)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    /// Shared picker destination for a multi-select row — used by the row, by
    /// each selected chip (focused on its trait), and by the "Next up" nudge.
    private func traitPicker(
        _ spec: TraitRowSpec,
        selection: Binding<[IdentityTrait]>,
        focus: IdentityTrait? = nil
    ) -> some View {
        TraitPickerDetailView(
            title: spec.title,
            characterName: viewModel.navigationTitle,
            intro: spec.intro,
            catalog: spec.catalog,
            nudge: spec.nudge,
            roleName: viewModel.roleDisplayText,
            suggestionSources: spec.suggestionSources,
            suggestedSlugs: spec.suggestedSlugs,
            selection: selection,
            focusTrait: focus,
            gateBanner: spec.gateBanner,
            roleExclusiveFamilies: spec.roleExclusiveFamilies,
            blockedNotice: spec.blockedNotice,
            tint: spec.tint,
            glyph: spec.glyph
        )
    }

    /// Row header for a multi-select field: step number, title, a summary of how
    /// many traits are chosen, and the disclosure chevron. A gate hint sits
    /// under the title while the earlier step is still empty.
    private func traitRowHeader(
        step: Int,
        title: String,
        count: Int,
        prompt: String,
        hint: String?,
        dimmed: Bool,
        hue: Color,
        glyph: String? = nil
    ) -> some View {
        HStack(spacing: 8) {
            stepBadge(step, hue: hue, dimmed: dimmed)
            VStack(alignment: .leading, spacing: 2) {
                facetTitle(title, hue: hue, dimmed: dimmed, glyph: glyph)
                if let hint {
                    Text(hint)
                        .font(.caption2)
                        .foregroundStyle(palette.textMuted.opacity(0.85))
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 8)
            Text(count == 0 ? prompt : IdentityUIStrings.selectedCount(count))
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .foregroundStyle(count == 0 ? hue.opacity(0.75) : hue)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted)
        }
        .contentShape(Rectangle())
    }

    /// Row title with its facet glyph — the same symbol that rides every chip
    /// and picker card for this facet, so the shape teaches the category.
    private func facetTitle(
        _ title: String,
        hue: Color,
        dimmed: Bool,
        glyph: String?
    ) -> some View {
        HStack(spacing: 6) {
            if let glyph, !glyph.isEmpty {
                Image(systemName: glyph)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(dimmed ? palette.textMuted : hue)
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(dimmed ? palette.textMuted : palette.textPrimary)
        }
    }

    /// Value shown on the right of an identity row. When nothing is chosen yet
    /// we show a question in the facet's own hue — an invitation to tap, rather
    /// than a flat "None".
    private func identityRowValue(text: String, isPrompt: Bool, hue: Color) -> some View {
        Text(text)
            .font(.subheadline)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .foregroundStyle(isPrompt ? hue.opacity(0.75) : hue)
    }

    private func identityRowLabel(
        step: Int,
        title: String,
        hue: Color,
        glyph: String? = nil,
        @ViewBuilder value: () -> some View
    ) -> some View {
        HStack(spacing: 8) {
            stepBadge(step, hue: hue, dimmed: false)
            facetTitle(title, hue: hue, dimmed: false, glyph: glyph)
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
            Button {
                Haptics.selection()
                nameFocused = false
                showSettings = true
            } label: {
                Image(systemName: "ellipsis.circle")                    .foregroundStyle(palette.accent)
            }
            .accessibilityLabel(IdentityUIStrings.settingsAction)
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

    /// A character who genuinely wants nothing — the iceberg case. Arc waived,
    /// so the arc badge reads "No arc needed" and stops counting against them.
    static let noArc = Character(
        uuid: "preview-no-arc",
        name: "The Iceberg",
        role: "Antagonist",
        notes: "A force of nature, not a person. It has no desire, only mass.",
        arcNotApplicable: true
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

#Preview("No arc needed") {
    let character = CharacterDetailPreviewData.noArc
    return NavigationStack {
        CharacterDetailView(
            character: character,
            viewModel: CharacterDetailPreviewData.viewModel(for: character),
            screenplayTitle: "The Neon Protocol"
        )
    }
}

#Preview("No arc needed — Dark") {
    let character = CharacterDetailPreviewData.noArc
    return NavigationStack {
        CharacterDetailView(
            character: character,
            viewModel: CharacterDetailPreviewData.viewModel(for: character),
            screenplayTitle: "The Neon Protocol"
        )
    }
    .preferredColorScheme(.dark)
}

#endif
