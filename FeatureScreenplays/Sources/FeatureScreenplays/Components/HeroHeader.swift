import SwiftUI
import DesignSystem

/// The dashboard hero: a warm welcome plus key stats at a glance, over the
/// signature brand gradient.
struct HeroHeader: View {
    @Environment(\.appPalette) private var palette
    let name: String
    let scriptCount: Int
    let sceneCount: Int
    let lastEdited: String
    var onOpenProfile: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            welcome
            stats
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: palette.brandPrimary.opacity(0.25), radius: 16, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture { onOpenProfile() }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Opens your profile")
    }

    private var welcome: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Home.welcomeBack)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(name)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 8)
            avatar
        }
    }

    private var avatar: some View {
        Text(initials)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(.white.opacity(0.18))
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1))
            .accessibilityHidden(true)
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init).joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    private var stats: some View {
        HStack(spacing: 8) {
            StatPill(value: "\(scriptCount)", label: "Scripts")
            divider
            StatPill(value: "\(sceneCount)", label: "Scenes")
            divider
            StatPill(value: lastEdited, label: "Last edit")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.25))
            .frame(width: 1, height: 30)
    }
}
