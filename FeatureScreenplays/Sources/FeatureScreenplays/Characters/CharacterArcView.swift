import SwiftUI
import Domain
import DesignSystem

/// A character's arc questions, pushed from the character detail screen. It
/// shares the caller's `CharacterDetailViewModel`, so edits flow into the
/// same draft and the debounced autosave / flush-on-exit keep working.
///
/// The list follows the character's arc order: stock questions (switched-off
/// ones shown faded with "Enable"), the writer's own questions, a dashed
/// "Add Question" card, and Notes pinned last.
struct CharacterArcView: View {
    @Environment(\.appPalette) private var palette
    @Bindable var viewModel: CharacterDetailViewModel
    private let gate: EditorGate
    @ObservedObject private var entitlementSignal: EditorEntitlementSignal
    @State private var focusRequest: AnyHashable?
    @State private var showArrange = false
    @State private var showDeleteConfirm = false
    @State private var deleteTargetID: String?

    private let notesID = "notes"

    init(viewModel: CharacterDetailViewModel, gate: EditorGate = .unrestricted) {
        _viewModel = Bindable(wrappedValue: viewModel)
        self.gate = gate
        _entitlementSignal = ObservedObject(wrappedValue: gate.entitlementSignal)
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        arcHeader(proxy: proxy)
                        if viewModel.draft.arcNotApplicable { waivedNote } else { arrangeBar }
                        questionList
                        notesField
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showArrange) {
            ArrangeQuestionsView(viewModel: viewModel, gate: gate)
        }
        .deleteDialog(
            isPresented: $showDeleteConfirm,
            title: L10n.ArcQuestionCopy.deleteTitle,
            message: L10n.ArcQuestionCopy.deleteMessage,
            deleteTitle: L10n.ArcQuestionCopy.deleteConfirm,
            cancelTitle: L10n.ArcQuestionCopy.cancel,
            onDelete: confirmDelete
        )
        .onDisappear { Task { await viewModel.flush() } }
    }

    // MARK: - Header

    private func arcHeader(proxy: ScrollViewProxy) -> some View {
        let next = viewModel.nextArcSlot
        return ProgressHeader(
            title: L10n.CharacterUI.arcTitle,
            systemImage: "chart.line.uptrend.xyaxis",
            filled: viewModel.arcFilledCount,
            total: viewModel.arcTotalCount,
            completeText: viewModel.arcCompleteText,
            nextFieldTitle: next?.displayTitle,
            onNextTapped: {
                guard let next else { return }
                focusRequest = AnyHashable(next.stableID)
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo(next.stableID, anchor: .top)
                }
            }
        )
    }

    /// Current order at a glance, plus the door to the Arrange sheet.
    private var arrangeBar: some View {
        HStack(spacing: 8) {
            Text(viewModel.isUsingStandardArcOrder
                 ? L10n.ArcQuestionCopy.standardOrder
                 : L10n.ArcQuestionCopy.customOrder)
                .font(.caption.weight(.medium))
                .foregroundStyle(palette.textMuted)
            Spacer(minLength: 8)
            Button {
                showArrange = true
            } label: {
                Label(L10n.ArcQuestionCopy.arrange, systemImage: "arrow.up.arrow.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(palette.accent.opacity(0.12)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Not applicable

    /// A quiet reminder that the writer already decided this character has no
    /// arc. The switch itself lives in Character Settings, out of the way.
    private var waivedNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.subheadline)
                .foregroundStyle(palette.accent)
            VStack(alignment: .leading, spacing: 3) {
                Text(IdentityUIStrings.arcNotApplicableTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(IdentityUIStrings.arcNotApplicableNote)
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(palette.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
        .transition(.opacity)
    }

    // MARK: - Questions

    private var questionList: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.visibleArcSlots, id: \.stableID) { slot in
                slotView(slot)
                    .id(slot.stableID)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            if !viewModel.draft.arcNotApplicable {
                AddSceneCard(
                    title: L10n.ArcQuestionCopy.addQuestion,
                    caption: L10n.ArcQuestionCopy.addCaption,
                    isLocked: isAddLocked
                ) {
                    insertQuestion(after: viewModel.draft.arcOrder.last)
                }
            }
        }
    }

    @ViewBuilder
    private func slotView(_ slot: ArcSlot) -> some View {
        switch slot {
        case .template(let question):
            if viewModel.isArcQuestionDisabled(question) {
                DisabledBeatRow(
                    title: CharacterArcField(question).title,
                    caption: L10n.ArcQuestionCopy.disabledCaption
                ) {
                    withAnimation { viewModel.setArcQuestion(question, disabled: false) }
                }
            } else {
                stockField(question)
            }
        case .custom(let question):
            customField(id: question.id)
        }
    }

    private func stockField(_ question: ArcTemplateQuestion) -> some View {
        let field = CharacterArcField(question)
        let ref = ArcQuestionRef.template(question)
        return ExpandableTextField(
            title: field.title,
            prompt: field.prompt,
            systemImage: field.systemImage,
            focusRequest: $focusRequest,
            focusID: AnyHashable(ref.storageKey),
            menuItems: stockMenu(question),
            menuLabel: L10n.ArcQuestionCopy.options,
            text: $viewModel.draft[arcAnswer: question]
        )
    }

    private func customField(id: String) -> some View {
        let ref = ArcQuestionRef.custom(id)
        return CustomBeatField(
            title: $viewModel.draft[arcQuestionID: id].title,
            subtitle: $viewModel.draft[arcQuestionID: id].subtitle,
            text: $viewModel.draft[arcQuestionID: id].text,
            focusRequest: $focusRequest,
            focusID: AnyHashable(ref.storageKey),
            onInsertAfter: { insertQuestion(after: ref) },
            moveItems: moveItems(for: ref, locked: false),
            onDelete: {
                deleteTargetID = id
                showDeleteConfirm = true
            },
            copy: .arcQuestion
        )
    }

    private var notesField: some View {
        ExpandableTextField(
            title: CharacterArcField.notes.title,
            prompt: CharacterArcField.notes.prompt,
            systemImage: CharacterArcField.notes.systemImage,
            focusRequest: $focusRequest,
            focusID: AnyHashable(notesID),
            text: $viewModel.draft.notes
        )
        .id(notesID)
    }

    // MARK: - Menus

    private func stockMenu(_ question: ArcTemplateQuestion) -> [ExpandableTextField.MenuItem] {
        let ref = ArcQuestionRef.template(question)
        let insert = ExpandableTextField.MenuItem(
            title: L10n.ArcQuestionCopy.insertAfter,
            systemImage: isAddLocked ? "lock.fill" : "plus.square.on.square"
        ) { insertQuestion(after: ref) }
        let disable = ExpandableTextField.MenuItem(
            title: L10n.ArcQuestionCopy.disable,
            systemImage: "eye.slash"
        ) {
            withAnimation { viewModel.setArcQuestion(question, disabled: true) }
        }
        let moves = moveItems(for: ref, locked: !gate.canMoveStockArcQuestions)
        return [insert] + moves + [disable]
    }

    private func moveItems(for ref: ArcQuestionRef, locked: Bool) -> [ExpandableTextField.MenuItem] {
        let steps: [(offset: Int, title: String)] = [
            (-1, L10n.ArcQuestionCopy.moveUp),
            (1, L10n.ArcQuestionCopy.moveDown)
        ]
        return steps
            .filter { viewModel.canMoveArcQuestion(ref, by: $0.offset) }
            .map { step in
                let icon = step.offset < 0 ? "arrow.up" : "arrow.down"
                return ExpandableTextField.MenuItem(
                    title: step.title,
                    systemImage: locked ? "lock.fill" : icon
                ) {
                    guard !locked else { return gate.onBlocked() }
                    withAnimation(.snappy) { viewModel.moveArcQuestion(ref, by: step.offset) }
                    Haptics.selection()
                }
            }
    }

    // MARK: - Actions

    private var isAddLocked: Bool {
        !gate.canAddArcQuestion(existingCount: viewModel.customArcQuestionCount)
    }

    private func insertQuestion(after ref: ArcQuestionRef?) {
        guard !isAddLocked else {
            gate.onBlocked()
            return
        }
        let question = withAnimation(.snappy) { viewModel.insertArcQuestion(after: ref) }
        focusRequest = AnyHashable(ArcQuestionRef.custom(question.id).storageKey)
    }

    private func confirmDelete() {
        guard let id = deleteTargetID else { return }
        withAnimation { viewModel.deleteArcQuestion(id: id) }
        deleteTargetID = nil
    }
}
