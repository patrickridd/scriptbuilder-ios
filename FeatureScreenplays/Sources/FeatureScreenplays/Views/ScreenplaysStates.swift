import SwiftUI
import DesignSystem

/// Empty-state shown when the user has no screenplays yet.
struct EmptyStateView: View {
    @Environment(\.appPalette) private var palette
    let name: String
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "film.stack")
                .font(.system(size: 60))
                .foregroundStyle(palette.brandPrimary)
            Text(L10n.Home.greeting(name))
                .font(.title2.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
            Text(L10n.Home.emptyMessage)
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
                .multilineTextAlignment(.center)
            Button(action: onCreate) {
                Label(L10n.Home.newScreenplay, systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(palette.primaryButtonGradient, in: Capsule())
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Error-state shown when loading fails and there's nothing cached to show.
struct ErrorStateView: View {
    @Environment(\.appPalette) private var palette
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 46))
                .foregroundStyle(.orange)
            Text(L10n.Home.loadErrorTitle)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
            Text(message)
                .font(.footnote)
                .foregroundStyle(palette.textMuted)
                .multilineTextAlignment(.center)
            Button(L10n.Action.tryAgain, action: onRetry)
                .buttonStyle(.bordered)
                .tint(palette.brandPrimary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
