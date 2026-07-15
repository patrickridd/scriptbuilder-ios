import SwiftUI
import DesignSystem

/// Hero header: gradient avatar monogram, name, provider badge, and an
/// at-a-glance screenplay-count stat.
struct ProfileHeaderCard: View {
    @Environment(\.appPalette) private var palette
    let config: ProfileConfiguration
    /// Live display name from the view model, falls back to the config snapshot.
    var liveName: String?

    private var name: String {
        let trimmed = liveName?.trimmingCharacters(in: .whitespaces) ?? ""
        return trimmed.isEmpty ? config.displayName : trimmed
    }

    private var initials: String {
        let parts = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
        let joined = parts.joined().uppercased()
        return joined.isEmpty ? "?" : joined
    }

    var body: some View {
        VStack(spacing: 14) {
            avatar
            Text(name)
                .font(.title2.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .multilineTextAlignment(.center)
            if let provider = config.providerLabel {
                Label(L10n.Header.provider(provider), systemImage: "checkmark.seal.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(palette.textMuted)
            }
            if let email = config.email {
                Text(email)
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
            }
            if let count = config.screenplayCount {
                statPill(count: count)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var avatar: some View {
        Text(initials)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 96, height: 96)
            .background(palette.heroGradient, in: Circle())
            .overlay(Circle().stroke(palette.cardStroke, lineWidth: 1))
            .shadow(color: palette.brandPrimary.opacity(0.35), radius: 16, y: 8)
    }

    private func statPill(count: Int) -> some View {
        return Label(L10n.Header.screenplayCount(count), systemImage: "film.stack")
            .font(.caption.weight(.semibold))
            .foregroundStyle(palette.brandPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(palette.brandPrimary.opacity(0.12), in: Capsule())
            .padding(.top, 4)
    }
}
