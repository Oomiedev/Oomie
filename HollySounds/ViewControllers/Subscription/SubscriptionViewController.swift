//
//  SubscriptionViewController.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 17.01.2023.
//

import UIKit
import StoreKit
import RealmSwift

typealias PurchaseCompletionHandler = ((SKPaymentTransaction?) -> Void)

final class SubscriptionViewController: UIViewController {
  
  let rootView = SubscriptionView()
  
  var selectProduct: ((SKProduct) -> Void)?
  var hasClosed: ((Bool) -> Void)?
  
  private var purchaseCompletionHandler: PurchaseCompletionHandler?
  
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
    hasClosed?(false)
    bindView()
  }

  
  private func bindView() {
    rootView.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    rootView.set(products: products)
    
    rootView.onSelectSubscription = { [weak self] product in
      self?.selectProduct?(product)
    }
  }
  
  @objc private func didTapCloseButton() {
    dismiss(animated: true) {
      self.hasClosed?(true)
      self.hasClosed = nil
    }
  }
}
