# AuthDomain

A tiny, dependency-free Swift package that defines the **authentication contract**
shared across an app. It contains no UI and no SDKs — just the protocol, the
models, and a zero-config mock so any layer can build and preview against auth
without pulling in Firebase, Supabase, or a network.

`AuthDomain` is the seam between your auth **UI** (e.g. the `FeatureAuth`
package) and your auth **backend** (e.g. a `FirebaseAuthData` package). The UI
depends only on this abstraction; the app's composition root injects a concrete
implementation at launch. The result: a UI that stays pure, testable, and
provider-agnostic.

## Requirements

- iOS 17+
- Swift 5.9+

## Installation

Add the package via Swift Package Manager:

```swift
.package(url: "https://github.com/your-org/AuthDomain.git", from: "1.0.0")
```

Then add `"AuthDomain"` to your target's dependencies.

## What's inside

| Type | Role |
| --- | --- |
| `AuthService` | The protocol the UI depends on (sign-in, sign-up, social, password reset). |
| `AuthUser` | A lightweight, backend-agnostic user model returned by the service. |
| `SocialAuthProvider` | The social identity providers a consumer can request (`apple`, `google`, `facebook`). |
| `AuthServiceError` | Friendly, localized errors a service can surface to consumers. |
| `MockAuthService` | A no-backend implementation for dev hosts and SwiftUI previews. |

## The contract

```swift
public protocol AuthService: Sendable {
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(firstName: String, lastName: String,
                email: String, password: String) async throws -> AuthUser
    func signIn(with provider: SocialAuthProvider) async throws -> AuthUser
    func sendPasswordReset(email: String) async throws
}
```

## Implementing a backend

Put concrete services in a **separate** package that imports your SDK — never
in the UI layer. That package depends on `AuthDomain` and maps the SDK's richer
user object down to `AuthUser`.

```swift
// In a separate "FirebaseAuthData" package that imports FirebaseAuth:
import AuthDomain
import FirebaseAuth

public final class FirebaseAuthService: AuthService {
    public init() {}

    public func signIn(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(id: result.user.uid, email: result.user.email)
    }
    // ...implement the rest
}
```

Throw `AuthServiceError.notImplemented(_:)` for any provider you don't support,
and `AuthServiceError.message(_:)` to surface a friendly message to the user.

## Previewing with no backend

`MockAuthService` simulates latency and always succeeds, so you can build and
preview the entire auth experience with **no Firebase, no network, no config**.

```swift
import AuthDomain

let service: AuthService = MockAuthService()        // 0.8s simulated latency
let fast:    AuthService = MockAuthService(delay: 0) // instant, for tests
```

## Composition root

The app wires the UI to the chosen backend in one place:

```swift
// Production
AuthFlowView(config: .init(appName: "Your App"),
             service: FirebaseAuthService())

// Dev host / previews
AuthFlowView(config: .init(appName: "Your App"),
             service: MockAuthService())
```

## License

[MIT](LICENSE)
