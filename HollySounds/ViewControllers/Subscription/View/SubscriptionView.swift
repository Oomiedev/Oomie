//
//  SubscriptionView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 02.02.2023.
//

import UIKit

import UIKit
import OomieOnboarding
import StoreKit

final class SubscriptionView: UIView {
  
  private lazy var backgroundImage: UIImageView = {
    let imageView = UIImageView()
    //imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "subscriptionBackground")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  let closeButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setImage(UIImage(named: "CloseIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
    return btn
  }()
  
  let continueButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("Continue", for: .normal)
    btn.layer.cornerRadius = 16
    btn.layer.cornerCurve = .continuous
    btn.setTitleColor(.white, for: .normal)
    btn.backgroundColor = .buttonPrimary
    btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
    return btn
  }()
  
  private lazy var appNameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.text = "O    O    M    I    E"
    label.textColor = .oomieWhite
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    return label
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.textColor = .white
    label.numberOfLines = 2
    label.text = "Get unlimited access\n to all sound packs"
    label.font = .systemFont(ofSize: 24, weight: .bold)
    return label
  }()
  
  private let stackView: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.spacing = 8
    view.distribution = .fillProportionally
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private var buttonBottom: NSLayoutConstraint!
  
  private var allProducts: [OomieProProucts] = OomieProProucts.allCases
  
  private var selectedSubscription: SKProduct?
  
  var onSelectSubscription:((SKProduct) -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    constraintView()
    
    continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(products: [SKProduct]) {
    products.forEach { [weak self] product in
      let planView = PlanView()
      planView.set(subscription: product)
      self?.stackView.addArrangedSubview(planView)
      
      planView.selectSubscription = { [weak self] selectedSubscription in
        self?.selectedSubscription = selectedSubscription
        self?.unselect()
        planView.select()
      }
      
      let year: OomieProProucts = .oneYear
      
      if product.productIdentifier == year.rawValue {
        self?.selectedSubscription = product
      }
    }
  }
  
  private func unselect() {
    if let pv = stackView.arrangedSubviews as? [PlanView] {
      pv.forEach {
        $0.unselect()
      }
    }
  }
  
  @objc private func didTapContinue() {
    guard let subscription = self.selectedSubscription else { return }
    self.onSelectSubscription?(subscription)
  }
}

private extension SubscriptionView {
  
  private func setupView() {
    backgroundColor = .clear
    addSubview(backgroundImage)
    addSubview(closeButton)
    addSubview(titleLabel)
    addSubview(stackView)
    addSubview(continueButton)
    addSubview(appNameLabel)
  }
  
  private func constraintView() {
    backgroundImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
    backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    
    appNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 28).isActive = true
    appNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
    closeButton.centerYAnchor.constraint(equalTo: appNameLabel.centerYAnchor).isActive = true
    closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    
    titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -32).isActive = true
    
    stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
    stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
    stackView.bottomAnchor.constraint(lessThanOrEqualTo: continueButton.topAnchor, constant: -32).isActive = true
    
    continueButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
    continueButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
    continueButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
    
    
    buttonBottom = continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -92)
    buttonBottom.isActive = true
    
    if UIScreen.main.bounds.height <= 667 {
      buttonBottom.constant = -32
    }
  }
}
