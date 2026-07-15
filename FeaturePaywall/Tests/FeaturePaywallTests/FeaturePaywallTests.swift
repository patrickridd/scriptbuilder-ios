import Testing
@testable import FeaturePaywall

@Suite("FeaturePaywall")
@MainActor
struct FeaturePaywallTests {
    @Test("Savings badge computes 44%")
    func savingsBadgeComputes44Percent() {
        let store = MockPaywallStore()
        let vm = PaywallViewModel(
            configuration: .scriptBuilderPro(termsURL: nil, privacyURL: nil),
            store: store
        )
        // 12 × 5.99 = 71.88; (71.88 - 39.99) / 71.88 ≈ 44%
        #expect(vm.savingsBadgeText == "Save 44%")
    }

    @Test("Defaults to yearly when available")
    func defaultsToYearlyWhenAvailable() {
        let vm = PaywallViewModel(
            configuration: .scriptBuilderPro(termsURL: nil, privacyURL: nil),
            store: MockPaywallStore()
        )
        #expect(vm.selectedPlan == .yearly)
    }

    @Test("Falls back to monthly when yearly missing")
    func fallsBackToMonthlyWhenYearlyMissing() {
        let store = MockPaywallStore(yearlyProduct: nil)
        let vm = PaywallViewModel(
            configuration: .scriptBuilderPro(termsURL: nil, privacyURL: nil),
            store: store
        )
        #expect(vm.selectedPlan == .monthly)
    }
}
