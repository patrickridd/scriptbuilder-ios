//
//  IAPSubscriptionView.swift
//  ScriptStarter
//
//  Created by patrick ridd on 7/1/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import SwiftUI
import StoreKit

struct IAPSubscriptionView: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    init(presentingViewController: UIViewController) {
        _viewModel = StateObject(wrappedValue: ViewModel(presentingViewController: presentingViewController))
        // Large Navigation Title
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.screenDark, NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 28) as Any, NSAttributedString.Key.strokeColor: UIColor.systemCyan, NSAttributedString.Key.strokeWidth: -3]
         // Inline Navigation Title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.screenDark, NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 28) as Any, NSAttributedString.Key.strokeColor: UIColor.systemCyan, NSAttributedString.Key.strokeWidth: -3]
    }

    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                ZStack {
                    Image(uiImage: viewModel.imageIcon)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 10)
                    VStack {
                        ScrollView(.vertical) {
                            VStack(spacing: 30) {
                                VStack(spacing: 10.0) {
                                    unlimitedScreenplayStack
                                    allAccessCharacterBuilder
                                    allAccessSceneBuilder
                                }.padding(.top)
                                    .frame(width: reader.size.width)
                                Spacer()
                                Spacer()
                                VStack(alignment: .center, spacing: 15) {
                                    iapButtonView(subscripton: .monthly(viewModel.monthlyAllAccessProduct))
                                    iapButtonView(subscripton: .yearly(viewModel.yearlyAllAccessProduct))
                                    iapButtonView(subscripton: .lifetime(viewModel.foreverAllAccessProduct))
                                }
                                .frame(width: reader.size.width, height: 200)
                                Spacer()
                            }
                        }
                        VStack(spacing: 4.0) {
                            confirmButton
                                .padding(.bottom)
                            restoreButton
                        }
                    }
                }
                .frame(width: reader.size.width)
                .navigationTitle(viewModel.title)
                .toolbar(content: {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        closeButton
                    }
                })
                .foregroundStyle(.black)
                .background(.white)
            }
        }.onAppear {
            viewModel.selectedSubscription = .monthly(viewModel.monthlyAllAccessProduct)
        }
    }
    
    var unlimitedScreenplayStack: some View {
        HStack(spacing: 8) {
            Image(systemName: "infinity.circle.fill")
                .resizable()
                .frame(width: 32.0, height: 32.0)
                .foregroundStyle(Color(uiColor: .screenDark))
            Text("Unlimited Screenplays".localized)
                .font(.callout)
                .fontWeight(.medium)
                .frame(alignment: .leading)
                .foregroundStyle(Color(uiColor: .screenHaitiBlack))
            loadingView
            checkmarkView
            Spacer()
        }
        .padding(.leading)
    }
    
    var allAccessCharacterBuilder: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.2.circle.fill")
                .resizable()
                .frame(width: 32.0, height: 32.0)
                .foregroundStyle(Color(uiColor: .screenDark))
            Text("Character Builder".localized)
                .font(.callout)
                .fontWeight(.medium)
                .frame(alignment: .leading)
                .foregroundStyle(Color(uiColor: .screenHaitiBlack))
            loadingView
            checkmarkView
            Spacer()
        }
        .padding(.leading)
    }
    
    var allAccessSceneBuilder: some View {
        HStack(spacing: 8) {
            Image(systemName: "film.circle.fill")
                .resizable()
                .frame(width: 32.0, height: 32.0)
                .foregroundStyle(Color(uiColor: .screenDark))
            Text("Scene Builder".localized)
                .font(.callout)
                .fontWeight(.medium)
                .frame(alignment: .leading)
                .foregroundStyle(Color(uiColor: .screenHaitiBlack))
            loadingView
            checkmarkView
            Spacer()
        }
        .padding(.leading)
    }

    @ViewBuilder
    var loadingView: some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }

    @ViewBuilder
    var checkmarkView: some View {
        if viewModel.productPurchased {
            Text("✅")
        }
    }
    
    var confirmButton: some View {
        Button {
            Task {
                await viewModel.confirmButtonTapped()
            }
        } label: {
            Text(viewModel.confirmButtonTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: UIScreen.main.bounds.width - 40.0, height: 50)
                .background {
                    Color(.systemCyan)
                }
                .clipShape(
                    RoundedRectangle(cornerSize: CGSize(width: UIScreen.main.bounds.width - 40.0, height: 50))
                )
        }.disabled(viewModel.isLoading)
    }

    var restoreButton: some View {
        Button {
            viewModel.restoreButtonTapped()
        } label: {
            HStack {
                Text("Restore Purchases")
                    .foregroundStyle(Color(uiColor: .screenDark))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }.disabled(viewModel.isLoading)
    }

    var closeButton: some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("Close")
                .font(.headline)
                .foregroundStyle(.cyan)
        }

    }

    @ViewBuilder
    func iapButtonView(subscripton: InAppSubscription) -> some View {
            VStack(spacing: 4) {
                Spacer()
                Text(subscripton.title)
                    .font(.headline)
                    .foregroundStyle(viewModel.subscriptionTitleColor(for: subscripton))
                Text(subscripton.price)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.priceColor(for: subscripton))
                if let subtitle = subscripton.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.subtitleColor(for: subscripton))
                }
                Spacer()
            }
            .frame(minWidth: 200, minHeight: 100)
            .background {
                viewModel.backgroundColor(for: subscripton)
                    .opacity(0.99)
            }
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(viewModel.borderColor(for: subscripton), lineWidth: 5)
            )
            .onTapGesture {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                viewModel.selectedSubscription = subscripton
            }
    }

}

