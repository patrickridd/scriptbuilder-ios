import SwiftUI
import DesignSystem

/// A tappable navigation entry point rendered as a single-row card, used on
/// `ProfileView` to push into a dedicated detail screen (e.g. Account Details).
///
/// Wrap it in a `NavigationLink(value:)` so the parent's `NavigationStack`
/// handles the push; this view just supplies the icon + label + subtitle +
/// chevron chrome consistent with the other profile cards.
struct SettingsRow: View {
    @Environment(\.appPalette) private var palette
    let icon: String
    let title: String
    let subtitle: String?

    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        ProfileCard {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.brandPrimary)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(palette.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(palette.textMuted)
                    }
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
    }
}
