import SwiftUI
import DesignSystem

/// The shared completion header used by the character, outline-section, and
/// scene editors: a bold title, a live "X of Y fields complete" subtitle, an
/// animated `ProgressRing`, and an optional "Next up: …" nudge that jumps the
/// writer to the first still-empty field.
struct ProgressHeader: View {
    @Environment(\.appPalette) private var palette

    let title: String
    let filled: Int
    let total: Int
    /// Copy shown when every counted field has content.
    let completeText: String
    /// Localized title of the first empty field, if any.
    var nextFieldTitle: String?
    var onNextTapped: (() -> Void)?

    private var isComplete: Bool { total > 0 && filled == total }

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(filled) / Double(total)
    }

    private var subtitle: String {
        isComplete ? completeText : L10n.Progress.fieldsComplete(filled, total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            summaryRow
            if !isComplete, let nextFieldTitle, let onNextTapped {
                nudge(title: nextFieldTitle, action: onNextTapped)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }

    private var summaryRow: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(palette.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(isComplete ? palette.accent : palette.textMuted)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: subtitle)
            }
            Spacer(minLength: 8)
            ProgressRing(targetFraction: fraction)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.Progress.accessibility(title, filled, total))
    }

    private func nudge(title: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.footnote.weight(.semibold))
                Text(L10n.Progress.nextUp(title))
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Image(systemName: "arrow.down.circle.fill")
                    .font(.subheadline)
            }
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(palette.accent.opacity(0.12), in: Capsule())
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityHint(L10n.Progress.nextUpHint)
    }
}
