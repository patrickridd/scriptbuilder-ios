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

    init() {
        _viewModel = StateObject(wrappedValue: ViewModel())
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
                                    if let monthlyAllAccessProduct = viewModel.monthlyAllAccessProduct {
                                        iapButtonView(subscripton: .monthly(viewModel.monthlyAllAccessProduct))
                                    }
                                    if let yearlyAllAccessProduct = viewModel.yearlyAllAccessProduct {
                                        iapButtonView(subscripton: .yearly(viewModel.yearlyAllAccessProduct))
                                    }
                                    if let foreverAllAccessProduct = viewModel.foreverAllAccessProduct {
                                        iapButtonView(subscripton: .lifetime(viewModel.foreverAllAccessProduct))
                                    }
                                }
                                .frame(width: reader.size.width, height: 200)
                                Spacer()
                            }
                        }
                        confirmButton
                            .padding(.bottom)
                    }
                }
                .frame(width: reader.size.width)
                .navigationTitle(Text(viewModel.title))
                .foregroundStyle(.black)
                .background(.white)
            }
        }
    }
    
    var unlimitedScreenplayStack: some View {
        HStack(spacing: 8) {
            Image(systemName: "infinity.circle.fill")
                .resizable()
                .frame(width: 32.0, height: 32.0)
                .foregroundStyle(Color(uiColor: .screenDark))
            Text("Unlimited Screenplays")
                .font(.callout)
                .fontWeight(.medium)
                .frame(alignment: .leading)
                .foregroundStyle(Color(uiColor: .screenHaitiBlack))
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
            Text("Character Builder")
                .font(.callout)
                .fontWeight(.medium)
                .frame(alignment: .leading)
                .foregroundStyle(Color(uiColor: .screenHaitiBlack))
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
            Spacer()
        }
        .padding(.leading)
    }
    
    var confirmButton: some View {
        Button {
            viewModel.confirmButtonTapped()
        } label: {
            Text(viewModel.confirmButtonTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: UIScreen.main.bounds.width - 40.0, height: 50)
                .background {
                    Color(.systemCyan)
                }
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: UIScreen.main.bounds.width - 40.0, height: 50)))
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
    IAPSubscriptionView()
}


extension IAPSubscriptionView {
    class ViewModel: ObservableObject {

        @Published var products: [SKProduct]?
        @Published var selectedSubscription: InAppSubscription?

        init() {
            InAppPurchases.store.delegate = self

            // Retrieves in app purchases from apple
            InAppPurchases.store.requestProducts { [weak self] (_, products) in
                DispatchQueue.main.async {
                    self?.products = products
                    self?.selectedSubscription = .monthly(self?.monthlyAllAccessProduct)
                }
            }
        }
        
        var title: String {
            "\("ScriptBuilder Pro".localized) ✔️"
        }
        
        var subtitle: String {
            "Unlimited ScriptBuilder Screenplays and ALL Access to Character Builder and Scene Builder"
        }
        
        var imageIcon: UIImage {
            #imageLiteral(resourceName: "screenplayAppIconAsset")
        }

        var confirmButtonTitle: String {
            let currencySymbol = products?.first?.priceLocale.currencySymbol ?? ""
            switch selectedSubscription {
            case .monthly:
                if let localPrice = monthlyAllAccessProduct?.price {
                    return "Get 1 month for \(currencySymbol)\(localPrice)"
                } else {
                    return "Get 1 month for $2.99"
                }
               
            case .yearly:
                if let localPrice = yearlyAllAccessProduct?.price {
                    return "Get 1 year for \(currencySymbol)\(localPrice)"
                } else {
                    return "Get 1 year for $19.99"
                }
            case .lifetime:
                if let localPrice = foreverAllAccessProduct?.price {
                    return "Get Lifetime for \(currencySymbol)\(localPrice)"
                } else {
                    return "Get Lifetime for $74.99"
                }
            default:
                return ""
            }
        }
        
        var monthlyAllAccessProduct: SKProduct? {
            products?.filter({$0.productIdentifier == InAppPurchases.unlimitedMonthlyIdentifier}).first
        }

        var yearlyAllAccessProduct: SKProduct? {
            products?.filter({$0.productIdentifier == InAppPurchases.unlimitedYearlyIdentifier}).first
        }
        
        var foreverAllAccessProduct: SKProduct? {
            products?.filter({$0.productIdentifier == InAppPurchases.unlimitedForeverIdentifier}).first
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

        func confirmButtonTapped() {
            switch selectedSubscription {
            case .monthly(let product):
                guard let monthlyProduct = product else { return }
                InAppPurchases.store.buyProduct(monthlyProduct)
            case .yearly(let product):
                guard let yearlyProduct = product else { return }
                InAppPurchases.store.buyProduct(yearlyProduct)
            case .lifetime(let product):
                guard let lifetimeProduct = product else { return }
                InAppPurchases.store.buyProduct(lifetimeProduct)
            default:
                break
            }
        }
    }
}

extension IAPSubscriptionView.ViewModel: InAppPurchaseDelegate {
    
    func didCompleteTransaction(for productIdentifier: String?, with error: (any Error)?, displayLoadingImage: Bool) {
        
    }
    
    func startingTransaction() {
        
    }
    
}
