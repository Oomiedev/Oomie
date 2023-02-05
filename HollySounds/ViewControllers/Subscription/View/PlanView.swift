//
//  PlanView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 02.02.2023.
//

import UIKit
import StoreKit
import OomieOnboarding

final class PlanView: UIView {
  
  private let stackView: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.distribution = .fillProportionally
    view.spacing = 8
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let allPeriodLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    label.textColor = .oomieSecondaryText
    label.numberOfLines = 2
    label.font = .systemFont(ofSize: 24, weight: .bold)
    return label
  }()
  
  private let periodLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    label.textColor = .oomieSecondaryText
    label.numberOfLines = 2
    label.font = .systemFont(ofSize: 17, weight: .semibold)
    return label
  }()
  
  private let selectIcon: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    return view
  }()
  
  private let unselectImage = UIImage(systemName: "circle")
  private let selectImage = UIImage(systemName: "checkmark.circle")
  private let unselectBorderColor = UIColor.oomieSecondaryText.withAlphaComponent(0.5).cgColor
  private let selectBorderColor = UIColor.buttonPrimary.cgColor
  private let unselectBackgroundColor = UIColor.oomieSecondaryText.withAlphaComponent(0.2)
  private let selectBackgroundColor = UIColor.buttonPrimary.withAlphaComponent(0.2)
  
  private var isSelect: Bool = false
  private var subscription: SKProduct?

  var selectSubscription: ((SKProduct) -> Void)?
  
  private var allProducts: [OomieProProucts] = OomieProProucts.allCases
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    constraintView()
    setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = 16
    layer.cornerCurve = .continuous
    layer.borderWidth = 2
  }
  
  func set(subscription: SKProduct) {
    self.subscription = subscription
    let products = allProducts.filter { $0.rawValue == subscription.productIdentifier }
    guard let firstProduct = products.first else { return }
    allPeriodLabel.text = firstProduct.title
    
    if let subtitle = firstProduct.subTitle {
      periodLabel.text = subtitle
      stackView.addArrangedSubview(periodLabel)
    }
    
    let year: OomieProProucts = .oneYear
    
    if subscription.productIdentifier == year.rawValue {
      select()
      selectSubscription?(subscription)
    }
    
  }
  
  func unselect() {
    isSelect = false
    updateSelection()
  }
  
  func select() {
    isSelect = true
    updateSelection()
  }
}

fileprivate extension PlanView {
  private func setupView() {
    selectIcon.image = unselectImage
    selectIcon.tintColor = .secondaryLabel
    backgroundColor = unselectBackgroundColor
    
    addSubview(stackView)
    addSubview(selectIcon)
    stackView.addArrangedSubview(allPeriodLabel)
  }
  
  private func constraintView() {
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: selectIcon.leadingAnchor, constant: -16),
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
      
      selectIcon.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
      selectIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      selectIcon.widthAnchor.constraint(equalToConstant: 24),
      selectIcon.heightAnchor.constraint(equalToConstant: 24)
    ])
  }
  
  private func setupActions() {
    self.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
    self.addGestureRecognizer(tapGesture)
  }
  
  @objc private func didTap() {
    guard let subscription = self.subscription else { return }
    selectSubscription?(subscription)
  }
  
  private func updateSelection() {
    allPeriodLabel.textColor = isSelect ? .white : .oomieSecondaryText
    selectIcon.image = isSelect ? selectImage : unselectImage
    selectIcon.tintColor = isSelect ? .white : .secondaryLabel
    self.layer.borderColor = isSelect ? selectBorderColor : unselectBorderColor
    self.backgroundColor = isSelect ? selectBackgroundColor : unselectBackgroundColor
  }
}
