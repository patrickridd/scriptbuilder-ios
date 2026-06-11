# Changelog

All notable changes to AuthDomain are documented here. This project
adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-06-11

### Added
- Initial public release of the backend-agnostic authentication contract.
- `AuthService` protocol — the abstraction the auth UI depends on, covering
  email/password sign-in, registration, social sign-in, and password reset.
- `AuthUser` — a lightweight, UI-facing user model that concrete services map
  their richer user objects down to.
- `SocialAuthProvider` — the social identity providers a consumer can request
  (`apple`, `google`, `facebook`).
- `AuthServiceError` — friendly, localized errors (`notImplemented`, `message`)
  a service can surface to consumers.
- `MockAuthService` — a no-backend implementation for dev hosts and SwiftUI
  previews, with configurable simulated latency and zero configuration.
- Unit tests covering the mock service and model behavior.
