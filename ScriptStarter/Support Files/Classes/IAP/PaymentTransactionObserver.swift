//
//  IAPHelper.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/12/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class PaymentTransactionObserver: NSObject  {
    
    private let productIdentifiers: Set<ProductIdentifier>
    var purchasedProductIdentifiers = Set<ProductIdentifier>()
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    weak var delegate: InAppPurchaseDelegate?
    
    public init(productIds: Set<ProductIdentifier>) {
        self.productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
            }
        }
        super.init()
    }

}

// MARK: - StoreKit API

extension PaymentTransactionObserver {
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        delegate?.startingTransaction()
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().add(self)
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
        SKPaymentQueue.default().restoreCompletedTransactions()
        delegate?.startingTransaction()
    }

    func refreshPurchasedProducts() async {
        // Iterate through the user's purchased products.
        for await verificationResult in Transaction.all {
            switch verificationResult {
            case .verified(let transaction):
                // Check the type of product for the transaction
                // and provide access to the content as appropriate.
                purchasedProductIdentifiers.insert(transaction.productID)
                UserDefaults.standard.set(true, forKey: transaction.productID)
            case .unverified(let unverifiedTransaction, _):
                // Handle unverified transactions based on your
                // business model.
                purchasedProductIdentifiers.remove(unverifiedTransaction.productID)
                UserDefaults.standard.set(false, forKey: unverifiedTransaction.productID)
            }
        }
        
    }
}

// MARK: - SKProductsRequestDelegate

extension PaymentTransactionObserver: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension PaymentTransactionObserver: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue,
                             updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
//            purchasedProductIdentifiers.remove(transaction)
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue,
                             restoreCompletedTransactionsFailedWithError error: Error) {
        let productIdentifier = queue.transactions.first?.payment.productIdentifier
        self.delegate?.didCompleteTransaction(for: productIdentifier,
                                              with: nil,
                                              displayLoadingImage: false)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.payment.productIdentifier
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        delegate?.didCompleteTransaction(for: productIdentifier,
                                         with: nil,
                                         displayLoadingImage: true)
    }
   
    private func restore(transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.original?.payment.productIdentifier

        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        delegate?.didCompleteTransaction(for: productIdentifier,
                                         with: nil,
                                         displayLoadingImage: true)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.original?.payment.productIdentifier
        
        if let transactionError = transaction.error as Error? {
            delegate?.didCompleteTransaction(for: productIdentifier,
                                             with: transactionError,
                                             displayLoadingImage: true)
        } else {
            delegate?.didCompleteTransaction(for: productIdentifier,
                                             with: nil,
                                             displayLoadingImage: true)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }

        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: Notification.Name.IAPHelperPurchaseNotification, object: identifier)
    }

}