#Preview {
    IAPSubscriptionView(presentingViewController: UIViewController())
}

extension IAPSubscriptionView {
    class ViewModel: ObservableObject {

        @Published private var store = Store.shared
        @Published var selectedSubscription: InAppSubscription?
        @Published var isLoading: Bool = false
        @Published var productPurchased: Bool = false

        weak var presentingViewController: UIViewController?

        init(presentingViewController: UIViewController) {
            self.presentingViewController = presentingViewController
        }
        
        var title: String {
            "\("ScriptBuilder Pro".localized) ✔️".localized
        }
        
        var subtitle: String {
            "Unlimited ScriptBuilder Screenplays and ALL Access to Character Builder and Scene Builder".localized
        }
        
        var imageIcon: UIImage {
            #imageLiteral(resourceName: "screenplayAppIconAsset")
        }

        var confirmButtonTitle: String {
            let currencySymbol = Locale.current.currencySymbol ?? ""
            switch selectedSubscription {
            case .monthly:
                if let localPrice = monthlyAllAccessProduct?.price {
                    return "Get 1 month for \(currencySymbol)\(localPrice)".localized
                } else {
                    return "Get 1 month for $2.99"
                }
            case .yearly:
                if let localPrice = yearlyAllAccessProduct?.price {
                    return "Get 1 year for \(currencySymbol)\(localPrice)".localized
                } else {
                    return "Get 1 year for $19.99".localized
                }
            case .lifetime:
                if let localPrice = foreverAllAccessProduct?.price {
                    return "Get Lifetime for \(currencySymbol)\(localPrice)".localized
                } else {
                    return "Get Lifetime for $69.99".localized
                }
            default:
                return ""
            }
        }
        
        var monthlyAllAccessProduct: Product? {
            store.subscriptions.first { $0.id == store.unlimitedMonthlyIdentifier }
        }

        var yearlyAllAccessProduct: Product? {
            store.subscriptions.first { $0.id == store.unlimitedYearlyIdentifier }
        }
        
        var foreverAllAccessProduct: Product? {
            store.nonConsumables.first { $0.id == store.unlimitedForeverIdentifier }
        }
        
        func borderColor(for subscription: InAppSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .screenDark : .lightGray)
        }
        
        func backgroundColor(for subscription: InAppSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .systemCyan : .white)
        }
     
        func subscriptionTitleColor(for subscription: InAppSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .black : .black)
        }
        
        func priceColor(for subscription: InAppSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .white : .systemCyan)
        }
        
        func subtitleColor(for subscription: InAppSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .black : .screenDark)
        }
        
        func restoreButtonTapped() {
            Task {
                await store.sync()
            }
        }

        @MainActor
        func confirmButtonTapped() async {
            isLoading.toggle()
            var transaction: Transaction?
            switch selectedSubscription {
            case .monthly(let product):
                guard let monthlyProduct = product else { return }
                do {
                    transaction = try await store.purchase(monthlyProduct)
                    isLoading.toggle()
                    productPurchased = transaction != nil
                    guard productPurchased else { return }
                } catch {
                    return
                }
            case .yearly(let product):
                guard let yearlyProduct = product else { return }
                do {
                    transaction = try await store.purchase(yearlyProduct)
                    isLoading.toggle()
                    productPurchased = transaction != nil
                    guard productPurchased else { return }
                } catch {
                    return
                }
            case .lifetime(let product):
                guard let lifetimeProduct = product else { return }
                do {
                    transaction = try await store.purchase(lifetimeProduct)
                    isLoading.toggle()
                    productPurchased = transaction != nil
                    guard productPurchased else { return }
                } catch {
                    return
                }
            default:
                isLoading.toggle()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.dismissView()
            }
        }

        @MainActor
        func dismissView() {
            presentingViewController?.presentedViewController?.dismiss(animated: true)
        }
    }
}
