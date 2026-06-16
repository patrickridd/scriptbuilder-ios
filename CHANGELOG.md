# Changelog

All notable changes to AuthDomain are documented here. This project
adheres to [Semantic Versioning](https://semver.org/).

## [1.3.0] - 2026-06-16

### Added
- **`AuthService.deleteAccount()`** — new async-throwing protocol requirement
  for permanently deleting the currently signed-in account. A default
  protocol-extension throws `AuthServiceError.notImplemented` so existing
  conformers outside this repo compile without modification (backward-compatible
  minor bump).
- **`MockAuthService.deleteAccount()`** — simulates the async deletion with the
  configured delay and always succeeds. Useful in dev hosts and SwiftUI
  previews.

---

## [1.2.0] - 2026-06-14

### Changed
- `MockAuthService` default simulated latency increased from `0.8s` to `1.6s`,
  so loading states (such as the FeatureAuth shimmering auth overlay) read
  clearly in dev hosts and SwiftUI previews. The `delay:` initializer parameter
  is unchanged — pass your own value to override.

---

## [1.1.0] - 2026-06-14

### Added
- `signOut() throws` requirement on `AuthService`.
  - A safe protocol-extension default (`throw .notImplemented("Sign out")`)
    is provided so existing conformers outside this repository compile without
    modification (backward-compatible minor bump).
  - `MockAuthService` now overrides `signOut()` with a no-op (no backend
    session to clear in the mock).

---

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
