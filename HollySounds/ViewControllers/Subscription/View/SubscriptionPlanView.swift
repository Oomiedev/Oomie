//
//  SubscriptionPlanView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 28.12.2022.
//

import UIKit

final class SubscriptionPlanView: UIView {
  
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
    label.textColor = UIColor(named: "Color 9")
    label.numberOfLines = 2
    label.font = .systemFont(ofSize: 24, weight: .bold)
    return label
  }()
  
  private let periodLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    label.textColor = UIColor(named: "Color 9")
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
  private let unselectBorderColor = UIColor(named: "Color 9")?.withAlphaComponent(0.5).cgColor
  private let selectBorderColor = UIColor(named: "Color 8")?.cgColor
  private let unselectBackgroundColor = UIColor(named: "Color 9")?.withAlphaComponent(0.2)
  private let selectBackgroundColor = UIColor(named: "Color 8")?.withAlphaComponent(0.2)
  
  private var isSelect: Bool = false
  private var subscription: SubscriptionModel?
  
  var selectSubscription: ((SubscriptionModel) -> Void)?
  
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
  
  func set(subscription: SubscriptionModel) {
    self.subscription = subscription
    self.isSelect = subscription.isSelected
    allPeriodLabel.text = subscription.title
    if let subtitle = subscription.subTitle {
      periodLabel.text = subtitle
      stackView.addArrangedSubview(periodLabel)
    }
    
    updateSelection()
    if subscription.isSelected {
      selectSubscription?(subscription)
    }
  }
  
  func unselect() {
    subscription?.isSelected = false
    isSelect = false
    updateSelection()
  }
  
  func select() {
    subscription?.isSelected = true
    isSelect = true
    updateSelection()
  }
}

fileprivate extension SubscriptionPlanView {
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
    allPeriodLabel.textColor = isSelect ? .white : UIColor(named: "Color 9")
    selectIcon.image = isSelect ? selectImage : unselectImage
    selectIcon.tintColor = isSelect ? .white : .secondaryLabel
    self.layer.borderColor = isSelect ? selectBorderColor : unselectBorderColor
    self.backgroundColor = isSelect ? selectBackgroundColor : unselectBackgroundColor
  }
}
