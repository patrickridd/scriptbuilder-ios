import SwiftUI
import Domain
import DesignSystem

// MARK: - View model

extension CharacterDetailViewModel {

    /// The arc list in display order; empty when the arc is waived (only
    /// Notes remains on screen then).
    var visibleArcSlots: [ArcSlot] {
        draft.arcNotApplicable ? [] : draft.arcSlots
    }

    var customArcQuestionCount: Int { draft.arcQuestions.count }

    var isUsingStandardArcOrder: Bool { draft.isUsingStandardArcOrder }

    @discardableResult
    func insertArcQuestion(after ref: ArcQuestionRef?) -> ArcQuestion {
        draft.insertArcQuestion(after: ref)
    }

    func deleteArcQuestion(id: String) {
        draft.removeArcQuestion(id: id)
    }

    func isArcQuestionDisabled(_ question: ArcTemplateQuestion) -> Bool {
        draft.isArcQuestionDisabled(question)
    }

    func setArcQuestion(_ question: ArcTemplateQuestion, disabled: Bool) {
        draft.setArcQuestion(question, disabled: disabled)
    }

    func canMoveArcQuestion(_ ref: ArcQuestionRef, by offset: Int) -> Bool {
        draft.canMoveArcQuestion(ref, by: offset)
    }

    func moveArcQuestion(_ ref: ArcQuestionRef, by offset: Int) {
        draft.moveArcQuestion(ref, by: offset)
    }

    /// Drag-reorder from the Arrange sheet (offsets into `arcOrder`).
    func moveArcRows(from source: IndexSet, to destination: Int) {
        var order = draft.arcOrder
        order.move(fromOffsets: source, toOffset: destination)
        draft.applyArcOrder(order)
    }

    func resetArcOrder() {
        draft.resetArcOrder()
    }
}

// MARK: - Sheet

/// Drag-to-reorder list of a character's arc questions. Built-in questions
/// are locked for free users (tap the lock → paywall); custom questions
/// always move. Notes is shown pinned at the bottom and never moves.
struct ArrangeQuestionsView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CharacterDetailViewModel
    let gate: EditorGate
    @State private var showResetConfirm = false

    private var canMoveStock: Bool { gate.canMoveStockArcQuestions }

    var body: some View {
        NavigationStack {
            List {
                questionsSection
                notesSection
                resetSection
            }
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle(L10n.ArcQuestionCopy.arrange)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.ArcQuestionCopy.done) { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.accent)
                }
            }
        }
        .confirmDialog(
            isPresented: $showResetConfirm,
            icon: "arrow.counterclockwise",
            title: L10n.ArcQuestionCopy.resetTitle,
            message: L10n.ArcQuestionCopy.resetMessage,
            confirmTitle: L10n.ArcQuestionCopy.reset,
            cancelTitle: L10n.ArcQuestionCopy.cancel,
            isDestructive: false
        ) {
            withAnimation { viewModel.resetArcOrder() }
        }
    }

    private var questionsSection: some View {
        Section {
            ForEach(viewModel.draft.arcSlots, id: \.stableID) { slot in
                row(for: slot)
                    .moveDisabled(isLocked(slot))
                    .listRowBackground(palette.cardSurface)
            }
            .onMove { source, destination in
                viewModel.moveArcRows(from: source, to: destination)
            }
        } header: {
            Text(L10n.ArcQuestionCopy.arrangeHint)
                .textCase(nil)
        } footer: {
            if !canMoveStock {
                Label(L10n.ArcQuestionCopy.lockedHint, systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
            }
        }
    }

    private var notesSection: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: CharacterArcField.notes.systemImage)
                    .foregroundStyle(palette.textMuted)
                    .frame(width: 22)
                Text(CharacterArcField.notes.title)
                    .foregroundStyle(palette.textMuted)
                Spacer()
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
            }
            .moveDisabled(true)
            .listRowBackground(palette.cardSurface.opacity(0.6))
        }
    }

    private var resetSection: some View {
        Section {
            Button {
                showResetConfirm = true
            } label: {
                Label(L10n.ArcQuestionCopy.reset, systemImage: "arrow.counterclockwise")
                    .foregroundStyle(viewModel.isUsingStandardArcOrder ? palette.textMuted : palette.accent)
            }
            .disabled(viewModel.isUsingStandardArcOrder)
            .listRowBackground(palette.cardSurface)
        }
    }

    private func isLocked(_ slot: ArcSlot) -> Bool {
        slot.isStock && !canMoveStock
    }

    private func isDisabled(_ slot: ArcSlot) -> Bool {
        guard case .template(let question) = slot else { return false }
        return viewModel.isArcQuestionDisabled(question)
    }

    private func row(for slot: ArcSlot) -> some View {
        let muted = isDisabled(slot)
        return HStack(spacing: 12) {
            Image(systemName: slot.systemImage)
                .foregroundStyle(slot.isStock ? palette.textMuted : palette.accent)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(slot.displayTitle)
                    .foregroundStyle(muted ? palette.textMuted : palette.textPrimary)
                    .strikethrough(muted, color: palette.textMuted)
                    .lineLimit(2)
                if !slot.isStock {
                    Text(L10n.ArcQuestionCopy.yourQuestion)
                        .font(.caption2)
                        .foregroundStyle(palette.accent)
                }
            }
            Spacer(minLength: 8)
            if isLocked(slot) { lockButton }
        }
    }

    private var lockButton: some View {
        Button {
            dismiss()
            let blocked = gate.onBlocked
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { blocked() }
        } label: {
            Image(systemName: "lock.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.accent)
                .padding(6)
                .background(Circle().fill(palette.accent.opacity(0.12)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.ArcQuestionCopy.lockedHint)
    }
}
