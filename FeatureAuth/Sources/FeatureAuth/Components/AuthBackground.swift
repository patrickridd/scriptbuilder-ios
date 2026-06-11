import SwiftUI

/// The standard FeatureAuth screen backdrop: the brand gradient with a few
/// soft, slowly drifting glow "blobs" layered on top for an ambient, living feel.
///
/// The motion is intentionally slow and blurred so it reads as a gentle wash
/// rather than distracting movement while people are reading or typing.
///
/// Respects the system **Reduce Motion** setting — when enabled it falls back
/// to the original static gradient + glow so the experience stays calm and
/// accessible.
///
/// Drop it in place of the old `backgroundGradient` + `accentGlow` pair:
/// ```swift
/// ZStack {
///     AuthBackground()
///     content
/// }
/// ```
public struct AuthBackground: View {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    public init() {}

    public var body: some View {
        ZStack {
            AuthTheme.backgroundGradient
                .ignoresSafeArea()

            if reduceMotion {
                AuthTheme.accentGlow
                    .ignoresSafeArea()
            } else {
                blobs
                    .ignoresSafeArea()
                    .onAppear { animate = true }
            }
        }
    }

    // MARK: - Drifting blobs

    private var blobs: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                blob(color: AuthTheme.blobTeal,
                     diameter: size.width * 0.95,
                     base: CGPoint(x: size.width * 0.18, y: size.height * 0.18),
                     drift: CGSize(width: 38, height: 30),
                     duration: 11,
                     delay: 0)

                blob(color: AuthTheme.blobBlue,
                     diameter: size.width * 1.05,
                     base: CGPoint(x: size.width * 0.85, y: size.height * 0.30),
                     drift: CGSize(width: -42, height: 34),
                     duration: 14,
                     delay: 1.5)

                blob(color: AuthTheme.blobDeep,
                     diameter: size.width * 1.1,
                     base: CGPoint(x: size.width * 0.55, y: size.height * 0.88),
                     drift: CGSize(width: 30, height: -36),
                     duration: 17,
                     delay: 0.8)
            }
            .blur(radius: 60)
        }
    }

    private func blob(color: Color,
                      diameter: CGFloat,
                      base: CGPoint,
                      drift: CGSize,
                      duration: Double,
                      delay: Double) -> some View {
        let offset: CGSize = animate ? drift : .zero
        let scale: CGFloat = animate ? 1.08 : 0.92
        return Circle()
            .fill(color)
            .frame(width: diameter, height: diameter)
            .position(base)
            .offset(offset)
            .scaleEffect(scale)
            .animation(
                .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: animate
            )
    }
}

#Preview("AuthBackground") {
    AuthBackground()
}
