//
//  PaywallView.swift
//  FeaturePaywall
//
//  iOS 26, trial-forward subscription paywall. StoreKit-free: it talks
//  only to a `PaywallStore`, so the same UI works against StoreKit 2 today
//  or a RevenueCat adapter later.
//

import SwiftUI
import DesignSystem

public struct PaywallView: View {
    @StateObject private var viewModel: PaywallViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appPalette) private var appPalette

    private var palette: PaywallPalette { PaywallPalette(appPalette) }

    /// Called when the user completes a purchase or is already subscribed,
    /// so the host can dismiss its presenting controller.
    private let onFinished: () -> Void

    public init(
        configuration: PaywallConfiguration,
        store: any PaywallStore,
        onFinished: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: PaywallViewModel(configuration: configuration, store: store))
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            content
            closeButton
        }
        .task { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .onChange(of: alreadySubscribed) { _, subscribed in
            if subscribed {
                Haptics.success()
                onFinished()
            }
        }
    }

    private var alreadySubscribed: Bool {
        viewModel.phase == .alreadySubscribed
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                palette.accent.opacity(0.10),
                Color(uiColor: .systemBackground)
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .loading:
            ProgressView().controlSize(.large)
        case .error(let message) where viewModel.selectedProduct == nil:
            loadFailure(message)
        default:
            scrollingContent
        }
    }

    private func loadFailure(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try Again") { viewModel.retry() }
                .font(.headline)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(palette.brandGradient, in: Capsule())
                .foregroundStyle(.white)
        }
        .padding(40)
    }

    private var scrollingContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 26) {
                    PaywallHeaderView(configuration: viewModel.configuration)
                        .padding(.top, 36)
                    PaywallFeatureList(features: viewModel.configuration.features)
                    planCards
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            purchaseBar
        }
    }

    @ViewBuilder
    private var planCards: some View {
        VStack(spacing: 12) {
            if let yearly = viewModel.yearly {
                PaywallPlanCard(
                    product: yearly,
                    isSelected: viewModel.selectedPlan == .yearly,
                    badgeText: yearlyBadge,
                    onTap: { select(.yearly) }
                )
            }
            if let monthly = viewModel.monthly {
                PaywallPlanCard(
                    product: monthly,
                    isSelected: viewModel.selectedPlan == .monthly,
                    badgeText: nil,
                    onTap: { select(.monthly) }
                )
            }
        }
    }

    private var yearlyBadge: String {
        if let savings = viewModel.savingsBadgeText {
            return "★ BEST VALUE · \(savings)"
        }
        return "★ BEST VALUE"
    }

    private var purchaseBar: some View {
        VStack(spacing: 12) {
            if case let .error(message) = viewModel.phase {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            ctaButton
            if let subline = viewModel.ctaSubline {
                Text(subline)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            PaywallFooterView(
                configuration: viewModel.configuration,
                isBusy: viewModel.isBusy,
                onRestore: { Task { await viewModel.restore() } }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private var ctaButton: some View {
        Button(action: { Task { await purchase() } }) {
            ZStack {
                if viewModel.phase == .purchasing {
                    ProgressView().tint(.white)
                } else {
                    Text(viewModel.ctaTitle)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundStyle(.white)
            .background(palette.brandGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(viewModel.isBusy || viewModel.selectedProduct == nil)
    }

    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss(); onFinished() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .padding(.trailing, 16)
                .padding(.top, 12)
            }
            Spacer()
        }
    }

    private func select(_ plan: PaywallPlan) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        viewModel.select(plan)
    }

    private func purchase() async {
        let completed = await viewModel.purchaseSelected()
        if completed {
            Haptics.success()
            onFinished()
            dismiss()
        }
    }
}

#Preview("Trial-forward") {
    PaywallView(
        configuration: .scriptBuilderPro(
            termsURL: URL(string: "https://example.com/terms"),
            privacyURL: URL(string: "https://example.com/privacy")
        ),
        store: MockPaywallStore()
    )
}

#Preview("Trial ineligible") {
    PaywallView(
        configuration: .scriptBuilderPro(termsURL: nil, privacyURL: nil),
        store: MockPaywallStore(
            yearlyProduct: .init(id: "unlimited_yearly", plan: .yearly, displayPrice: "$39.99", price: 39.99)
        )
    )
}
