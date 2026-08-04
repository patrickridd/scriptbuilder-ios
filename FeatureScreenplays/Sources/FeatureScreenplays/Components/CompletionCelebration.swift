import SwiftUI
import DesignSystem

/// The little congratulatory banner that drops in when a character arc, outline
/// section, or scene reaches 100%. Pairs with `ProgressRing`'s bloom flourish.
struct CompletionToast: View {
    @Environment(\.appPalette) private var palette

    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3.weight(.semibold))
                .foregroundStyle(palette.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(palette.textPrimary)
                Text(L10n.Progress.celebrationSubtitle)
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(palette.accent.opacity(0.35), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
    }
}

/// Shows a `CompletionToast` once, on the incomplete → complete transition only,
/// so re-opening a finished screen stays quiet.
private struct CompletionCelebrationModifier: ViewModifier {
    let isComplete: Bool
    let title: String

    @State private var isShowing = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isShowing {
                    CompletionToast(title: title)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 4)
                }
            }
            .onChange(of: isComplete) { wasComplete, nowComplete in
                guard nowComplete, !wasComplete else { return }
                celebrate()
            }
    }

    private func celebrate() {
        Haptics.success()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            isShowing = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2.4))
            withAnimation(.easeOut(duration: 0.3)) { isShowing = false }
        }
    }
}

extension View {
    /// Celebrate the moment a form's counted fields all fill up.
    func completionCelebration(isComplete: Bool, title: String) -> some View {
        modifier(CompletionCelebrationModifier(isComplete: isComplete, title: title))
    }
}
