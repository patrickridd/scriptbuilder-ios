import SwiftUI

/// Environment plumbing for the shared `AppPalette`. Read tokens in any
/// component via `@Environment(\.appPalette)`. Inject a custom palette at the
/// composition root (or any subtree) with `.appPalette(_:)`.
private struct AppPaletteKey: EnvironmentKey {
    static let defaultValue: AppPalette = .default
}

public extension EnvironmentValues {
    var appPalette: AppPalette {
        get { self[AppPaletteKey.self] }
        set { self[AppPaletteKey.self] = newValue }
    }
}

public extension View {
    /// Injects a shared `AppPalette` into this view's environment.
    func appPalette(_ palette: AppPalette) -> some View {
        environment(\.appPalette, palette)
    }
}
