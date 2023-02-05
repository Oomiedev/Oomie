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
  
  var completeWithSuccess: (() -> Void)?
  
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
    bindView()
    SKPaymentQueue.default().add(self)
  }

  
  private func bindView() {
    rootView.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    rootView.set(products: products)
    
    rootView.onSelectSubscription = { [weak self] product in
      self?.product = product
      
      self?.buy(product) { [weak self] _ in
        self?.dismissView()
        
      }
    }
  }
  
  @objc private func didTapCloseButton() {
    dismissView()
  }
  
  private func dismissView() {
    dismiss(animated: true)
  }
  
  private func buy(_ product: SKProduct, completion: @escaping PurchaseCompletionHandler) {
    purchaseCompletionHandler = completion
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
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
      completeWithSuccess?()
      dismissView()
      
    } catch let error {
      print("Error: ", error)
    }
    
  }
}

extension SubscriptionViewController: SKPaymentTransactionObserver {
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
          self?.purchaseCompletionHandler?(transaction)
          self?.purchaseCompletionHandler = nil
        }
      @unknown default:
        print(transaction.transactionState.rawValue)
        break
      }
    }
  }
}

