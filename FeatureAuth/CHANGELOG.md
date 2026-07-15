# Changelog

All notable changes to FeatureAuth are documented here. This project
adheres to [Semantic Versioning](https://semver.org/).

## [3.2.1] - 2026-07-13

### Changed
- **Removed the `DesignSystem` dependency** so FeatureAuth is fully
  remotely-resolvable with no local `path:` dependencies. The loading overlay
  logic that previously came from `DesignSystem` is now a self-contained,
  internal `AuthLoadingCard` inside the package, using FeatureAuth's own
  shimmer and theme tokens. Its only remaining dependency is `AuthDomain`
  (already remote-versioned).

### Notes
- **No public API changes** — `AuthLoadingOverlay` keeps the same signature and
  behavior, and the frosted-glass look is unchanged. Existing consumers are
  unaffected and require no migration.

## [3.2.0] - 2026-07-13

### Added
- **Injectable brand logo** — `AuthConfiguration` now exposes a public
  `logo: Image?` property (with a matching `logo:` initializer parameter),
  and `AuthBrandHeader` accepts a `logo:` parameter. The composition root
  injects the host app's own artwork, keeping FeatureAuth fully reusable and
  brand-agnostic. When `nil`, a neutral SF Symbol placeholder is shown so
  previews still render. Fully backward compatible — existing call sites
  that omit `logo` are unaffected.
  
## [3.1.0] - 2026-06-14

### Added
- **Shimmering loading overlay** — while a login or sign-up request is in
  flight, both screens now present a glassy, dimmed veil with a centered card:
  the app badge plus shimmering skeleton bars and a localized status line
  ("Signing you in…" / "Creating your account…"). It reuses the existing
  on-brand shimmer sweep, animates in and out smoothly, respects **Reduce
  Motion**, and is announced politely to VoiceOver. Localized in English and
  Spanish. No API changes — it's driven by the existing `isLoading` state.

### Changed
- Bumped `AuthDomain` dependency to `from: "1.2.0"` to pick up the longer
  `MockAuthService` default delay, so the new loading overlay reads clearly in
  dev hosts and previews.

---

## [3.0.0] - 2026-06-14

### Added
- **Per-screen social provider lists** — `AuthConfiguration` now exposes
  `loginProviders: [SocialAuthProvider]` and `signUpProviders: [SocialAuthProvider]`,
  letting you configure the Login and Sign Up screens independently. The common
  use case: keep a provider on Login (so existing users can still sign in) while
  dropping it from Sign Up (to prevent new accounts with it). Both default to
  `[.apple, .google, .facebook]`, so the rendered UI is unchanged unless you
  customize them.

### Breaking
- **Removed `AuthConfiguration.showFacebookLogin`** in favor of the new
  `loginProviders` / `signUpProviders` arrays. To migrate:
  - `showFacebookLogin: true` (or omitted) → no change needed; the defaults
    already include all three providers.
  - `showFacebookLogin: false` → pass arrays without `.facebook`, e.g.
    `loginProviders: [.apple, .google], signUpProviders: [.apple, .google]`.

---

## [2.2.0] - 2026-06-14

### Changed
- Bumped `AuthDomain` dependency to `from: "1.1.0"` to pick up the new
  `signOut() throws` protocol requirement.

### Chore
- `Package.resolved` is now gitignored (library packages should not pin their
  transitive dependency graph).

---

## [2.1.0] - 2026-06-13

### Added
- **`AuthConfiguration.showFacebookLogin`** — a new flag (defaults to `true`)
  that gates the Facebook sign-in button on both the Login and Sign Up screens.
  Set it to `false` to begin phasing Facebook out without touching any other
  code. Fully backward compatible.

### Changed
- **Modernized state management** — `AuthViewModel` now uses the `@Observable`
  macro instead of `ObservableObject`/`@Published`, and the screens own it via
  `@State`. The public API is unchanged; existing call sites and bindings work
  as before. (Requires iOS 17+, which was already the package minimum.)
- **Migrated the test suite to Swift Testing** (`@Suite`/`@Test`/`#expect`) with
  a clear Given/When/Then structure for readability.

### Fixed
- **Cancelling a social sign-in no longer shows an error alert.** When a user
  backs out of Apple, Google, or Facebook sign-in, the flow now returns quietly
  to the auth screen instead of surfacing a "user cancelled" message. Genuine
  errors still surface as before.
- **Keyboard dismissal** — the email/password keyboard can now be dismissed by
  tapping anywhere outside a field or by swiping down (interactive drag),
  applied consistently across Login and Sign Up.

## [2.0.0] - 2026-06-11

### Breaking
- The brand color tokens were renamed to role-based, color-agnostic names so
  they read correctly for any brand palette. Update any direct references:
  - `AuthTheme.brandBlue` → `AuthTheme.brandPrimary`
  - `AuthTheme.brandTeal` → `AuthTheme.brandSecondary`
  - `AuthTheme.brandDeep` → `AuthTheme.brandTertiary`

### Added
- **Client theming via `AuthPalette`** — a public, injectable struct holding
  every color and layout token. Pass your own palette to `AuthFlowView`,
  `LoginView`, or `SignUpView` via the new `theme:` parameter to fully re-skin
  the experience without touching the kit's source. `AuthPalette.default`
  reproduces FeatureAuth's signature look, and a `with(...)` builder lets you
  override just a few tokens (e.g. `AuthPalette.default.with(brandPrimary: .purple)`).
  The active palette is also exposed through the SwiftUI environment
  (`\.authPalette`) for custom components.
- **`AuthBackground`** — an ambient, living backdrop for the auth screens.
  Three soft, blurred glow blobs (teal, blue, periwinkle) drift slowly on
  independent looping animations over the sky-to-periwinkle gradient, gently
  scaling for a calm, premium feel. Falls back to a static gradient + glow
  when **Reduce Motion** is enabled. Wired into `LoginView`, `SignUpView`,
  and the component preview.
- **`Shimmer`** view modifier + `authShimmer()` extension — a subtle diagonal
  gleam that sweeps slowly across a view. Tuned for a refined, luxury accent
  (3.2s sweep, 2.4s pause, low-intensity highlight) and applied to the brand
  badge in `AuthBrandHeader`. Respects **Reduce Motion**.
- **Full localization** via a String Catalog (`Localizable.xcstrings`) shipped
  with the package. Every user-facing string — field labels, placeholders,
  buttons, links, dividers, accessibility labels, alerts, and validation
  messages — now resolves from the package bundle (`.module`).
- English (`en`) and Spanish (`es`) translations included out of the box.
- `defaultLocalization: "en"` declared in `Package.swift`.

### Changed
- `blobTeal`, `blobBlue`, and `blobDeep` color tokens added to `AuthTheme`,
  tuned for both light and dark mode.
- `AuthTheme` is now a thin accessor over the currently active `AuthPalette`,
  so all existing `AuthTheme.x` token references reflect the injected theme.
- `AuthConfiguration` defaults are now localized. Its initializer parameters
  are optional (`nil` → localized fallback), so existing call sites that pass
  explicit copy are unaffected.

## [1.2.0] - 2026-06-10

### Added
- `AuthService` protocol — the UI now depends on this abstraction instead of
  hardcoded mock logic, so you can inject any backend (Firebase, Supabase,
  your own API) from the app's composition root without touching the UI.
- `AuthUser` — a lightweight, backend-agnostic user model returned by the service.
- `SocialAuthProvider` and `AuthServiceError` supporting types.
- `MockAuthService` — a no-backend implementation for the dev host and
  SwiftUI previews (zero configuration, simulated latency).
- `AuthFlowView`, `LoginView`, and `SignUpView` now accept a `service:` and an
  `onAuthenticated:` callback to route the signed-in user into your app.

### Changed
- `AuthViewModel` now performs real async auth calls through the injected
  `AuthService`, surfaces thrown errors as friendly messages, and exposes
  `currentUser`. Fully backward compatible — all new parameters default to
  `MockAuthService`, so existing call sites keep working unchanged.

## [1.1.0] - 2026-06-10

### Added
- `AuthConfiguration.signUpFooterPrompt` — the sign-up screen's
  "Already have an account?" line is now white-labelable, matching the
  existing `loginFooterPrompt` option. Fully backward compatible (defaults
  to the previous copy).

## [1.0.0] - 2026-06-10

### Added
- Initial public release.
- `AuthFlowView` — one-line drop-in for the full login + sign-up experience.
- `LoginView` and `SignUpView` public screens.
- `AuthConfiguration` for white-labeling app name and copy.
- Public component library: `AuthTextField`, `AuthPrimaryButton`,
  `SocialAuthButton`, `SocialIconButton`, `LabeledDivider`, `AuthBrandHeader`.
- `AuthTheme` adaptive design tokens with light/dark support.
- `AuthAssets.bundle` hook for configurable brand-image loading.
- `AuthViewModel` with input validation and placeholder auth actions.
- Unit tests for login/sign-up validation.
