//
//  SubscriptionViewController.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 28.12.2022.
//

import UIKit
import StoreKit

final class SubscriptionViewController: UIViewController {
  
  let rootView = SubscriptionView()
  
  let subscriptions: [SubscriptionModel] = [SubscriptionModel(title: "1 year 5$",
                                                              subTitle: "Only $0,42 in month",
                                                              isSelected: true),
                                            SubscriptionModel(title: "1 month 1$",
                                                              subTitle: nil,
                                                              isSelected: false)]
  
  private var product: SKProduct?
  
  let identifiers: [String] = ["one_year", "monthly"]
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.isOpaque = true
    bindView()
    
    let request = SKProductsRequest(productIdentifiers: Set(Subscriptions.allCases.compactMap { $0.rawValue }))
    request.delegate = self
    request.start()
  }
  
  private func bindView() {
    rootView.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    rootView.set(subscriptions: subscriptions)
  }
  
  @objc private func didTapCloseButton() {
    dismiss(animated: true)
  }
}

struct SubscriptionModel {
  let title: String
  let subTitle: String?
  var isSelected: Bool
}

extension SubscriptionViewController: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    if !response.invalidProductIdentifiers.isEmpty {
      print("invalid: ", response.invalidProductIdentifiers)
    }
  }
}

enum Subscriptions: String, CaseIterable {
  case year = "one_year"
  case monthly = "monthly"
}
