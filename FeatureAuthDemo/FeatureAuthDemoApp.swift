import SwiftUI
import FeatureAuth

/// Dev/demo host for the FeatureAuth package. The shippable app
/// (ScriptBuilder) lives in its own project and injects this package as a
/// feature module; this shell just lets us run & preview it in isolation.
@main
struct FeatureAuthDemoApp: App {
    var body: some Scene {
        WindowGroup {
            AuthFlowView()
        }
    }
}
