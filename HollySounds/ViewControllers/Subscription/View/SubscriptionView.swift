//
//  SubscriptionView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 28.12.2022.
//

import UIKit

final class SubscriptionView: UIView {
  
  let backgroundImage: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
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
    btn.backgroundColor = UIColor(named: "Color 8")
    btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
    return btn
  }()
  
  let appIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "OOMIE")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    constraintView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(subscriptions: [SubscriptionModel]) {
    subscriptions.forEach { subscription in
      let planView = SubscriptionPlanView()
      planView.set(subscription: subscription)
      planView.selectSubscription = { [weak self] selectedSubscription in
        self?.unselect()
        planView.select()
      }
      stackView.addArrangedSubview(planView)
    }
  }
  
  private func unselect() {
    if let pv = stackView.arrangedSubviews as? [SubscriptionPlanView] {
      pv.forEach {
        $0.unselect()
      }
    }
  }
}

fileprivate extension SubscriptionView {
  private func setupView() {
    backgroundColor = .clear
    addSubview(backgroundImage)
    addSubview(closeButton)
    addSubview(titleLabel)
    addSubview(stackView)
    addSubview(continueButton)
    addSubview(appIcon)
  }
  
  private func constraintView() {
    backgroundImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
    backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    
    closeButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 21).isActive = true
    closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    
    titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -32).isActive = true
    
    stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
    stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
    stackView.bottomAnchor.constraint(lessThanOrEqualTo: continueButton.topAnchor, constant: -32).isActive = true
    
    continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80).isActive = true
    continueButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
    continueButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
    continueButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
    
    appIcon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    appIcon.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
    appIcon.widthAnchor.constraint(equalToConstant: 93).isActive = true
    appIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
  }
}
