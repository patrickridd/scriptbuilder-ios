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
                                        iapButtonView(selectedSubscription: .monthly, with: monthlyAllAccessProduct, subscripton: .monthly)
                                    }
                                    if let yearlyAllAccessProduct = viewModel.yearlyAllAccessProduct {
                                        iapButtonView(selectedSubscription: .yearly, with: yearlyAllAccessProduct, subscripton: .yearly)
                                    }
                                    if let foreverAllAccessProduct = viewModel.foreverAllAccessProduct {
                                        iapButtonView(selectedSubscription: .lifetime, with: foreverAllAccessProduct, subscripton: .lifetime)
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
            
        } label: {
            Text("Let's Go")
                .font(.body)
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
    func iapButtonView(selectedSubscription: ViewModel.SelectedSubscription, with product: SKProduct, subscripton: InAppSubscription) -> some View {
            VStack(spacing: 4) {
                Spacer()
                Text(subscripton.title)
                    .font(.headline)
                    .foregroundStyle(viewModel.subscriptionTitleColor(for: selectedSubscription))
                Text(subscripton.price)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.priceColor(for: selectedSubscription))
                if let subtitle = subscripton.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.subtitleColor(for: selectedSubscription))
                }
                Spacer()
            }
            .frame(minWidth: 200, minHeight: 100)
            .background {
                viewModel.backgroundColor(for: selectedSubscription)
                    .opacity(0.99)
            }
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(viewModel.borderColor(for: selectedSubscription), lineWidth: 5)
            )
            .onTapGesture {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                viewModel.selectedSubscription = selectedSubscription
                viewModel.purchaseTapped(for: product)
            }
    }

}

#Preview {
    IAPSubscriptionView()
}


extension IAPSubscriptionView {
    class ViewModel: ObservableObject {
        
        enum SelectedSubscription {
            case monthly
            case yearly
            case lifetime
        }

        @Published var products: [SKProduct]?
        @Published var selectedSubscription: SelectedSubscription = .monthly
        
        init() {
            // Retrieves in app purchases from apple
            InAppPurchases.store.requestProducts { (_, products) in
                DispatchQueue.main.async {
                    self.products = products
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
        
        var monthlyAllAccessProduct: SKProduct? {
            products?.filter({$0.productIdentifier == InAppPurchases.unlimitedMonthlyIdentifier}).first
        }

        var yearlyAllAccessProduct: SKProduct? {
            products?.filter({$0.productIdentifier == InAppPurchases.unlimitedYearlyIdentifier}).first
        }
        
        var foreverAllAccessProduct: SKProduct? {
            products?.filter({$0.productIdentifier == InAppPurchases.unlimitedForeverIdentifier}).first
        }
        
        func purchaseTapped(for product: SKProduct) {
            print("\(product.productIdentifier) tapped")
        }
        
        func borderColor(for subscription: SelectedSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .screenDark : .lightGray)
        }
        
        func backgroundColor(for subscription: SelectedSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .systemCyan : .white)
        }
     
        func subscriptionTitleColor(for subscription: SelectedSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .black : .black)
        }
        
        func priceColor(for subscription: SelectedSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .white : .systemCyan)
        }
        
        func subtitleColor(for subscription: SelectedSubscription) -> Color {
            Color(uiColor: subscription == self.selectedSubscription ? .black : .screenDark)
        }
        
    }
}
