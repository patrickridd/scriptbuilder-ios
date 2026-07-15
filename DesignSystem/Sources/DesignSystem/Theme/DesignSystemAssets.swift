import SwiftUI

/// Generic accessor for artwork bundled with the DesignSystem package.
///
/// App-specific brand artwork (e.g. the product logo) intentionally does *not*
/// live here — the host app owns its identity and injects it into feature
/// modules at the composition root. This type only vends genuinely shared,
/// non-brand design assets from the package's own resource bundle.
public enum DesignSystemAssets {

    /// Bundle that vends the shared artwork. Points at the package's own
    /// resource bundle.
    public static let bundle: Bundle = .module

    /// Loads a named image from the shared DesignSystem catalog.
    public static func image(_ name: String) -> Image {
        Image(name, bundle: bundle)
    }
}
