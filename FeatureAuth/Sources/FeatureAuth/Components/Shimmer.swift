import SwiftUI

/// A soft, periodic highlight sweep that travels diagonally across a view —
/// perfect as a premium accent on the brand badge or loading skeletons.
///
/// The sweep pauses between passes so it reads as an occasional gleam rather
/// than constant motion. Respects **Reduce Motion** (renders nothing extra
/// when enabled), so it stays calm and accessible.
public struct Shimmer: ViewModifier {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    /// Seconds for one sweep to cross the view.
    var duration: Double
    /// Seconds to wait between sweeps.
    var pause: Double
    /// Peak opacity of the highlight band.
    var intensity: Double

    public init(duration: Double = 3.2, pause: Double = 2.4, intensity: Double = 0.55) {
        self.duration = duration
        self.pause = pause
        self.intensity = intensity
    }

    public func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .overlay(sweep.mask(content))
                .onAppear(perform: start)
        }
    }

    private var sweep: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            LinearGradient(
                colors: [.clear,
                         Color.white.opacity(intensity),
                         .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: width * 0.6)
            .blur(radius: 6)
            .rotationEffect(.degrees(18))
            .offset(x: phase * width * 1.6)
        }
        .allowsHitTesting(false)
    }

    private func start() {
        // Reset, then loop with a pause baked into the keyframe.
        phase = -1
        withAnimation(
            .easeInOut(duration: duration)
                .repeatForever(autoreverses: false)
                .delay(pause)
        ) {
            phase = 1
        }
    }
}

public extension View {
    /// Adds a soft, periodic shimmer sweep across this view.
    func authShimmer(duration: Double = 3.2,
                     pause: Double = 2.4,
                     intensity: Double = 0.55) -> some View {
        modifier(Shimmer(duration: duration, pause: pause, intensity: intensity))
    }
}
