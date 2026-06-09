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
