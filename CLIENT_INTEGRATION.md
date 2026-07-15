# Client Integration Guide

How to wire the three packages — **`AuthDomain`** (contract), **`FeatureAuth`** (UI),
and **`FirebaseAuthData`** (Firebase-backed service) — into a real shippable app.

The dev harness (`FeatureAuth-Dev`) uses `MockAuthService` for previews and local
development. A production client injects `FirebaseAuthService` instead. Nothing else
about the composition changes.

---

## 1. Add the packages

### Via Xcode
**File ▸ Add Package Dependencies…** and add each URL:

| Package | URL |
|---------|-----|
| `AuthDomain` | `https://github.com/patrickridd/AuthDomain.git` |
| `FeatureAuth` | `https://github.com/patrickridd/FeatureAuth.git` |
| `FirebaseAuthData` | `https://github.com/patrickridd/FirebaseAuthData.git` |

`FirebaseAuthData` pulls in Firebase, Google Sign-In, and Facebook SDK automatically.
You do **not** need to add those SDKs separately — Xcode embeds all transitive
binary frameworks on your behalf.

### Via XcodeGen (`project.yml`)

```yaml
packages:
  AuthDomain:
    url: https://github.com/patrickridd/AuthDomain.git
    from: 1.0.0
  FeatureAuth:
    url: https://github.com/patrickridd/FeatureAuth.git
    from: 1.0.0
  FirebaseAuthData:
    url: https://github.com/patrickridd/FirebaseAuthData.git
    from: 1.0.0

targets:
  YourApp:
    dependencies:
      - package: AuthDomain
        product: AuthDomain
      - package: FeatureAuth
        product: FeatureAuth
      - package: FirebaseAuthData
        product: FirebaseAuthData
```

> **Version alignment:** `FeatureAuth` and `FirebaseAuthData` both depend on
> `AuthDomain` `1.x`. Keep all three on the same `AuthDomain` major to avoid
> SPM resolution conflicts.

### Via `Package.swift` (library/framework target)

```swift
dependencies: [
    .package(url: "https://github.com/patrickridd/AuthDomain.git", from: "1.0.0"),
    .package(url: "https://github.com/patrickridd/FeatureAuth.git", from: "1.0.0"),
    .package(url: "https://github.com/patrickridd/FirebaseAuthData.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "AuthDomain", package: "AuthDomain"),
            .product(name: "FeatureAuth", package: "FeatureAuth"),
            .product(name: "FirebaseAuthData", package: "FirebaseAuthData"),
        ]
    )
]
```

---

## 2. Firebase project setup

