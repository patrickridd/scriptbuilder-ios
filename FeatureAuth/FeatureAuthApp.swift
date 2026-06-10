import SwiftUI
import FeatureAuthKit

@main
struct FeatureAuthApp: App {
    var body: some Scene {
        WindowGroup {
            // The whole auth experience now lives in the FeatureAuthKit
            // Swift package. Brand artwork (AppLogo, GoogleLogo, FacebookLogo)
            // still ships in this app's asset catalog and is loaded from the
            // main bundle by default.
            AuthFlowView()
        }
    }
}
