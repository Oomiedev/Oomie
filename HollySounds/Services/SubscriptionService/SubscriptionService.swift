//
//  SubscriptionService.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 17.01.2023.
//

import Foundation
import StoreKit
import RealmSwift

protocol SubscriptionService: AnyObject {
  func fetchSubscriptions(identifiers: [OomieProProucts])
  func buy(product: SKProduct)
  func viewDismissed(status: Bool)
}

final class SubscriptionServiceImpl: NSObject, SubscriptionService {
  var products: (([SKProduct]) -> Void)?
  var paymentComplete: ((Bool) -> Void)?
  var dismissView: (() -> Void)?
  
  private var isDismissed: Bool = false
  
  
  func fetchSubscriptions(identifiers: [OomieProProucts]) {
    let request = SKProductsRequest(productIdentifiers: Set(identifiers.map { $0.rawValue }))
    request.delegate = self
    request.start()
  }
  
  func buy(product: SKProduct) {
    SKPaymentQueue.default().add(self)
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }
  
  func viewDismissed(status: Bool) {
    isDismissed = status
    print("1111-0 Status ", status)
  }
  
  private func getPackages() {
    do {
      let realm = try Realm()
      
      let objects = realm.objects(Package.self)
      
      let proPackages = objects.filter { $0.status == .pro }
      
      for obj in proPackages {
        realm.beginWrite()
        obj.status = .downloaded
        try realm.commitWrite()
      }
      
      if !isDismissed {
        dismissView?()
      }
      
      paymentComplete?(true)
      
    } catch let error {
      print("Error: ", error)
    }
  }
}

extension SubscriptionServiceImpl: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    if !response.products.isEmpty {
      self.products?(response.products.reversed())
    }
  }
}

extension SubscriptionServiceImpl: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
    for transaction in transactions {
      switch transaction.transactionState {
        
      case .purchasing, .deferred:
        print(transaction.transactionState.rawValue)
        break
      case .purchased, .restored:
        SKPaymentQueue.default().finishTransaction(transaction)
        DispatchQueue.main.async { [weak self] in
          self?.getPackages()
        }
      case .failed:
        SKPaymentQueue.default().finishTransaction(transaction)
        DispatchQueue.main.async { [weak self] in
          self?.paymentComplete?(false)
        }
      @unknown default:
        print(transaction.transactionState.rawValue)
        break
      }
    }
  }
}

enum OomieProProucts: String, CaseIterable {
  case oneYear = "one_year"
  case monthly = "monthly"
  
  var title: String {
    switch self {
    case .oneYear:
      return "1 year  5$"
    case .monthly:
      return "1 month  1$"
    }
  }
  
  var subTitle: String? {
    switch self {
    case .oneYear:
      return "Only $ 0,42 in month"
    case .monthly:
      return nil
    }
  }
}

