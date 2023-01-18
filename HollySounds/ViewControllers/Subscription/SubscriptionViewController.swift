//
//  SubscriptionViewController.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 17.01.2023.
//

import UIKit
import StoreKit

final class SubscriptionViewController: UIViewController {
  
  let rootView = SubscriptionView()
  
  private var product: SKProduct?
  
  private var products: [SKProduct]
  
  init(products: [SKProduct]) {
    self.products = products
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindView()
    
    SKPaymentQueue.default().add(self)
  }

  
  private func bindView() {
    rootView.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    rootView.set(products: products)
    
    rootView.onSelectSubscription = { [weak self] product in
      self?.product = product
      
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(payment)
    }
  }
  
  @objc private func didTapCloseButton() {
    dismiss(animated: true)
  }
}

extension SubscriptionViewController: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
    transactions.forEach {
      switch $0.transactionState {
      case .purchasing:
        print("Purchasing")
      case .purchased:
        print("Purchased")
      case .failed:
        print("Failed")
      case .restored:
        print("Restored")
      case .deferred:
        print("Deferred")
      @unknown default:
        print("Uknown")
      }
    }
  }
}
