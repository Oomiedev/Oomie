//
//  SubscriptionService.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 17.01.2023.
//

import Foundation
import StoreKit

protocol SubscriptionService: AnyObject {
  func fetchSubscriptions(identifiers: [OomieProProucts])
}

final class SubscriptionServiceImpl: NSObject, SubscriptionService {
  
  var products: (([SKProduct]) -> Void)?
  
  func fetchSubscriptions(identifiers: [OomieProProucts]) {
    let request = SKProductsRequest(productIdentifiers: Set(identifiers.map { $0.rawValue }))
    request.delegate = self
    request.start()
  }
}

extension SubscriptionServiceImpl: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    if !response.products.isEmpty {
      self.products?(response.products.reversed())
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

