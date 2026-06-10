# Changelog

All notable changes to FeatureAuth are documented here. This project
adheres to [Semantic Versioning](https://semver.org/).

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
