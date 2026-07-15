//
//  PaywallPlanCard.swift
//  FeaturePaywall
//

import SwiftUI
import DesignSystem

struct PaywallPlanCard: View {
    let product: PaywallProduct
    let isSelected: Bool
    let badgeText: String?
    let onTap: () -> Void
    @Environment(\.appPalette) private var appPalette

    private var palette: PaywallPalette { PaywallPalette(appPalette) }

    var body: some View {
        Button(action: onTap) {
            content
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        HStack(spacing: 14) {
            selectionIndicator
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            priceColumn
        }
        .padding(16)
        .background(palette.cardFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(cardStroke)
        .overlay(alignment: .topTrailing) { badge }
    }

    private var title: String {
        switch product.plan {
        case .yearly: return "Yearly"
        case .monthly: return "Monthly"
        }
    }

    private var detail: String? {
        switch product.plan {
        case .yearly:
            if product.hasEligibleFreeTrial, let trial = product.trialDescription {
                return "\(trial), then \(product.displayPrice)/year"
            }
            return "Billed \(product.displayPrice) per year"
        case .monthly:
            return "Billed monthly"
        }
    }

    private var priceColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(product.displayPrice)
                .font(.title3.weight(.bold))
            Text(product.plan == .yearly ? "/year" : "/month")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var selectionIndicator: some View {
        Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
            .font(.system(size: 22))
            .foregroundStyle(isSelected ? palette.accent : Color(uiColor: .tertiaryLabel))
    }

    private var cardStroke: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(
                isSelected ? palette.selectedCardStroke : palette.unselectedCardStroke,
                lineWidth: isSelected ? 2 : 1
            )
    }

    @ViewBuilder
    private var badge: some View {
        if let badgeText {
            Text(badgeText)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(palette.badgeGradient, in: Capsule())
                .offset(x: -12, y: -10)
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        PaywallPlanCard(
            product: .init(id: "y", plan: .yearly, displayPrice: "$39.99", price: 39.99, hasEligibleFreeTrial: true, trialDescription: "7-day free trial"),
            isSelected: true,
            badgeText: "★ BEST VALUE · Save 44%",
            onTap: {}
        )
        PaywallPlanCard(
            product: .init(id: "m", plan: .monthly, displayPrice: "$5.99", price: 5.99),
            isSelected: false,
            badgeText: nil,
            onTap: {}
        )
    }
    .padding()
}
