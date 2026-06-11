# Changelog

All notable changes to FeatureAuth are documented here. This project
adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
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

### Changed
- `blobTeal`, `blobBlue`, and `blobDeep` color tokens added to `AuthTheme`,
  tuned for both light and dark mode.

## [1.3.0] - 2026-06-10

### Added
- **Full localization** via a String Catalog (`Localizable.xcstrings`) shipped
  with the package. Every user-facing string — field labels, placeholders,
  buttons, links, dividers, accessibility labels, alerts, and validation
  messages — now resolves from the package bundle (`.module`).
- English (`en`) and Spanish (`es`) translations included out of the box.
- `defaultLocalization: "en"` declared in `Package.swift`.

### Changed
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
