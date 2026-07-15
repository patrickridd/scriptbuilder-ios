//
//  PaywallHeaderView.swift
//  FeaturePaywall
//

import SwiftUI
import DesignSystem

struct PaywallHeaderView: View {
    let configuration: PaywallConfiguration
    @Environment(\.appPalette) private var appPalette

    private var palette: PaywallPalette { PaywallPalette(appPalette) }

    var body: some View {
        VStack(spacing: 14) {
            glyph
            Text(configuration.productName)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
            Text(configuration.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
    }

    private var glyph: some View {
        Image(systemName: configuration.glyphSymbolName)
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 88, height: 88)
            .background(palette.brandGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: palette.accent.opacity(0.35), radius: 16, y: 8)
    }
}

#Preview {
    PaywallHeaderView(
        configuration: .scriptBuilderPro(termsURL: nil, privacyURL: nil)
    )
    .padding()
}
