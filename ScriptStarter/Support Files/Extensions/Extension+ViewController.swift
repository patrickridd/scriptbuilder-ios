//
//  Extension+ViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/8/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//
//  Trimmed down to the two members still used by the live SwiftUI flow after
//  the legacy UIKit view controllers were removed:
//   - `presentIAPSubscriptionView()` — the paywall entry point, presented on
//     the top-most SwiftUI hosting controller by `AppDelegate`.
//   - `present(error:)` — a simple alert helper.
//
import FeaturePaywall
import DesignSystem
import UIKit
import SwiftUI

extension UIViewController {

    // Presents the modernized SwiftUI paywall (FeaturePaywall package). The
    // purchase `store` is injected by the composition root (`AppDelegate`)
    // rather than reached for via a singleton.
    @MainActor
    func presentIAPSubscriptionView(store: any PaywallStore) {
        let configuration = PaywallConfiguration.scriptBuilderPro(
            termsURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
            privacyURL: URL(string: "https://www.scriptbuilderapp.com/_files/ugd/b622d0_f5722cd213394590bbd181559a0af540.pdf")
        )
        let paywall = PaywallView(
            configuration: configuration,
            store: store,
            onFinished: { [weak self] in
                self?.presentedViewController?.dismiss(animated: true)
            }
        )
        let hostingController = UIHostingController(
            rootView: paywall.appPalette(.default)
        )
        // Present full-screen on all idioms so the paywall fully covers the
        // shell (a page-sheet leaves the shell peeking behind and clips the
        // header). The in-view close button handles dismissal.
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
}
