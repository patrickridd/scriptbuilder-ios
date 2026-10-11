import SwiftUI
import Domain
import DesignSystem

/// The editor for one outline section. For the Idea section it shows the six
/// idea fields; for an act it shows the act's "overall description" plus that
/// act's narrative beats, headed by an ⓘ info popover. Every field is an
/// auto-growing `ExpandableTextField` bound through `OutlineViewModel`, which
/// autosaves each edit non-destructively. Purely declarative.
struct OutlineSectionDetailView: View {
    @Environment(\.appPalette) var palette
    @Bindable var viewModel: OutlineViewModel
    let section: OutlineSection
    @State private var showBeatsInfo = false
    @State var isArranging = false
    @State private var focusRequest: AnyHashable?
    /// A custom beat with writing in it that's waiting on delete confirmation.
    @State private var pendingDeleteID: String?
    let gate: EditorGate
    /// Re-renders the PRO marker live after a purchase / restore / expiry.
    @ObservedObject private var entitlementSignal: EditorEntitlementSignal

    init(section: OutlineSection, viewModel: OutlineViewModel, gate: EditorGate = .unrestricted) {
        self.section = section
        self.viewModel = viewModel
        self.gate = gate
        _entitlementSignal = ObservedObject(wrappedValue: gate.entitlementSignal)
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        progressHeader(proxy: proxy)
                            .padding(8)
                        if section == .idea {
                            ideaFields
                        } else {
                            overallDescriptionField
                            beatsHeader
                            beatsFields
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: focusRequest) { _, requested in
                    scrollToRequested(requested, proxy: proxy)
                }
            }
        }
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
        // Same delete pop-up as characters, scenes and screenplays.
        .deleteDialog(
            isPresented: isConfirmingDelete,
            title: L10n.CustomBeatCopy.deleteConfirmTitle,
            message: L10n.CustomBeatCopy.deleteConfirmMessage,
            deleteTitle: L10n.Action.delete,
            cancelTitle: L10n.Action.cancel
        ) {
            if let id = pendingDeleteID { performDelete(id) }
        }
        .sheet(isPresented: $isArranging) {
            ArrangeBeatsView(viewModel: viewModel, gate: gate)
        }
    }

    /// Brings a freshly added custom beat into view (focus follows via the
    /// field's own handling of `focusRequest`).
    private func scrollToRequested(_ requested: AnyHashable?, proxy: ScrollViewProxy) {
        guard let anchor = requested?.base as? OutlineViewModel.FieldAnchor,
              case .custom = anchor else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            proxy.scrollTo(anchor, anchor: .center)
        }
    }

    /// The screenplay's title, since the section name already appears in the
    /// on-screen header. Falls back to the section title for untitled drafts.
    private var navigationTitleText: String {
        let name = viewModel.screenplay.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? section.title : name
    }

    // MARK: - Progress header

    private var progress: (filled: Int, total: Int) { viewModel.filledCount(for: section) }

    private func progressHeader(proxy: ScrollViewProxy) -> some View {
        let next = viewModel.firstUnfilled(for: section)
        return ProgressHeader(
            title: section.title,
            systemImage: section.systemImage,
            filled: progress.filled,
            total: progress.total,
            completeText: L10n.Outline.sectionComplete,
            nextFieldTitle: next?.title,
            onNextTapped: {
                guard let anchor = next?.anchor else { return }
                focusRequest = AnyHashable(anchor)
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo(anchor, anchor: .top)
                }
            }
        )
    }

    // MARK: - Idea

    private var ideaFields: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.ideaFieldSpecs) { spec in
                ExpandableTextField(
                    title: spec.isOptional ? L10n.Action.optional(spec.title) : spec.title,
                    prompt: spec.prompt,
                    systemImage: spec.systemImage,
                    focusRequest: $focusRequest,
                    focusID: AnyHashable(OutlineViewModel.FieldAnchor.outline(spec.field)),
                    text: viewModel.binding(for: spec.field)
                )
                .id(OutlineViewModel.FieldAnchor.outline(spec.field))
            }
        }
    }

    // MARK: - Act sections

    private var overallDescriptionField: some View {
        Group {
            if let field = section.descriptionField {
                ExpandableTextField(
                    title: L10n.Outline.overallDescription,
                    prompt: L10n.Outline.overallPrompt(section.title),
                    systemImage: "text.alignleft",
                    focusRequest: $focusRequest,
                    focusID: AnyHashable(OutlineViewModel.FieldAnchor.outline(field)),
                    text: viewModel.binding(for: field)
                )
                .id(OutlineViewModel.FieldAnchor.outline(field))
            }
        }
    }

    private var beatsHeader: some View {
        HStack(spacing: 8) {
            Text(L10n.Outline.actBeats)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
            Button {
                showBeatsInfo = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Outline.aboutActBeats)
            .popover(isPresented: $showBeatsInfo) {
                beatsInfoPopover
            }
            Spacer()
            arrangeHeaderButton
        }
        .padding(.top, 6)
    }

    private var beatsInfoPopover: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(L10n.Outline.actBeats)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
            }
            Text(viewModel.beatsInfoText)
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .frame(width: 300, alignment: .leading)
        .padding(20)
        .presentationCompactAdaptation(.popover)
    }

    /// Template and custom beats in outline order, closed by the dashed
    /// "+ Add Beat" card.
    private var beatsFields: some View {
        VStack(spacing: 14) {
            if slotIDs.isEmpty { emptyBeatsNote }
            ForEach(viewModel.slots(for: section), id: \.stableID) { slot in
                slotView(slot)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            addBeatCard
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: slotIDs)
    }

    /// Identity-only fingerprint of the outline so the insert/remove spring
    /// doesn't fire on every keystroke.
    private var slotIDs: [String] {
        viewModel.slots(for: section).map(\.stableID)
    }

    @ViewBuilder
    private func slotView(_ slot: CustomBeat.Slot) -> some View {
        switch slot {
        case .template(let beat):
            templateField(beat)
        case .custom(let beat):
            customField(beat)
        }
    }

    @ViewBuilder
    private func templateField(_ beat: ActBeatField) -> some View {
        if viewModel.isDisabled(beat) {
            DisabledBeatRow(title: beat.title) { toggleBeat(beat, disabled: false) }
                .id(OutlineViewModel.FieldAnchor.beat(beat))
        } else {
            ExpandableTextField(
                title: beat.title,
                prompt: beat.subtitle,
                systemImage: "circle.grid.cross",
                focusRequest: $focusRequest,
                focusID: AnyHashable(OutlineViewModel.FieldAnchor.beat(beat)),
                menuItems: templateMenu(for: beat),
                menuLabel: L10n.CustomBeatCopy.options,
                text: viewModel.binding(for: beat)
            )
            .id(OutlineViewModel.FieldAnchor.beat(beat))
        }
    }

    private func templateMenu(for beat: ActBeatField) -> [ExpandableTextField.MenuItem] {
        let insert = ExpandableTextField.MenuItem(
            title: L10n.CustomBeatCopy.insertAfter,
            systemImage: "plus.square.on.square"
        ) { addBeat(after: .template(beat)) }
        return [insert] + moveMenuItems(for: BeatReference(beat)) + [
            ExpandableTextField.MenuItem(
                title: L10n.CustomBeatCopy.disable,
                systemImage: "eye.slash"
            ) { toggleBeat(beat, disabled: true) }
        ]
    }

    private func toggleBeat(_ beat: ActBeatField, disabled: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            viewModel.setBeat(beat, disabled: disabled)
        }
    }

    private func customField(_ beat: CustomBeat) -> some View {
        let anchor = OutlineViewModel.FieldAnchor.custom(beat.id)
        return SwipeToDeleteRow(onDelete: { requestDelete(beat) }) {
            CustomBeatField(
                title: viewModel.titleBinding(forCustomBeat: beat.id, in: section),
                subtitle: viewModel.subtitleBinding(forCustomBeat: beat.id, in: section),
                text: viewModel.textBinding(forCustomBeat: beat.id, in: section),
                focusRequest: $focusRequest,
                focusID: AnyHashable(anchor),
                onInsertAfter: { addBeat(after: .custom(beat)) },
                moveItems: moveMenuItems(for: .custom(beat.id)),
                onDelete: { requestDelete(beat) }
            )
        }
        .id(anchor)
    }

    private var addBeatCard: some View {
        AddSceneCard(
            title: L10n.CustomBeatCopy.addTitle,
            caption: L10n.CustomBeatCopy.addCaption(section.title),
            isLocked: isBeatLocked
        ) {
            addBeat(after: nil)
        }
    }

    // MARK: - Custom beat intents

    /// Whether a *new* beat would hit the free-tier limit for this act.
    /// Existing beats are never locked.
    private var isBeatLocked: Bool {
        _ = entitlementSignal.revision
        return !gate.canAddCustomBeat(viewModel.customBeatCount(for: section))
    }

    /// The single place the custom-beat gate is checked.
    private func addBeat(after slot: CustomBeat.Slot?) {
        guard gate.canAddCustomBeat(viewModel.customBeatCount(for: section)) else {
            gate.onBlocked()
            return
        }
        guard let id = viewModel.addCustomBeat(to: section, after: slot) else { return }
        focusRequest = AnyHashable(OutlineViewModel.FieldAnchor.custom(id))
    }

    /// Empty beats go straight away; beats with writing ask first.
    private func requestDelete(_ beat: CustomBeat) {
        let hasContent = beat.isFilled
            || !beat.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if hasContent {
            pendingDeleteID = beat.id
        } else {
            performDelete(beat.id)
        }
    }

    private func performDelete(_ id: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            viewModel.deleteCustomBeat(id: id, from: section)
        }
        pendingDeleteID = nil
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding(
            get: { pendingDeleteID != nil },
            set: { if !$0 { pendingDeleteID = nil } }
        )
    }
}

private extension CustomBeat.Slot {
    /// Stable identity for `ForEach`. The slot's own `Hashable` includes the
    /// beat's text, so keying on it would rebuild (and unfocus) a custom beat
    /// on every keystroke.
    var stableID: String {
        switch self {
        case .template(let beat): return "template.\(beat.rawValue)"
        case .custom(let beat):   return "custom.\(beat.id)"
        }
    }
}

#if DEBUG
#Preview("Act I") {
    NavigationStack {
        OutlineSectionDetailView(
            section: .actOne,
            viewModel: OutlineViewModel(
                screenplay: MockScreenplayRepository.sampleScreenplays()[0],
                repository: MockScreenplayRepository()
            )
        )
        .environment(\.appPalette, .default)
    }
}

#Preview("Idea") {
    NavigationStack {
        OutlineSectionDetailView(
            section: .idea,
            viewModel: OutlineViewModel(
                screenplay: MockScreenplayRepository.sampleScreenplays()[0],
                repository: MockScreenplayRepository()
            )
        )
        .environment(\.appPalette, .default)
    }
}
#endif
