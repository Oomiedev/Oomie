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
  var dismissed: (() -> Void)?
  
  private var purchaseCompletionHandler: PurchaseCompletionHandler?
  
  private var product: SKProduct?
  private var products: [SKProduct]
  private var isFromOnboarding: Bool
  
  init(products: [SKProduct], isFromOnboarding: Bool) {
    self.products = products
    self.isFromOnboarding = isFromOnboarding
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  private func bindView() {
    rootView.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    rootView.set(products: products)
    
    rootView.onSelectSubscription = { [weak self] product in
      self?.selectProduct?(product)
    }
  }
  
  @objc private func didTapCloseButton() {
    if !isFromOnboarding {
      dismiss(animated: true) {
        self.hasClosed?(true)
        self.hasClosed = nil
      }
    } else {
      self.hasClosed?(true)
      self.hasClosed = nil
      dismiss()
    }
  }
  
  func dismiss() {
    let transition: CATransition = CATransition()
    transition.duration = 0.5
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition.type = CATransitionType.reveal
    transition.subtype = CATransitionSubtype.fromBottom
    if let window = view.window {
      window.layer.add(transition, forKey: nibName)
    }
    
    self.dismiss(animated: false, completion: nil)
    dismissed?()
  }
}