1. Create a project in the [Firebase Console](https://console.firebase.google.com).
2. **Add an iOS app** with your client bundle identifier.
3. Download **`GoogleService-Info.plist`** and drag it into your Xcode app target
   (ensure **"Add to target"** is checked so it ships in the bundle).
4. In **Authentication ▸ Sign-in method**, enable the providers you need:
   - **Email/Password** — always required as the baseline
   - **Apple** — recommended (see §4 below)
   - **Google** — see §5 below
   - **Facebook** — see §6 below (legacy support)

---

## 3. Composition root

Use `UIApplicationDelegateAdaptor` so the SDK lifecycle hooks run at the right
time. Call `FirebaseAuthService.configure()` and (if using Facebook)
`FirebaseAuthService.configureFacebook(...)` inside `AppDelegate`, then inject
`FirebaseAuthService()` into `AuthFlowView`.

```swift
import SwiftUI
import UIKit
import FeatureAuth
import FirebaseAuthData
import AuthDomain

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configures Firebase (+ Google Sign-In client ID) from GoogleService-Info.plist.
        FirebaseAuthService.configure()

        // Only needed if you support Facebook login (§6).
        FirebaseAuthService.configureFacebook(application: application, launchOptions: launchOptions)

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handles OAuth redirect URLs for Google and Facebook.
        FirebaseAuthService.handleOpenURL(url, options: options)
    }
}

// MARK: - App entry point

@main
struct YourApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            let config = AuthConfiguration(
                appName: "Your App",
                loginSubtitle: "Welcome back",
                signUpSubtitle: "Create your account to get started",
                loginFooterPrompt: "New here?"
            )

            AuthFlowView(
                config: config,
                service: FirebaseAuthService()
            ) { user in
                // Authenticated. Route into your main experience here.
                NSLog("Authenticated as \(user.email ?? user.id)")
            }
        }
    }
}
```

That's the whole integration. The UI layer (`FeatureAuth`) never imports Firebase —
it only knows the `AuthService` contract — so you can swap the backend at this one
injection point without touching any screens.

---

## 4. Sign in with Apple

### App setup
1. In the [Apple Developer Portal](https://developer.apple.com/account), enable
   the **Sign In with Apple** capability for your App ID.
2. In Xcode, add the entitlement: **Signing & Capabilities ▸ + ▸ Sign in with Apple**.
3. In Firebase Console: **Authentication ▸ Sign-in method ▸ Apple** — enable it and
   follow the service ID / key configuration steps.

### XcodeGen entitlement
```yaml
targets:
  YourApp:
    entitlements:
      path: YourApp/YourApp.entitlements
      properties:
        com.apple.developer.applesignin:
          - Default
```

> **Simulator note:** Sign in with Apple only works on a simulator after the app
> has completed at least one successful sign-in on a **real device** first. Use a
> bypass or test on device for the first run.

---

## 5. Google Sign-In

No extra `Info.plist` keys are required beyond `GoogleService-Info.plist`. The
`CLIENT_ID` and `REVERSED_CLIENT_ID` values in that file are all the SDK needs.

Add the reversed client ID URL scheme so the OAuth redirect lands back in your app:

```xml
<!-- Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Copy REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID-HERE</string>
    </array>
  </dict>
</array>
```

In XcodeGen `project.yml` under `info ▸ properties`:
```yaml
CFBundleURLTypes:
  - CFBundleTypeRole: Editor
    CFBundleURLSchemes:
      - com.googleusercontent.apps.YOUR-CLIENT-ID-HERE   # from GoogleService-Info.plist
```

---

## 6. Facebook Login (legacy — existing users only)

Facebook login is provided for **continuity with existing users only** and will be
phased out in a future release. For new apps, use Apple or Google instead.

### Meta App setup
1. Create (or use an existing) app in the
   [Meta for Developers](https://developers.facebook.com) dashboard.
2. Under **Use cases ▸ Authentication and account creation**, add
   **Facebook Login for Business**.
3. Under **App settings ▸ Basic**, note your **App ID**.
4. Under **App settings ▸ Advanced**, generate (or copy) your **Client token**.
5. Add your bundle identifier as an iOS platform entry under **App settings ▸ Basic**.

### Firebase setup
In Firebase Console: **Authentication ▸ Sign-in method ▸ Facebook** — enable it
and enter your App ID and App secret.

> **The App Secret is mandatory.** Facebook sign-in uses **Limited Login**
> (see below), and Firebase validates the returned OIDC token against the App
> Secret you enter here. If it's missing, even otherwise-valid sign-ins are
> rejected.

### Limited Login (what to expect)
As of **FirebaseAuthData 1.2.1**, Facebook sign-in uses **Limited Login**, not
classic OAuth. This is required by Apple's App Tracking Transparency: without
tracking consent, the classic flow no longer returns a usable access token.

What this means for you:
- During sign-in the user is taken to **`limited.facebook.com`** — this is
  **expected and correct**, not an error.
- No host-app code changes are required: keep calling
  `signIn(with: .facebook)`. The package generates a per-sign-in nonce,
  requests Limited Login, and exchanges the OIDC token for a Firebase
  credential internally.
- You do **not** need to call `ATTrackingManager` or show an ATT prompt just to
  make Facebook login work. (The `NSUserTrackingUsageDescription` key below is
  only needed if your app requests tracking for *other* reasons, e.g. ads.)

### `Info.plist` / XcodeGen keys
All four entries below are required. The Facebook SDK reads them at runtime.

```xml
<!-- Info.plist -->
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>

<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>

<key>FacebookDisplayName</key>
<string>$(PRODUCT_NAME)</string>

<!-- Prevent the SDK from auto-initialising at launch (avoids crash on bundle-ID validation) -->
<key>FacebookAutoInitEnabled</key>
<false/>
<key>FacebookAutoLogAppEventsEnabled</key>
<false/>
<key>FacebookAdvertiserIDCollectionEnabled</key>
<false/>

<!-- Required by iOS for ATT prompt -->
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to personalise ads for you.</string>

<!-- Required by the SDK to query the Facebook / Messenger apps -->
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
</array>

<!-- Facebook OAuth redirect URL scheme -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR_FACEBOOK_APP_ID</string>   <!-- e.g. fb388278151632697 -->
    </array>
  </dict>
</array>
```

In XcodeGen `project.yml` the equivalent `info ▸ properties` block:
```yaml
FacebookAppID: "YOUR_FACEBOOK_APP_ID"
FacebookClientToken: "YOUR_FACEBOOK_CLIENT_TOKEN"
FacebookDisplayName: $(PRODUCT_NAME)
FacebookAutoInitEnabled: false
FacebookAutoLogAppEventsEnabled: false
FacebookAdvertiserIDCollectionEnabled: false
NSUserTrackingUsageDescription: "This identifier will be used to personalise ads for you."
LSApplicationQueriesSchemes:
  - fbapi
  - fb-messenger-share-api
CFBundleURLTypes:
  - CFBundleTypeRole: Editor
    CFBundleURLSchemes:
      - fbYOUR_FACEBOOK_APP_ID
```

> **No extra SPM packages needed.** The Facebook SDK is a transitive dependency of
> `FirebaseAuthData`; Xcode embeds all the required binary frameworks automatically
> when you add `FirebaseAuthData` as a package dependency.

---

## 7. `AuthConfiguration` reference

All fields are optional — omit any to use the built-in defaults.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `appName` | `String` | `"App"` | Displayed as the hero title on login/sign-up screens |
| `loginSubtitle` | `String` | `"Sign in to continue"` | Sub-heading on the login screen |
| `signUpSubtitle` | `String` | `"Create your account"` | Sub-heading on the sign-up screen |
| `loginFooterPrompt` | `String` | `"Don't have an account?"` | Text before the "Sign up" link |
| `signUpFooterPrompt` | `String` | `"Already have an account?"` | Text before the "Log in" link |

---

## 8. General notes

- **`GoogleService-Info.plist` is safe to ship** — it contains only public
  identifiers, not secret keys. Never embed server-side API secrets in the app binary.
- **Simulator + Sign in with Apple:** First login must happen on a real device.
  Use a mock bypass in the simulator during development.
- **Facebook phase-out plan:** When you are ready to remove Facebook, disable the
  provider in Firebase Console and set `showFacebookLogin: false` on
  `AuthConfiguration` (available from `1.2.0`). Existing users can re-link via
  email/password or Apple before you ship the removal.
