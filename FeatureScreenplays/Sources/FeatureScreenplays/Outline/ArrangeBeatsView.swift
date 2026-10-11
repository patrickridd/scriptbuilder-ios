import SwiftUI
import Domain
import DesignSystem

/// The whole outline as one draggable list: act headers, their beats, and a
/// "Drop a beat here" row for empty acts. Dragging a beat under another act's
/// header moves it there. Custom beats always move; template beats move with
/// Pro (locked rows open the paywall). Changes save as they happen, and
/// "Reset to Standard Order" is always free.
struct ArrangeBeatsView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: OutlineViewModel
    let gate: EditorGate
    @ObservedObject private var entitlementSignal: EditorEntitlementSignal
    @State private var isConfirmingReset = false

    init(viewModel: OutlineViewModel, gate: EditorGate) {
        self.viewModel = viewModel
        self.gate = gate
        _entitlementSignal = ObservedObject(wrappedValue: gate.entitlementSignal)
    }

    private var canMoveTemplates: Bool {
        _ = entitlementSignal.revision
        return gate.canMoveTemplateBeats()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                list
            }
            .navigationTitle(L10n.ArrangeCopy.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { doneItem }
            .safeAreaInset(edge: .bottom) { resetBar }
            .confirmDialog(
                isPresented: $isConfirmingReset,
                icon: "arrow.uturn.backward.circle.fill",
                title: L10n.ArrangeCopy.resetConfirmTitle,
                message: L10n.ArrangeCopy.resetConfirmMessage,
                confirmTitle: L10n.ArrangeCopy.resetConfirmButton,
                cancelTitle: L10n.Action.cancel,
                isDestructive: false,
                coversNavigationBar: true
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    viewModel.resetBeatOrder()
                }
            }
        }
    }

    private var doneItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(L10n.ArrangeCopy.done) { dismiss() }
                .fontWeight(.semibold)
                .tint(palette.accent)
        }
    }

    // MARK: - List

    private var list: some View {
        List {
            introRow
            ForEach(viewModel.arrangeRows) { row in
                rowView(row)
            }
            .onMove { source, destination in
                viewModel.moveArrangeRows(from: source, to: destination)
                Haptics.selection()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(.active))
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.arrangeRows.map(\.id))
    }

    private var introRow: some View {
        Text(canMoveTemplates ? L10n.ArrangeCopy.intro : L10n.ArrangeCopy.proIntro)
            .font(.footnote)
            .foregroundStyle(palette.textMuted)
            .fixedSize(horizontal: false, vertical: true)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .moveDisabled(true)
    }

    @ViewBuilder
    private func rowView(_ row: ArrangeRow) -> some View {
        switch row.kind {
        case .header(_, let title):
            headerRow(title)
        case .beat(let beat, let sectionID):
            beatRow(beat, sectionID: sectionID)
        case .placeholder:
            placeholderRow
        }
    }

    private func headerRow(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .tracking(1.2)
            .foregroundStyle(palette.accent)
            .padding(.top, 12)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .moveDisabled(true)
    }

    private func beatRow(_ beat: OutlineBeat, sectionID: String) -> some View {
        let isLocked = !beat.isCustom && !canMoveTemplates
        return ArrangeBeatRow(
            beat: beat,
            hint: homeHint(for: beat, shownIn: sectionID),
            isLocked: isLocked
        )
        .contentShape(Rectangle())
        .onTapGesture { if isLocked { gate.onBlocked() } }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 8))
        .moveDisabled(isLocked)
    }

    /// "Usually in Act I" — only when the beat sits outside its home act.
    private func homeHint(for beat: OutlineBeat, shownIn sectionID: String) -> String? {
        guard let home = beat.homeSectionID, home != sectionID,
              let title = viewModel.sectionTitle(forID: home) else { return nil }
        return L10n.ArrangeCopy.usuallyIn(title)
    }

    private var placeholderRow: some View {
        VStack(spacing: 3) {
            Text(L10n.ArrangeCopy.dropHere)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.accent)
            Text(L10n.ArrangeCopy.dropHereCaption)
                .font(.caption)
                .foregroundStyle(palette.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.accent.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(palette.accent.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, dash: [7, 5]))
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .moveDisabled(true)
    }

    // MARK: - Reset

    /// Docked tray, deliberately unlike the white beat cards: an accent-tinted
    /// glass panel with a hairline + upward shadow, holding an outlined capsule.
    private var resetBar: some View {
        resetButton
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .background { resetTray }
    }

    private var resetButton: some View {
        let isStandard = viewModel.isUsingStandardOrder
        let tint = isStandard ? palette.textMuted : palette.accent
        return Button {
            isConfirmingReset = true
        } label: {
            Label(L10n.ArrangeCopy.reset, systemImage: "arrow.uturn.backward")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Capsule().fill(tint.opacity(isStandard ? 0.08 : 0.14)))
                .overlay(Capsule().strokeBorder(tint.opacity(isStandard ? 0.25 : 0.55), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .disabled(isStandard)
    }

    private var resetTray: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(.ultraThinMaterial)
            LinearGradient(
                colors: [palette.accent.opacity(0.16), palette.accent.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            Rectangle()
                .fill(palette.accent.opacity(0.3))
                .frame(height: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
        .ignoresSafeArea(edges: .bottom)
    }
}

/// One beat on the Arrange screen: kind glyph, title, an optional
/// "Usually in…" / disabled caption, and a lock when moving needs Pro.
private struct ArrangeBeatRow: View {
    @Environment(\.appPalette) private var palette
    let beat: OutlineBeat
    let hint: String?
    let isLocked: Bool

    private var displayTitle: String {
        let trimmed = beat.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.CustomBeatCopy.untitled : trimmed
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: beat.isCustom ? "sparkle" : "circle.grid.cross")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.accent)
                .frame(width: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(displayTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                captionLine
            }
            Spacer(minLength: 4)
            statusGlyph
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(beat.isCustom ? palette.accent.opacity(0.35) : palette.cardStroke, lineWidth: 1)
        )
        .opacity(beat.isDisabled ? 0.55 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityHint(isLocked ? L10n.ArrangeCopy.lockedHint : "")
    }

    @ViewBuilder private var captionLine: some View {
        let parts = [hint, beat.isDisabled ? L10n.ArrangeCopy.disabledTag : nil].compactMap { $0 }
        if !parts.isEmpty {
            Text(parts.joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(hint != nil ? palette.accent : palette.textMuted)
        }
    }

    @ViewBuilder private var statusGlyph: some View {
        if isLocked {
            Image(systemName: "lock.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .accessibilityHidden(true)
        }
    }
}
