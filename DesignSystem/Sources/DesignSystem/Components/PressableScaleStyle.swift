import SwiftUI

/// A button style that gently scales and fades its content while pressed,
/// giving tappable elements a responsive, tactile feel.
///
/// Shared across the app target and all Feature modules so pressable cards,
/// tiles, and icons behave consistently. Tune `pressedScale` and
/// `pressedOpacity` for the density of the element (larger cards use a
/// subtler scale; small icons can dip a little more).
public struct PressableScaleStyle: ButtonStyle {
    private let pressedScale: CGFloat
    private let pressedOpacity: Double

    /// - Parameters:
    ///   - pressedScale: Scale applied while pressed. Defaults to `0.96`,
    ///     a subtle dip suited to cards.
    ///   - pressedOpacity: Opacity applied while pressed. Defaults to `0.85`.
    public init(pressedScale: CGFloat = 0.96, pressedOpacity: Double = 0.85) {
        self.pressedScale = pressedScale
        self.pressedOpacity = pressedOpacity
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == PressableScaleStyle {
    /// A subtle press-scale style for tappable cards and tiles.
    static var pressableCard: PressableScaleStyle { PressableScaleStyle() }

    /// A slightly deeper press-scale style suited to small icons.
    static var pressableIcon: PressableScaleStyle {
        PressableScaleStyle(pressedScale: 0.86, pressedOpacity: 0.7)
    }
}
