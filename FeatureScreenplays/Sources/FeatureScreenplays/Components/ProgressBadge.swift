import SwiftUI
import DesignSystem

/// A compact capsule showing "filled / total" progress for a section, flipping
/// to a checkmark "Complete" state once everything is filled in. Used on
/// navigation rows that lead into a longer form (e.g. Character Arc).
struct ProgressBadge: View {
    @Environment(\.appPalette) private var palette

    let filled: Int
    let total: Int
    var completeText: String?

    private var isComplete: Bool { total > 0 && filled >= total }

    var body: some View {
        HStack(spacing: 4) {
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption.weight(.semibold))
            }
            Text(labelText)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(isComplete ? palette.accent : palette.textMuted)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(
            Capsule(style: .continuous)
                .fill(palette.accent.opacity(isComplete ? 0.18 : 0.10))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(palette.accent.opacity(isComplete ? 0.35 : 0.18), lineWidth: 1)
        )
        .accessibilityLabel(labelText)
    }

    private var labelText: String {
        if isComplete, let completeText { return completeText }
        return "\(filled)/\(total)"
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ProgressBadge(filled: 3, total: 10)
        ProgressBadge(filled: 9, total: 9, completeText: "Complete")
    }
    .padding()
}
#endif
