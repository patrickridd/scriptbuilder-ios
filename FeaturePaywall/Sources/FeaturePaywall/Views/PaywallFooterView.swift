//
//  PaywallFooterView.swift
//  FeaturePaywall
//

import SwiftUI
import DesignSystem

struct PaywallFooterView: View {
    let configuration: PaywallConfiguration
    let isBusy: Bool
    let onRestore: () -> Void
    @Environment(\.appPalette) private var appPalette

    private var palette: PaywallPalette { PaywallPalette(appPalette) }

    var body: some View {
        VStack(spacing: 10) {
            Button("Restore Purchases", action: onRestore)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.accent)
                .disabled(isBusy)

            HStack(spacing: 6) {
                if let terms = configuration.termsURL {
                    Link("Terms", destination: terms)
                    Text("·").foregroundStyle(.secondary)
                }
                if let privacy = configuration.privacyURL {
                    Link("Privacy", destination: privacy)
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PaywallFooterView(
        configuration: .scriptBuilderPro(
            termsURL: URL(string: "https://example.com/terms"),
            privacyURL: URL(string: "https://example.com/privacy")
        ),
        isBusy: false,
        onRestore: {}
    )
    .padding()
}
