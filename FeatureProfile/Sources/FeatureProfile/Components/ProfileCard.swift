import SwiftUI
import DesignSystem

/// A reusable rounded card surface used by every profile section. Centralises
/// the surface fill, stroke, and corner radius so all cards stay visually
/// consistent and each section file only describes its content.
struct ProfileCard<Content: View>: View {
    @Environment(\.appPalette) private var palette
    private let title: String?
    private let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
                    .padding(.horizontal, 4)
            }
            VStack(spacing: 0) { content }
                .background(surface)
                .overlay(stroke)
        }
    }

    private var surface: some View {
        RoundedRectangle(cornerRadius: palette.cornerRadius)
            .fill(palette.cardSurface)
    }

    private var stroke: some View {
        RoundedRectangle(cornerRadius: palette.cornerRadius)
            .stroke(palette.cardStroke, lineWidth: 1)
    }
}

/// A single labelled row used inside cards (icon + title + trailing value).
struct ProfileRow<Trailing: View>: View {
    @Environment(\.appPalette) private var palette
    let icon: String
    let title: String
    let tint: Color?
    let trailing: Trailing

    init(
        icon: String,
        title: String,
        tint: Color? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.tint = tint
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint ?? palette.brandPrimary)
                .frame(width: 28)
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(tint ?? palette.textPrimary)
            Spacer(minLength: 8)
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

extension View {
    /// Divider tinted to the palette separator, used between rows.
    @ViewBuilder
    func profileDivider(_ palette: AppPalette) -> some View {
        Divider().overlay(palette.separator).padding(.leading, 58)
    }
}
