# Changelog

All notable changes to FeatureAuth are documented here. This project
adheres to [Semantic Versioning](https://semver.org/).

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
