//
//  IAPManager.swift
//  countdown-core
//
//  Created by Assylbek Issatayev on 07/02/2021.
//

import StoreKit

final class IAPManager: NSObject, UIApplicationDelegate {
    private var request: SKProductsRequest?
    private var productsCompletion: ((Result<[SKProduct], Error>) -> Void)?
    private var restoreCompletion: ((Result<String, Error>) -> Void)?
    private var transactionCompletion: ((Result<String, Error>) -> Void)?

    static let shared = IAPManager()

    override private init() { super.init() }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SKPaymentQueue.default().add(self)
        return true
    }

    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    func requestProducts(
        productIdentifiers: Set<String>,
        completion: @escaping (Result<[SKProduct], Error>) -> Void
    ) {
        request?.cancel()
        productsCompletion = completion
        request = SKProductsRequest(
            productIdentifiers: productIdentifiers
        )
        request?.delegate = self
        request?.start()
    }

    func buy(
        product: SKProduct,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        transactionCompletion = completion
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        restoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(
        _: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        request = nil
        productsCompletion?(.success(response.products))
    }

    func request(
        _: SKRequest,
        didFailWithError error: Error
    ) {
        productsCompletion?(.failure(error))
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(
        _: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred:
                break
            case .failed:
                if let error = transaction.error as? SKError, error.code != .paymentCancelled {
                    transactionCompletion?(.failure(error))
                    restoreCompletion?(.failure(error))
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .purchased:
                let id = transaction.payment.productIdentifier
                UserDefaults.standard.setValue(true, forKey: id)
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionCompletion?(.success(id))
                restoreCompletion?(.success(id))
            case .purchasing:
                break
            case .restored:
                let id = transaction.original?.payment.productIdentifier
                    ?? transaction.payment.productIdentifier
                UserDefaults.standard.setValue(true, forKey: id)
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionCompletion?(.success(id))
                restoreCompletion?(.success(id))
            @unknown default:
                break
            }
        }
    }
}

