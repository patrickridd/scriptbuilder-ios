//
//  PaywallFeatureList.swift
//  FeaturePaywall
//

import SwiftUI
import DesignSystem

struct PaywallFeatureList: View {
    let features: [PaywallFeature]
    @Environment(\.appPalette) private var appPalette

    private var palette: PaywallPalette { PaywallPalette(appPalette) }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(features) { feature in
                row(for: feature)
            }
        }
    }

    private func row(for feature: PaywallFeature) -> some View {
        HStack(spacing: 14) {
            Image(systemName: feature.symbolName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(palette.accent)
                .frame(width: 38, height: 38)
                .background(palette.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            Text(feature.title)
                .font(.callout.weight(.medium))
            Spacer(minLength: 0)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(palette.accent)
        }
    }
}

#Preview {
    PaywallFeatureList(
        features: PaywallConfiguration.scriptBuilderPro(termsURL: nil, privacyURL: nil).features
    )
    .padding()
}
