import SwiftUI

/// Decorative overlay that turns a plain cover tile into a brad-bound
/// screenplay page: a left spine with three brass brads, a couple of faint
/// "typed" text lines, and a dog-eared page-fold corner (top-right).
///
/// Purely visual and lightweight — meant to layer on top of `CoverArtwork`
/// or the dashed "New Script" tile so every card reads as a script page.
struct ScriptBinding: View {
    /// When true, draws faint horizontal "text" lines over the page.
    var showTextLines: Bool = true
    /// Tint for the brads / fold — defaults to a warm brass.
    var brassColor: Color = Color(red: 0.85, green: 0.69, blue: 0.36)

    var body: some View {
        ZStack {
            spine
            if showTextLines { textLines }
            pageFold
        }
    }

    // MARK: - Spine + brads

    private var spine: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(.black.opacity(0.07))
                    .frame(width: 18)
                brads
            }
            Spacer(minLength: 0)
        }
    }

    private var brads: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    Spacer()
                    Circle()
                        .fill(brassColor.opacity(0.7))
                        .frame(width: 5, height: 5)
                        .overlay(Circle().strokeBorder(.black.opacity(0.15), lineWidth: 0.5))
                        .shadow(color: .black.opacity(0.18), radius: 0.5, y: 0.5)
                    Spacer()
                }
            }
            .frame(width: 18, height: geo.size.height)
        }
        .frame(width: 18)
    }

    // MARK: - Faint typed lines

    private var textLines: some View {
        VStack(alignment: .leading, spacing: 7) {
            line(widthFactor: 0.42)
            line(widthFactor: 0.62)
            line(widthFactor: 0.30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.leading, 30)
        .padding([.trailing, .bottom], 14)
    }

    private func line(widthFactor: CGFloat) -> some View {
        GeometryReader { geo in
            Capsule()
                .fill(.white.opacity(0.22))
                .frame(width: geo.size.width * widthFactor, height: 3)
        }
        .frame(height: 3)
    }

    // MARK: - Page fold

    private var pageFold: some View {
        VStack {
            HStack {
                Spacer()
                PageFoldShape()
                    .fill(.white.opacity(0.28))
                    .frame(width: 22, height: 22)
                    .overlay(
                        PageFoldShape()
                            .stroke(.black.opacity(0.12), lineWidth: 0.5)
                    )
            }
            Spacer()
        }
    }
}

/// A small triangle that reads as a dog-eared page corner in the top-right.
private struct PageFoldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
