import SwiftUI

/// Configuration for where FeatureAuthKit loads its brand images from.
///
/// The kit references three named images:
/// - `AppLogo`     — the product logo shown in the header
/// - `FacebookLogo`
/// - `GoogleLogo`
///
/// By default these are loaded from the host app's main bundle
/// (`Bundle.main`), so apps that already ship these assets work with no
/// extra setup. To package the artwork inside your own module instead,
/// set `AuthAssets.bundle` once at launch:
///
/// ```swift
/// AuthAssets.bundle = .module
/// ```
public enum AuthAssets {
    /// Bundle used to resolve the kit's brand images. Defaults to `.main`.
    public static var bundle: Bundle = .main

    static func image(_ name: String) -> Image {
        Image(name, bundle: bundle)
    }
}
