# FeatureAuth

A sleek, accessible, drop-in authentication **feature module** for SwiftUI
apps. Premium login & sign-up screens with adaptive light/dark theming, large touch
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
https://github.com/patrickridd/FeatureAuth.git
```

Or add it to your own `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/patrickridd/FeatureAuth.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["FeatureAuth"]
    )
]
```

## Usage

The fastest way to get the full experience is `AuthFlowView` — it shows the
login screen and presents sign-up as a full-screen sheet:

```swift
import SwiftUI
import FeatureAuth

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
        loginFooterPrompt: "New here?",
        signUpFooterPrompt: "Already registered?"
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
import FeatureAuth

AuthAssets.bundle = .module   // or any Bundle you choose
```

## Wiring up a real backend

`FeatureAuth` is **backend-agnostic**. The UI depends only on the
`AuthService` protocol — it never imports Firebase or any SDK. You inject a
concrete implementation at your app's composition root, so you can swap
providers (Firebase today, Supabase tomorrow) without touching the UI.

### 1. Implement `AuthService` in a separate package

```swift
import FeatureAuth
import FirebaseAuth

public final class FirebaseAuthService: AuthService {
    public init() {}

    public func signIn(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(id: result.user.uid, email: result.user.email)
    }

    public func signUp(firstName: String, lastName: String,
                       email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUser(id: result.user.uid, email: result.user.email,
                        displayName: "\(firstName) \(lastName)")
    }

    public func signIn(with provider: SocialAuthProvider) async throws -> AuthUser {
        throw AuthServiceError.notImplemented(provider.rawValue)
    }

    public func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
```

### 2. Inject it at the composition root (your app)

```swift
import FeatureAuth
import Auth // your Firebase-backed package

AuthFlowView(
    config: AuthConfiguration(appName: "Script Builder"),
    service: FirebaseAuthService()
) { user in
    session.signedIn(as: user) // route into your app
}
```

With no `service:` argument, `FeatureAuth` falls back to a built-in
`MockAuthService` — perfect for the dev host and SwiftUI previews (no
Firebase, no network, no config).

## Components

If you want to compose your own screens, every building block is public:

- `AuthTextField` — glassy, accessible labeled field
- `AuthPrimaryButton` — gradient CTA with loading state
- `SocialAuthButton` / `SocialIconButton` — Apple / Google / Facebook
- `LabeledDivider` — "or continue with" separator
- `AuthBrandHeader` — logo + title + subtitle
- `AuthTheme` — the full design-token palette

## License

FeatureAuth is available under the MIT license. See [LICENSE](LICENSE).
