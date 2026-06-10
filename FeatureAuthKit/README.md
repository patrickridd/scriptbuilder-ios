# FeatureAuthKit

A sleek, accessible, drop-in authentication UI for SwiftUI apps. Premium
login & sign-up screens with adaptive light/dark theming, large touch
targets, high-contrast colors, and Dynamic Type support — designed to be
usable for people who are hard of seeing.

| Light | Dark |
|-------|------|
| Soft sky-to-periwinkle gradient, frosted white cards | Premium navy-to-teal gradient, glassy translucent fields |

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

In Xcode: **File ▸ Add Package Dependencies…** and paste the repo URL:

```
https://github.com/<your-org>/FeatureAuthKit.git
```

Or add it to your own `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<your-org>/FeatureAuthKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["FeatureAuthKit"]
    )
]
```

## Usage

The fastest way to get the full experience is `AuthFlowView` — it shows the
login screen and presents sign-up as a full-screen sheet:

```swift
import SwiftUI
import FeatureAuthKit

struct ContentView: View {
    var body: some View {
        AuthFlowView()
    }
}
```

### White-labeling

Customize the app name and copy without touching the kit's source:

```swift
AuthFlowView(
    config: AuthConfiguration(
        appName: "Your App",
        loginSubtitle: "Welcome back",
        signUpSubtitle: "Create your account",
        loginFooterPrompt: "New here?"
    )
)
```

You can also use the screens directly:

```swift
LoginView(config: .default)
SignUpView(config: .default)
```

## Brand images

The kit references three named images:

- `AppLogo` — the product logo shown in the header
- `GoogleLogo`
- `FacebookLogo`

By default these are loaded from your app's **main bundle**, so just add
them to your app's asset catalog and they'll appear automatically.

To load them from a different bundle (e.g. you ship them in your own
module), set this once at launch:

```swift
import FeatureAuthKit

AuthAssets.bundle = .module   // or any Bundle you choose
```

## Wiring up a real backend

`AuthViewModel` ships with placeholder logic and validation. Connect it to
your auth provider (Sign in with Apple, Supabase, Firebase, etc.) by
replacing the bodies of `login()`, `signUp()`, and the social methods.

## Components

If you want to compose your own screens, every building block is public:

- `AuthTextField` — glassy, accessible labeled field
- `AuthPrimaryButton` — gradient CTA with loading state
- `SocialAuthButton` / `SocialIconButton` — Apple / Google / Facebook
- `LabeledDivider` — "or continue with" separator
- `AuthBrandHeader` — logo + title + subtitle
- `AuthTheme` — the full design-token palette

## License

FeatureAuthKit is available under the MIT license. See [LICENSE](LICENSE).
