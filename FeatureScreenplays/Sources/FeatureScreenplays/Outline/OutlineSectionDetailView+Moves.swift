import SwiftUI
import Domain
import DesignSystem

/// "Move Up / Move Down / Move to Act…" for the beat "…" menus. Template
/// beats need Pro to move (the items stay visible with a lock and open the
/// paywall); custom beats always move.
extension OutlineSectionDetailView {

    func moveMenuItems(for reference: BeatReference) -> [ExpandableTextField.MenuItem] {
        let isLocked = !reference.isCustom && !gate.canMoveTemplateBeats()
        var items: [ExpandableTextField.MenuItem] = []
        if viewModel.canMove(reference, by: -1) {
            items.append(item(L10n.ArrangeCopy.moveUp, "arrow.up", locked: isLocked) {
                viewModel.move(reference, by: -1)
            })
        }
        if viewModel.canMove(reference, by: 1) {
            items.append(item(L10n.ArrangeCopy.moveDown, "arrow.down", locked: isLocked) {
                viewModel.move(reference, by: 1)
            })
        }
        for target in viewModel.moveTargets(from: section) {
            items.append(item(L10n.ArrangeCopy.moveTo(target.title), "arrow.right.square", locked: isLocked) {
                viewModel.move(reference, toSection: target.id)
            })
        }
        return items
    }

    private func item(
        _ title: String, _ systemImage: String, locked: Bool, action: @escaping () -> Void
    ) -> ExpandableTextField.MenuItem {
        ExpandableTextField.MenuItem(title: title, systemImage: locked ? "lock.fill" : systemImage) {
            guard !locked else {
                gate.onBlocked()
                return
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { action() }
            Haptics.selection()
        }
    }

    /// Opens the Arrange screen from the beats header.
    var arrangeHeaderButton: some View {
        Button {
            isArranging = true
        } label: {
            Label(L10n.ArrangeCopy.openButton, systemImage: "arrow.up.arrow.down")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(palette.accent.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    /// Shown in place of beats when this act has been emptied out.
    var emptyBeatsNote: some View {
        VStack(spacing: 4) {
            Text(L10n.ArrangeCopy.noBeatsYet)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
            Text(L10n.ArrangeCopy.noBeatsCaption)
                .font(.caption)
                .foregroundStyle(palette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
