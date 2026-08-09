import SwiftUI
import DesignSystem

/// The shared completion header used by the character, outline-section, and
/// scene editors: a bold title, a live "X of Y fields complete" subtitle, an
/// animated `ProgressRing`, and an optional "Next up: …" nudge that jumps the
/// writer to the first still-empty field.
struct ProgressHeader: View {
    @Environment(\.appPalette) private var palette

    let title: String
    /// Optional SF Symbol shown leading the title.
    var systemImage: String?
    /// When true the title is rendered as a soft prompt (muted, lighter weight)
    /// because the real value has not been entered yet.
    var titleIsPlaceholder: Bool = false
    /// Optional action fired when a placeholder title is tapped.
    var onTitleTapped: (() -> Void)?
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    private var summaryRow: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                titleRow
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(isComplete ? palette.accent : palette.textMuted)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: subtitle)
                        .padding(.leading, 2)
                    if !isComplete, let nextFieldTitle, let onNextTapped {
                        nudge(title: nextFieldTitle, action: onNextTapped)
                            .padding(.trailing)
                    }
                }
            }
            Spacer(minLength: 8)
            ProgressRing(targetFraction: fraction)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.Progress.accessibility(title, filled, total))
    }

    @ViewBuilder
    private var titleRow: some View {
        if titleIsPlaceholder, let onTitleTapped {
            Button {
                Haptics.selection()
                onTitleTapped()
            } label: {
                titleLabel
            }
            .buttonStyle(PressableScaleStyle())
        } else {
            titleLabel
        }
    }

    private var titleLabel: some View {
        HStack(alignment: .center, spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(titleIsPlaceholder ? palette.textMuted : palette.accent)
            }
            Text(title)
                .font(titleIsPlaceholder ? .title.weight(.semibold) : .title.weight(.bold))
                .foregroundStyle(titleIsPlaceholder ? palette.textMuted : palette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: titleIsPlaceholder)
    }

    private func nudge(title: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.caption2.weight(.semibold))
                Text(L10n.Progress.nextUp(title))
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                Image(systemName: "arrow.down.circle.fill")
                    .font(.caption2)
            }
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(palette.accent.opacity(0.12), in: Capsule())
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityHint(L10n.Progress.nextUpHint)
    }
}

// MARK: - Previews

#if DEBUG
private struct ProgressHeaderPreview: View {
    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 32) {
                    ProgressHeader(
                        title: "Scene Progress",
                        systemImage: "film",
                        filled: 2,
                        total: 6,
                        completeText: "Scene complete — nice work!",
                        nextFieldTitle: "Dialogue",
                        onNextTapped: {}
                    )
                    ProgressHeader(
                        title: "Act One",
                        systemImage: "list.bullet.rectangle",
                        filled: 5,
                        total: 6,
                        completeText: "Act complete!",
                        nextFieldTitle: "Inciting Incident",
                        onNextTapped: {}
                    )
                    ProgressHeader(
                        title: "Character",
                        systemImage: "person.fill",
                        filled: 8,
                        total: 8,
                        completeText: "Every detail filled in ✨"
                    )
                    ProgressHeader(
                        title: "No Icon, Just Starting",
                        filled: 0,
                        total: 6,
                        completeText: "Done!",
                        nextFieldTitle: "Scene Description",
                        onNextTapped: {}
                    )
                }
                .padding(20)
            }
        }
    }
}

#Preview("Progress Header — Light") { ProgressHeaderPreview() }
#Preview("Progress Header — Dark") { ProgressHeaderPreview().preferredColorScheme(.dark) }
#endif
