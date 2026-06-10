import SwiftUI
import FeatureAuth

/// Dev/demo host for the FeatureAuth package. The shippable app
/// (ScriptBuilder) lives in its own project and injects this package as a
/// feature module; this shell just lets us run & preview it in isolation.
@main
struct FeatureAuthDemoApp: App {
    var body: some Scene {
        WindowGroup {
            let authConfiguration = AuthConfiguration(
                appName: "Script Builder",
                loginSubtitle: "From your screen to the silver screen",
                signUpSubtitle: "Create your account to start writing",
                loginFooterPrompt: "New to Script Builder?"
            )
            // Dev host injects the built-in MockAuthService. In ScriptBuilder
            // you'd inject a real FirebaseAuthService from the Auth package.
            AuthFlowView(
                config: authConfiguration,
                service: MockAuthService()
            ) { user in
                NSLog("FeatureAuth: authenticated as \(user.email ?? user.displayName ?? user.id)")
            }
        }
    }
}
