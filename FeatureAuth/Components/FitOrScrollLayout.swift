import SwiftUI

/// Centers content on a single screen when it fits, and falls back to a
/// scroll view when the content is taller than the available space (e.g.
/// when the user enables larger accessibility text sizes).
struct FitOrScrollLayout<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                content
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

// MARK: - Previews

#Preview("FitOrScrollLayout — short content fits") {
    ZStack {
        AuthTheme.backgroundGradient.ignoresSafeArea()
        FitOrScrollLayout {
            VStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AuthTheme.fieldGlass)
                        .frame(height: 54)
                        .overlay(
                            Text("Row \(i + 1)")
                                .foregroundStyle(AuthTheme.textPrimary)
                        )
                }
            }
            .padding(24)
        }
    }
}

#Preview("FitOrScrollLayout — tall content scrolls") {
    ZStack {
        AuthTheme.backgroundGradient.ignoresSafeArea()
        FitOrScrollLayout {
            VStack(spacing: 16) {
                ForEach(0..<14, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AuthTheme.fieldGlass)
                        .frame(height: 54)
                        .overlay(
                            Text("Row \(i + 1)")
                                .foregroundStyle(AuthTheme.textPrimary)
                        )
                }
            }
            .padding(24)
        }
    }
}
